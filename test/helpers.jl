exists(lib::Ptr, sym::Symbol) = Libdl.dlsym_e(lib, sym) != C_NULL

# https://github.com/JuliaLang/julia/pull/25646/
# The old behaviour was equivalent to the new `readuntil` called with `keep=true`, but the new
# `readuntil` defaults to `keep=false`.
# It's not possible for Julia to differentiate between a method that accepts kwargs and one that
# doesn't, so a graceful deprecation is not possible.
@static if VERSION < v"0.7.0-DEV.3510"
    _readuntil(args...) = readuntil(args...)
else
    _readuntil(args...) = readuntil(args...; keep=true)
end

function udp_srv(port::Int)
    r = Future()

    sock = UDPSocket()
    bind(sock, ip"127.0.0.1", port)

    @schedule begin
        put!(r, String(recv(sock)))
        close(sock)
    end

    return r
end

function tcp_srv(port::Int)
    r = Future()

    server = listen(ip"127.0.0.1", port)
    @schedule begin
        while !isready(r)
            sock = accept(server)
            put!(r, _readuntil(sock, '\0'))
        end
        close(server)
    end

    return r
end
