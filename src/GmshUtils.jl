"""
    addAirfoilPoints(airfoil::AirfoilParams, Points::Vector{Vector}, io::IOStream; tag="")

It writes on the .geo file the list of points of the airfoil.
"""
function addAirfoilPoints(airfoil::AirfoilParams, Points::Vector{Vector}, io::IOStream; tag="")
    airfoil_coo = get_coordinates(airfoil)
    for i = 1:1:(length(airfoil_coo[:, 1]))
        x = airfoil_coo[i, 1]
        y = airfoil_coo[i, 2]
        z = airfoil_coo[i, 3]
        x_string = string(x) * "*Cos(AoA) + " * string(y) * "*Sin(AoA)"
        y_string = "-1* " * string(x) * "*Sin(AoA) + " * string(y) * "*Cos(AoA)"
        z_string = string(z)

        str_tmp = "Point($i) = {" * x_string * "," * y_string * "," * z_string * ",a_dim};\n"
        push!(Points, [i, x, y, z, tag])
        write(io, str_tmp)
    end
end


function addShearPoint(shear_coord, Points::Vector{Vector}, io::IOStream; tag="shear")
    x = shear_coord[1, 1]
    y = shear_coord[1, 2]
    z = shear_coord[1, 3]
    x_string = "$L"
    y_string = "-1* " * string(x) * "*Sin(AoA) + " * string(y) * "*Cos(AoA)"
    nn = length(Points) + 1
    str_tmp = "Point($nn) = {" * x_string * "," * y_string * "," * string(z) * ",a_dim};\n"
    push!(Points, [nn, x, y, z, tag])
    write(io, str_tmp)

end


function addPoint(x, y, z, Points::Vector{Vector}, io::IOStream; tag="")
    nn = length(Points) + 1
    str_tmp = "Point($nn) = {$x, $y, $z};\n"
    write(io, str_tmp)
    push!(Points, [nn, x, y, z, tag])
end


function addLine(a1, a2, Lines::Vector{Vector}, io::IOStream; tag="")
    nn = length(Lines) + 1
    str_tmp = "Line($nn) = {$a1, $a2};\n"
    write(io, str_tmp)
    push!(Lines, [nn, a1, a2, tag])
end

function addSpline(a, Lines::Vector{Vector}, io::IOStream; tag="")
    nn = length(Lines) + 1
    if typeof(a) <:Vector
        str_tmp = "Spline($nn) = {$(a[1]), $(a[2])};\n"
        push!(Lines, [nn, a[1][1], a[2], tag])
    else
        str_tmp = "Spline($nn) = {$a};\n"
        push!(Lines, [nn, a[1], a[end], tag])
    end
 
    write(io, str_tmp)
end

function addCirc(a1, a2, a3, Lines::Vector{Vector}, io::IOStream; tag="")
    nn = length(Lines) + 1
    str_tmp = "Circle($nn) = {$a1, $a2, $a3};\n"
    write(io, str_tmp)
    push!(Lines, [nn, a1, a3])
end

function getLinesNodes(i::Int64, Lines::Vector{Vector})
    return (Lines[i][2], Lines[i][3])
end


function LoopfromPoints(a::Vector{Int64}, Lines::Vector{Vector})
    lines_id = Any[]

    push!(lines_id, LinefromPoints(a[1], a[2], Lines))
    loop = Any[]
    push!(loop, lines_id[1])
    #the second node

    loop[end] > 0 ? ctrl_sing = 2 : ctrl_sing = 1
    count = 2

    while count <= length(a)

        loop[end] > 0 ? ctrl_sing = 2 : ctrl_sing = 1

        point_1 = getLinesNodes(abs(loop[end]),Lines)[ctrl_sing]

        if count < length(a)
            point_2 = a[count+1]
        else
            point_2 = a[1]
        end


        push!(loop, LinefromPoints(point_1, point_2, Lines))
        count = count + 1
    end

    return loop
end



function LinefromPoints(p1::Int64, p2::Int64, Lines::Vector{Vector})
    p = [p1, p2]
    line_found = false
    line = 0
    while !line_found && line < length(Lines)
        line = line + 1
        line_nodes = getLinesNodes(line, Lines)
        line_nodes = [line_nodes[1], line_nodes[2]]
        sorted_line_nodes = sort(line_nodes)
        if sorted_line_nodes == sort(p)
            line_found = true
            if p[1] == line_nodes[2]
                line = -line
            end
        end

    end

    if line_found
        return line
    else
        return "Line not found"
    end
end


function addLoop(a::Vector, Loops::Vector{Vector}, io::IOStream)
    nn = length(Loops) + 1

    str_tmp = "Curve Loop($nn) = {$(a[1]),$(a[2]),$(a[3]),$(a[4]) };\n"
    write(io, str_tmp)
    push!(Loops, [nn, a])


end

function addPlaneSurface(a, Surfaces::Vector{Vector}, io::IOStream)
    nn = length(Surfaces) + 1

    str_tmp = "Plane Surface($nn) = {$a};\n"
    write(io, str_tmp)
    push!(Surfaces, [nn, a])

end

function TransfiniteCurve(curves::Vector, nodes::String, progression::Union{Float64,String}, io::IOStream)
    str_curves = "$(curves[1])"
    for i = 2:1:length(curves)
        str_curves = str_curves * ", $(curves[i])"

    end
    str_tmp = "Transfinite Curve {$str_curves} = $nodes Using Progression $progression; \n"
    write(io, str_tmp)

end

function TransfiniteSurfaces(surf::Vector, io::IOStream)

    for i = 1:1:length(surf)
        str_tmp = "Transfinite Surface {$(surf[i])};\n"
        write(io, str_tmp)

   end
end

function RecombineSurfaces(surf::Vector, recombine::Bool, io::IOStream)
    if recombine
    str_surf = "$(surf[1])"

    for i = 2:1:length(surf)
        str_surf = str_surf * ", $(surf[i])"



    end
    str_tmp = "Recombine Surface {$str_surf}; \n"
    write(io, str_tmp)

    end

end



function addPhysicalGroup(name::String, entities::Vector, type::String, PhysicalGroups::DataFrame, io::IOStream; add=false)

    if type != "Point" && type != "Curve" && type != "Surface"
        error("Type of Physical Group not recognized, available:Point, Curve, Surface")
    end

    str_ent = "$(entities[1])"
    for i = 2:1:length(entities)
        str_ent = str_ent * ", $(entities[i])"
    end

    if add == false
        nn = size(PhysicalGroups, 1) + 1
        str_tmp = "Physical $type (\"$name\", $nn) = {$str_ent}; \n"
        push!(PhysicalGroups, [nn, name, entities, type])

    else
        f_name = filter(:name => ==(name) , PhysicalGroups)
        f_type = filter(:type => ==(type) , f_name)
        nn = f_type.number[1]
        str_tmp = "Physical $type (\"$name\", $nn) += {$str_ent}; \n"
        append!(PhysicalGroups.entities[nn], entities)

    end
    write(io, str_tmp)

end