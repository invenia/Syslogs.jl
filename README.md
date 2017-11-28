# SystemLog
[![stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://invenia.github.io/SystemLog.jl/stable)
[![latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://invenia.github.io/SystemLog.jl/latest)
[![Build Status](https://travis-ci.org/invenia/SystemLog.jl.svg?branch=master)](https://travis-ci.org/invenia/SystemLog.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/github/invenia/SystemLog.jl?svg=true)](https://ci.appveyor.com/project/invenia/SystemLog-jl)
[![codecov](https://codecov.io/gh/invenia/SystemLog.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/SystemLog.jl)

## Features

- Local logging with the syslog libc interface
- Remote logging via UDP or TCP.
- Julia interface to the basic libc calls
- `Syslog` type which is a subtype for `IO` for use in other logging libraries (e.g., Memento.jl)

## TODO

- TLS support with MbedTLS.jl