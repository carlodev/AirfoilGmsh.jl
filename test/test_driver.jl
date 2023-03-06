function test_airfoil(url::String)
    fname= get_airfoil_name_test(url)
    csvname = fname*".csv"
    @test from_url_to_csv(url) == csvname
    @test typeof(create_geofile(csvname)) == IOStream
    @test typeof(create_geofile(csvname; Reynolds=200e3)) == IOStream
    @test typeof(create_geofile(csvname; dimension = 3 )) == IOStream
    rm(csvname)
    rm(fname*"_2D.geo")
    rm(fname*"_3D.geo")
end


function get_airfoil_name_test(url::String)
    s = findlast("/", url)[1]
    return url[s+1:end-4]
end
