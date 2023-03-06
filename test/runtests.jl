using AirfoilGmsh
using Test

url_test = ["https://m-selig.ae.illinois.edu/ads/coord/c141a.dat", 
"https://m-selig.ae.illinois.edu/ads/coord/e1098.dat",
"https://m-selig.ae.illinois.edu/ads/coord/n0012.dat",
"https://m-selig.ae.illinois.edu/ads/coord/n0009sm.dat"]

@testset "AirfoilGmsh.jl" begin
    # Test reading from web
    include("test_driver.jl")
    for url in url_test
        test_airfoil(url)
    end

end