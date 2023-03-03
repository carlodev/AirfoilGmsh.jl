using AirfoilGmsh
using Test

@testset "AirfoilGmsh.jl" begin
    # Test reading from web
    url = "https://m-selig.ae.illinois.edu/ads/coord/c141a.dat"
    @test from_url_to_csv(url) == "c141a.csv"
    @test typeof(create_geofile("c141a.csv")) == IOStream
    @test typeof(create_geofile("c141a.csv"; dimension = 3 )) == IOStream
    
    url = "https://m-selig.ae.illinois.edu/ads/coord/e1098.dat"
    @test from_url_to_csv(url) == "e1098.csv"
    @test typeof(create_geofile("e1098.csv")) == IOStream   
    @test typeof(create_geofile("e1098.csv"; dimension = 3)) == IOStream 
end


rm("c141a.csv")
rm("c141a_2D.geo")
rm("c141a_3D.geo")


rm("e1098.csv")
rm("e1098_2D.geo")
rm("e1098_3D.geo")