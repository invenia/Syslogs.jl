using Documenter, SystemLog

makedocs(
    modules=[SystemLog],
    format=:html,
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/SystemLog.jl/blob/{commit}{path}#L{line}",
    sitename="SystemLog.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[
        "assets/invenia.css",
     ],
)

deploydocs(
    repo = "github.com/invenia/SystemLog.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
