using Documenter, AirfoilGmsh

makedocs(
    sitename = "AirfoilGmsh.jl",
    modules = [AirfoilGmsh],
    pages = [
        "Introduction" => "index.md",
        "Usage" => "usage.md",
        "References" => "ref.md"
    ],
)

deploydocs(
    repo = "github.com/carlodev/AirfoilGmsh.jl",
    push_preview = true,
)
