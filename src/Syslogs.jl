__precompile__()

module Syslogs

export Syslog

using Compat
using Compat.Sockets
using Compat.Printf
using Nullables

# Default UDP and TCP ports
const UDP_PORT = 514
const TCP_PORT = 514

const LOG_EMERG   = 0  # system is unusable
const LOG_ALERT   = 1  # action must be taken immediately
const LOG_CRIT    = 2  # critical conditions
const LOG_ERR     = 3  # error conditions
const LOG_WARNING = 4  # warning conditions
const LOG_NOTICE  = 5  # normal but significant condition
const LOG_INFO	  = 6  # informational
const LOG_DEBUG   = 7  # debug-level messages

#  facility codes
const LOG_KERN     = 0  # kernel messages
const LOG_USER     = 1  # random user-level messages
const LOG_MAIL     = 2  # mail system
const LOG_DAEMON   = 3  # system daemons
const LOG_AUTH     = 4  # security/authorization messages
const LOG_SYSLOG   = 5  # messages generated internally by syslogd
const LOG_LPR      = 6  # line printer subsystem
const LOG_NEWS     = 7  # network news subsystem
const LOG_UUCP     = 8  # UUCP subsystem
const LOG_CRON     = 9  # clock daemon
const LOG_AUTHPRIV = 10	# security/authorization messages (private)

#  other codes through 15 reserved for local use
const LOG_LOCAL0 = 16
const LOG_LOCAL1 = 17
const LOG_LOCAL2 = 18
const LOG_LOCAL3 = 19
const LOG_LOCAL4 = 20
const LOG_LOCAL5 = 21
const LOG_LOCAL6 = 22
const LOG_LOCAL7 = 23

# Define dictionary mappings from keywords to codes
# for levels and facilities.
const LEVELS = Dict(
    :emergency => LOG_EMERG,
    :emerg => LOG_EMERG,
    :alert => LOG_ALERT,
    :critical => LOG_CRIT,
    :crit => LOG_CRIT,
    :error => LOG_ERR,
    :err => LOG_ERR,
    :warning => LOG_WARNING,
    :warn => LOG_WARNING,
    :notice => LOG_NOTICE,
    :info => LOG_INFO,
    :debug => LOG_DEBUG,
)


# Define valid syslog facilities (even kern, which isn't accessible from userspace).
const FACILITIES = Dict(
    :kern => LOG_KERN,
    :user => LOG_USER,
    :mail => LOG_MAIL,
    :daemon => LOG_DAEMON,
    :auth => LOG_AUTH,
    :security => LOG_AUTH,
    :syslog => LOG_SYSLOG,
    :lpr => LOG_LPR,
    :news => LOG_NEWS,
    :uucp => LOG_UUCP,
    :cron => LOG_CRON,
    :authpriv => LOG_AUTHPRIV,
    :local0 => LOG_LOCAL0,
    :local1 => LOG_LOCAL1,
    :local2 => LOG_LOCAL2,
    :local3 => LOG_LOCAL3,
    :local4 => LOG_LOCAL4,
    :local5 => LOG_LOCAL5,
    :local6 => LOG_LOCAL6,
    :local7 => LOG_LOCAL7,
)

openlog(ident::String, logopt::Integer, facility::Integer) =
    ccall((:openlog, "libc"), Cvoid, (Ptr{UInt8}, UInt, UInt), ident, logopt, facility)

syslog(priority::Integer, msg::String) =
    ccall((:syslog, "libc"), Cvoid, (UInt, Ptr{UInt8}), priority, msg)

closelog() = ccall((:closelog, "libc"), Cvoid, ())

makepri(facility::Integer, priority::Integer) = (UInt(facility) << 3) | UInt(priority)

"""
    Syslog <: IO

`Syslog` handles writing logs to local (libc inteface) and remote (UDP / TCP sockets) syslog servers.

# Fields
# `address::Nullable{Tuple{IPAddr, Int}}`: The host and ip for the remote servers. Logs locally if null.
* `facility::Symbol`: The syslog facility to write to (e.g., :local0, :ft, :daemon, etc) (defaults to :user)
* `socket::Nullable{Base.LibuvStream`: A UDP or TCP socket for logging messages. Logs locally if null.
"""
mutable struct Syslog <: IO
    address::Nullable{Tuple{IPAddr, Int}}
    facility::Symbol
    socket::Nullable{Base.LibuvStream}
end

Syslog(host::IPAddr, port::Int, facility::Symbol=:user; tcp::Bool=false) =
    Syslog((host, port), facility, tcp ? connect(host, port) : UDPSocket())

Syslog(host::IPAddr, facility::Symbol=:user; tcp::Bool=false) =
    Syslog(host, tcp ? TCP_PORT : UDP_PORT, facility; tcp=tcp)

Syslog(facility::Symbol=:user) =
    Syslog(Nullable{Tuple{IPAddr, Int}}(), facility, Nullable{Base.LibuvStream}())

"""
    println(::Syslog, ::AbstractString, ::AbstractString)

Converts the first AbstractString to a Symbol and call
`println(::Syslog, ::Symbol, ::AbstractString)`
"""
function Base.println(io::Syslog, level::AbstractString, msg::AbstractString)
    println(io, Symbol(lowercase(level)), msg)
end

function Base.println(io::Syslog, level::Symbol, msg::String)
    haskey(LEVELS, level) || throw(ArgumentError("Invalid logging level: $level."))
    haskey(FACILITIES, io.facility) || throw(ArgumentError("Invalid logging facility: $(io.facility)."))

    if !isnull(io.socket)
        sock = get(io.socket)

        if !(isa(sock, UDPSocket) || isa(sock, TCPSocket))
            throw(ArgumentError("Syslog only supports UDP or TCP sockets."))
        end
    end

    pri = makepri(FACILITIES[io.facility], LEVELS[level])

    if isnull(io.socket) && isnull(io.address)
        syslog(pri, msg)
    else
        sock = get(io.socket)
        addr = get(io.address)
        content = @sprintf("<%d>%s\0", pri, msg)

        if isa(sock, UDPSocket)
            # info("Sending ($(typeof(sock))): $content")
            send(sock, addr[1], addr[2], content)
        else
            # info("Sending ($(typeof(sock))): $content")
            try
                write(sock, content)
            catch e
                close(sock)
                s = connect(addr[1], addr[2])
                io.socket = s
                write(s, content)
            end
        end
    end
end

Base.log(io::Syslog, args...) = println(io, args...)

function Base.flush(io::Syslog)
    if !isnull(io.socket) && isa(get(io.socket), TCPSocket)
        flush(get(io.socket))
    end
end

function Base.close(io::Syslog)
    if !isnull(io.socket)
        close(get(io.socket))
    end
end

end  # module
