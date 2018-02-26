using Compat.Test
using Syslogs

import Compat.Libdl
using Compat.Distributed
using Compat: replace
using Base: BufferStream
using TestSetExtensions

eval(Syslogs, Meta.parse("UDP_PORT = 8080"))
eval(Syslogs, Meta.parse("TCP_PORT = 8080"))

include("helpers.jl")

@testset ExtendedTestSet "Syslog" begin
    @testset "Local" begin
        info("Local Tests")
        io = Syslog()
        println(io, "info", "foobar")
    end

    @testset "Remote" begin
        logs = filter(!isempty, split(read("scripts/output.log", String), "\n\0"))
        test_logs = map(logs) do s
            input = replace(s, r"^<\d+>" => "")
            level = last(split(first(split(s, ':'))))
            (level, input, s * "\0")
        end

        @testset "Invalid Stream" begin
            io = Syslog((ip"127.0.0.1", 8080), :user, BufferStream())
            @test_throws ArgumentError println(io, :info, "foobar")
        end

        @testset "UDP" begin
            info("UDP Tests")
            @testset "Simple" begin
                r = udp_srv(8080)
                io = Syslog(ip"127.0.0.1", 8080; tcp=false)
                println(io, "info", "foobar")
                s = fetch(r)
                @test contains(s, "foobar")
                close(io)
            end

            @testset "SysLogHandler" begin
                @testset "$input" for (level, input, output) in test_logs
                    r = udp_srv(8080)
                    io = Syslog(ip"127.0.0.1", 8080; tcp=false)
                    info("Sending (UDP): $level, $input")
                    println(io, level, input)
                    s = fetch(r)
                    @test strip(s) == strip(output)
                    close(io)

                    r = udp_srv(8080)
                    io = Syslog(ip"127.0.0.1"; tcp=false)
                    info("Sending (UDP): $level, $input")
                    println(io, level, input)
                    s = fetch(r)
                    @test strip(s) == strip(output)
                    close(io)
                end
            end
        end

        @testset "TCP" begin
            info("TCP Tests")

            @testset "Simple" begin
                r = tcp_srv(8080)
                io = Syslog(ip"127.0.0.1", 8080; tcp=true)
                println(io, "info", "foobar")
                s = fetch(r)
                @test contains(s, "foobar")
                flush(io)
                close(io)
            end

            @testset "SysLogHandler" begin
                @testset "$input" for (level, input, output) in test_logs
                    r = tcp_srv(8080)
                    info("Sending (TCP): $level, $input")
                    io = Syslog(ip"127.0.0.1", 8080; tcp=true)
                    println(io, level, input)
                    s = fetch(r)
                    @test s == output
                    close(io)
                end
            end

            @testset "Disonnect" begin
                serv = listen(ip"127.0.0.1", 8080)
                io = Syslog(ip"127.0.0.1", 8080; tcp=true)
                close(io)
                log(io, "info", "foobar\n")
                println(typeof(io.socket))
                flush(io)
                close(io)
                close(serv)
            end
        end
    end

    @testset "Libc" begin
        info("Libc Tests")
        Syslogs.openlog("syslog", 0, Syslogs.LOG_USER)
        Syslogs.closelog()
    end
end
