# Syslogs
[![stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/Syslogs.jl/stable)
[![latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/Syslogs.jl/latest)
[![Build Status](https://travis-ci.org/invenia/Syslogs.jl.svg?branch=master)](https://travis-ci.org/invenia/Syslogs.jl)
[![codecov](https://codecov.io/gh/invenia/Syslogs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Syslogs.jl)

## Installation

```julia
Pkg.clone("https://github.com/invenia/Syslogs.jl")
```

## Usage

```julia
io = Syslog()
println(io, :info, "Hello World!")
```

To log to a remote server you can pass the remote ip address and port to the `Syslog` constructor (e.g., `Syslog(ipaddr, port; tcp=true)`).

## Features

- Local logging with the syslog libc interface
- Remote logging via UDP or TCP.
- Julia interface to the basic libc calls
- `Syslog` type which is a subtype for `IO` for use in other logging libraries (e.g., Memento.jl)

## TODO

- TLS support with MbedTLS.jl
