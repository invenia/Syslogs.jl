using Documenter, Syslogs

makedocs(
    modules=[Syslogs],
    format=:html,
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/Syslogs.jl/blob/{commit}{path}#L{line}",
    sitename="Syslogs.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[
        "assets/invenia.css",
     ],
)

deploydocs(
    repo = "github.com/invenia/Syslogs.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
