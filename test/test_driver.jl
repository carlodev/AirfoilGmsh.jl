function test_airfoil(url::String)
    fname= get_airfoil_name_test(url)
    csvname = fname*".csv"
    @test from_url_to_csv(url) == csvname
    @test typeof(create_geofile(csvname)) == Tuple{IOStream, String}

    @test typeof(create_geofile(csvname, BoundaryLayer(Reynolds=200e3))) == Tuple{IOStream, String}
    @test typeof(create_geofile(csvname, DomainInfo(dimension = 2) )) == Tuple{IOStream, String}
    # x,y,wl,wu = increase_resolution_airfoil(csvname,500; maxiters = 10, maxtime = 10)
    # @test typeof(x) <: Vector{Float64}
    # rm(csvname)
    # rm(fname*"_2D.geo")
    # rm(fname*"_3D.geo")
end

function get_airfoil_name_test(url::String)
    s = findlast("/", url)[1]
    return url[s+1:end-4]
end
