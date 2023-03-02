using AirfoilGmsh
using Test


@testset "AirfoilGmsh.jl" begin
    # Test reading from web
    url = "https://m-selig.ae.illinois.edu/ads/coord/c141a.dat"
    @test from_url_to_csv(url) == "c141a.csv"

    
end
