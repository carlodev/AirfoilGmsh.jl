using Documenter, AirfoilGmsh

makedocs(
    sitename = "AirfoilGmsh.jl",
    modules = [AirfoilGmsh],
    pages = [
        "Introduction" => "index.md",
        "Usage" => "usage.md",
    ],
)

deploydocs(
    repo = "github.com/carlodev/AirfoilGmsh.jl",
    push_preview = true,
)
