"""
    AirfoilPoints

It contains informations about the airfoil points.
- coordinates::Matrix{Float64} : x,y,z matrix 
- num::Int64 : number of points
- leading_edge::Vector{Float64} : leading edge points indexes
- trailing_edge::Vector{Float64} : trailing edge points indexes
"""
struct AirfoilPoints
    coordinates::Matrix{Float64}
    num::Int64
    leading_edge::Vector{Int64}
    trailing_edge::Vector{Int64}
end

"""
    AirfoilParams

- name::String : airfoil name
- points::AirfoilPoints
- chord::Float64 : chord length
- sharp_end::Bool : if the trailing edge is sharp or not
- sharp_idx::Int64 : if 1 is sharp, if 2 is not sharp
"""
struct AirfoilParams
    name::String
    points::AirfoilPoints
    chord::Float64
    sharp_end::Bool
    sharp_idx::Int64
end


function get_coordinates(ap::AirfoilParams)
    get_coordinates(ap.points)
end

function get_coordinates(ap::AirfoilPoints)
    ap.coordinates
end

function is_sharp(ap::AirfoilParams)
    ap.sharp_end
end

"""
get_airfoil_name(filename::String)

It removes the .csv extension. It verify that the file has the .csv extension.
Return a string with the name of the airfoil.
"""
function get_airfoil_name(filename::String)
    @assert filename[end-3:end] == ".csv"
    airfoil_name = filename[1:end-4]
    return airfoil_name
end


"""
    AirfoilParams(filename::String, trailing_edge_points, leading_edge_points)

Constructor from file
"""
function AirfoilParams(filename::String, chord::Float64, trailing_edge_points, leading_edge_points)
    #Get aifoil name removing the .csv extension
    name = get_airfoil_name(filename)

    airfoil_points_list, sharp_end, sharp_idx, trailing_edge_points, leading_edge_points = get_airfoil_features(filename, chord, trailing_edge_points, leading_edge_points)
    num = size(airfoil_points_list)[1]

    points = AirfoilPoints(airfoil_points_list, num, leading_edge_points, trailing_edge_points)
    AirfoilParams(name, points, chord, sharp_end, sharp_idx)
end


function get_airfoil_features(filename::String, c::Float64, trailing_edge_points, leading_edge_points)
    airfoil_points_list = CSV.File(filename, header=true) |> Tables.matrix
    formatting_airfoil_points!(airfoil_points_list,c)
    
    trailing_edge_points = findTE(trailing_edge_points, c, airfoil_points_list)
    sharp_end, sharp_idx = detect_end(trailing_edge_points)
    
    leading_edge_points = findLE(leading_edge_points, c, airfoil_points_list)

    airfoil_points_list, sharp_end, sharp_idx, trailing_edge_points, leading_edge_points
end


function formatting_airfoil_points!(airfoil_points_list::Matrix{Float64}, c::Float64)
    if airfoil_points_list[1, 1] != c
        error("the file must start from the trailing edge")
    end

    clockwise = is_clockwise(airfoil_points_list)
    if clockwise
        reverse!(airfoil_points_list, dims = 1)
    end
end

"""
    is_clockwise(Mat::Matrix{Float64})

Verify that the the sequence of points is clockwise, if yes it reverses the order.
"""
function is_clockwise(Mat::Matrix{Float64})
    idx_1 = Int(floor(length(Mat[:, 1]) / 4))
    if (Mat[idx_1, 1] - Mat[idx_1+1, 1]) < 0
        clockwise = true
    else
        clockwise = false
    end

    return clockwise
end

"""
    findTE(trailing_edge_points, c::Float64, airfoil_points_list::Matrix{Float64})

Automatically detects the trailing edge points indexes
"""
function findTE(trailing_edge_points, c::Float64, airfoil_points_list::Matrix{Float64})
    atol = 1e-6
    while isempty(trailing_edge_points)
        trailing_edge_points = findall(x -> isapprox(x, c; atol=atol), airfoil_points_list[:, 1])
        atol = atol * 2
    end
    println(trailing_edge_points)
    sort!(trailing_edge_points)
    trailing_edge_points
end

"""
detect_end(trailing_edge_points::Vector{Int64})

Automatically detects if the trailing edge is sharp or not
"""
function detect_end(trailing_edge_points::Vector{Int64})
    if length(trailing_edge_points) == 1
        sharp_end = true
        sharp_idx = 1
        println("sharp edge")
    elseif length(trailing_edge_points) == 2
        sharp_end = false
        sharp_idx = 2
        println("non-shap edge")
    else
        error("Impossible to determine the trailing edge, please specify")
    end
    return sharp_end, sharp_idx
end

"""
    findLE(leading_edge_points, c::Float64, airfoil_points_list::Matrix{Float64})

Automatically detects the leeading edge points indexes
"""
function findLE(leading_edge_points, c::Float64, airfoil_points_list::Matrix{Float64})

    atol = 1e-5
    d = 0.07*c #Location of trailing points
    while length(leading_edge_points) != 2
        leading_edge_points = findall(x -> isapprox(x, d; atol=atol), airfoil_points_list[:, 1])
        atol = atol * 2
        if length(leading_edge_points) > 2
            distance_ = abs.(leading_edge_points[1:end-1] - leading_edge_points[2:end])
            neig_ = findall(x -> x==1, distance_)
            deleteat!(leading_edge_points,neig_)
        end
    end
    sort!(leading_edge_points)
    leading_edge_points
end