"""
    create_geofile(filename::String; Reynolds = -1, h0 = -1, leading_edge_points = Int64[], trailing_edge_points = Int64[], chord=1.0, dimension=2, elements = :QUAD)

It is the main function of the package. From a csv file containing the airfoil points it creates a .geo file.
The .geo file can be created using the function [`from_url_to_csv`](@ref).
The user can specify just the file name.
´´´julia
    create_geofile("naca0012.csv")
´´´
It is also possibile to provide extra arguments such as the Reynolds number and/or the first layer height for a better extimation of the boundary-cell properties.
It is possible to overwrite the extimation of the trailing edge and leading edge made by the code providing the relative points numbers.
The mesh can be created in 2D or 3D. In 3D case by default are created periodic boundary conditions in the `z` direction.
It is possible to create a mesh with the following options:\\

|Type of element| Dimension | Symbol    |
|---------------|-----------|-----------|
|Quadrilateral  | 2D        | :QUAD     |
|Hexaedral      | 3D        | :HEX      |
|Triangular     | 2D        | :TRI      |
|Thetraedreal   | 3D        | :TETRA    |
"""
function create_geofile(filename::String; Reynolds = -1, h0 = -1, leading_edge_points = Int64[], trailing_edge_points = Int64[], chord=1.0, dimension=2, elements = :QUAD)
    
refinement_params = refinement_parameters(Reynolds, h0, chord)
    
if elements == :QUAD || elements == :HEX
    recombine = true
    else
    recombine = false
end
 
Points = Vector[]
Lines = Vector[]
Surfaces = Vector[]
Loops = Vector[]
PhysicalGroups = DataFrame(number=Int64[], name=String[], entities=Vector[], type=String[])


Airfoil = AirfoilParams(filename, chord, trailing_edge_points, leading_edge_points)

io = start_writing(Airfoil, dimension, chord, refinement_params)

addAirfoilPoints(Airfoil, Points, io)
Airfoil.points.leading_edge
Airfoil.points.trailing_edge[Airfoil.sharp_idx]

N_edge = 5
# Create airfoil lines
    
spline_airfoil_top = addSpline(Airfoil.points.trailing_edge[1] : Airfoil.points.leading_edge[1], Lines, io)[end][1]
spline_airfoil_le = addSpline(Airfoil.points.leading_edge[1] : Airfoil.points.leading_edge[2], Lines, io)[end][1]
    
if ! is_sharp(Airfoil)
    spline_airfoil_te = addLine(Airfoil.points.trailing_edge[1], Airfoil.points.trailing_edge[2], Lines, io)[end][1]
    spline_airfoil_bottom = addSpline(Airfoil.points.leading_edge[2] : Airfoil.points.trailing_edge[Airfoil.sharp_idx] , Lines, io)[end][1]
else
    b_points = [Airfoil.points.leading_edge[2]: Airfoil.points.num, Airfoil.points.trailing_edge[Airfoil.sharp_idx]]
    spline_airfoil_bottom = addSpline(b_points, Lines, io)[end][1]
end



#External Domain points
point1 = addPoint(0, "C", 0, Points, io; tag ="external")[end][1]
point2 = addPoint(0, "-C", 0, Points, io; tag ="external")[end][1]
    
point5 = addPoint("L", "C", 0, Points, io; tag ="external")[end][1]
point6 = addPoint("L", "-C", 0, Points, io; tag ="external")[end][1]
    
point3 = addPoint(chord, "C", 0, Points, io; tag ="external")[end][1]
point4 = addPoint(chord, "-C", 0, Points, io; tag ="external")[end][1]
    
#Trailing edge point at the rear part
#This allows the shear to rotate as the AoA impose it

x_tmp, y_tmp = Points[Airfoil.points.trailing_edge[1]][2:3]
point7 = addPoint("L", "-L* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*L*Cos(AoA)", 0, Points, io; tag ="shear_external")[end][1]
    
    
    
    
    if ! is_sharp(Airfoil)
        x_tmp, y_tmp = Points[Airfoil.points.trailing_edge[2]][2:3]
        point8 = addPoint("L", "-L* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*L*Cos(AoA)", 0, Points, io; tag ="shear_external")[end][1]
    end
    
    
    origin_idx = addPoint(0, 0, 0, Points, io; tag ="origin")[end][1]
    
    #add Refinement points   
    point1r = addPoint(" Refinement_offset*Sin(AoA)", " Refinement_offset*Cos(AoA)", 0, Points, io; tag ="refinement")[end][1]
    point2r = addPoint(" - Refinement_offset*Sin(AoA)", " - Refinement_offset*Cos(AoA)", 0, Points, io; tag ="refinement")[end][1]
    
    
    x_tmp, y_tmp = Points[Airfoil.points.trailing_edge[1]][2:3]
    point3r = addPoint("$chord*Cos(AoA)", "-$chord* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*$chord*Cos(AoA) + Refinement_offset", 0, Points, io; tag ="refinement")[end][1]
    point7r = addPoint("L", "-L* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*L*Cos(AoA)+ Refinement_offset", 0, Points, io; tag ="refinement")[end][1]
    
    if ! is_sharp(Airfoil)
        x_tmp, y_tmp = Points[Airfoil.points.trailing_edge[2]][2:3]
    end
    
    point8r = addPoint("L", "-L* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*L*Cos(AoA) - Refinement_offset", 0, Points, io; tag ="refinement")[end][1]
    point4r = addPoint("$chord*Cos(AoA)", "-$chord* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*$chord*Cos(AoA) - Refinement_offset", 0, Points, io; tag ="refinement")[end][1]
    
    
    
 

    circ = addCirc(point2, origin_idx, point1, Lines, io; tag="external_circ")[end][1]
    
    
    l1 = addLine(point1, point3, Lines, io; tag = "external")[end][1]
    l2 = addLine(point2, point4, Lines, io; tag = "external")[end][1]
    l3 = addLine(point3, point5, Lines, io; tag = "external")[end][1]
    l3t = addLine(point3r, Airfoil.points.trailing_edge[1], Lines, io; tag = "external")[end][1]
    
    l2t = addLine(point4r, Airfoil.points.trailing_edge[Airfoil.sharp_idx], Lines, io;)[end][1]
    
    l4 = addLine(point4, point6, Lines, io; tag = "external")[end][1]
    l1l = addLine(point1, point1r, Lines, io)[end][1]
    l1lr = addLine(point1r, Airfoil.points.leading_edge[1], Lines, io;)[end][1]
    
    l2l = addLine(point2, point2r, Lines, io;)[end][1]
    l2lr = addLine(point2r, Airfoil.points.leading_edge[2], Lines, io;)[end][1]
    
    
    l5 = addLine(point5, point7r, Lines, io;)[end][1]
    l5r = addLine(point7r, point7, Lines, io;)[end][1]
    
    if is_sharp(Airfoil)
        l7 = addLine(point7, point8r, Lines, io;)[end][1]
        l7 = addLine(point6, point8r, Lines, io;)[end][1]
    else
        l7 = addLine(point7, point8, Lines, io;)[end][1]
        l8r = addLine(point8, point8r, Lines, io;)[end][1]
        l6r = addLine(point6, point8r, Lines, io;)[end][1]
        l8t = addLine(point8, Airfoil.points.trailing_edge[2], Lines, io;)[end][1]
    
        #l3ter = addLine(point4r, trailing_edge_point[2])
    end
    l7t = addLine(point7, Airfoil.points.trailing_edge[1], Lines, io)[end][1]
    
    #Add Refinement lines
    circr = addCirc(point2r, origin_idx, point1r, Lines, io)[end][1]
    l13r = addLine(point1r, point3r, Lines, io; tag="refinement")[end][1]
    l24r = addLine(point2r, point4r, Lines, io; tag="refinement")[end][1]
    l37r = addLine(point3r, point7r, Lines, io; tag="refinement")[end][1]
    l48r = addLine(point4r, point8r, Lines, io; tag="refinement")[end][1]
    
    
    l33r = addLine(point3, point3r, Lines, io)[end][1]
    l44r = addLine(point4, point4r, Lines, io)[end][1]
    

    loop1 = LoopfromPoints([point1, point1r, point2r, point2], Lines)
    loop1r = LoopfromPoints([point1r, Airfoil.points.leading_edge[1], Airfoil.points.leading_edge[2], point2r], Lines)
    
    loop2 = LoopfromPoints([point1, point3, point3r, point1r], Lines)
    loop2r = LoopfromPoints([point1r, point3r,  Airfoil.points.trailing_edge[1],     Airfoil.points.leading_edge[1]], Lines)
    
    loop3 = LoopfromPoints([point2, point4, point4r, point2r], Lines)
    loop3r = LoopfromPoints([point2r, point4r, Airfoil.points.trailing_edge[Airfoil.sharp_idx], Airfoil.points.leading_edge[2]], Lines)
    
    LinefromPoints(point8r, point6, Lines)
    
    loop4 = LoopfromPoints([point3, point5, point7r, point3r], Lines)
    loop4r = LoopfromPoints([point3r, point7r, point7, Airfoil.points.trailing_edge[1]], Lines)
    
    loop5 = LoopfromPoints([point4, point6, point8r, point4r], Lines)
    if is_sharp(Airfoil)
    
        loop5r = LoopfromPoints([point4r, point8r, point7, Airfoil.points.trailing_edge[Airfoil.sharp_idx]], Lines)
    
    else
        loop5r = LoopfromPoints([point4r, point8r, point8, Airfoil.points.trailing_edge[Airfoil.sharp_idx]],Lines)
    
    
    end
    
    loop1 = addLoop(loop1, Loops, io)[end][1]
    loop2 = addLoop(loop2, Loops, io)[end][1]
    loop3 = addLoop(loop3, Loops, io)[end][1]
    loop4 = addLoop(loop4, Loops, io)[end][1]
    loop5 = addLoop(loop5, Loops, io)[end][1]
    
    loop1r = addLoop(loop1r, Loops, io)[end][1]
    loop2r = addLoop(loop2r, Loops, io)[end][1]
    loop3r = addLoop(loop3r, Loops, io)[end][1]
    loop4r = addLoop(loop4r, Loops, io)[end][1]
    loop5r = addLoop(loop5r, Loops, io)[end][1]
    
    addPlaneSurface(loop1, Surfaces, io)
    addPlaneSurface(loop2, Surfaces, io)
    addPlaneSurface(loop3, Surfaces, io)
    addPlaneSurface(loop4, Surfaces, io)
    addPlaneSurface(loop5, Surfaces, io)
    
    addPlaneSurface(loop1r, Surfaces, io)
    addPlaneSurface(loop2r, Surfaces, io)
    addPlaneSurface(loop3r, Surfaces, io)
    addPlaneSurface(loop4r, Surfaces, io)
    addPlaneSurface(loop5r, Surfaces, io)
    
    if ! is_sharp(Airfoil)
        loop6 = LoopfromPoints([point7, point8, Airfoil.points.trailing_edge[2], Airfoil.points.trailing_edge[1]],Lines)
        loop6 = addLoop(loop6,Loops,io)[end][1]
        addPlaneSurface(loop6, Surfaces, io)
    end
    
    
    
    
    #Transfinite Curves
    
    #Leading Edge
    leading_edge_lines = [LinefromPoints(point1, point2, Lines), 
    LinefromPoints(point1r, point2r, Lines), 
    LinefromPoints(Airfoil.points.leading_edge[1], Airfoil.points.leading_edge[2], Lines)]
    TransfiniteCurve(leading_edge_lines, "N_inlet", 1.0, io)
    
    
    #Internal Lines
    internal_lines = -1 .* [LinefromPoints(point1, point1r, Lines),
        LinefromPoints(point3, point3r, Lines),
        LinefromPoints(point5, point7r, Lines),
        LinefromPoints(point6, point8r, Lines),
        LinefromPoints(point4, point4r, Lines),
        LinefromPoints(point2, point2r, Lines)]
    
    TransfiniteCurve(internal_lines, "N_vertical", "P_vertical",io)
    
    
    #Refinement
    if is_sharp(Airfoil)
        internal_lines = -1 .* [LinefromPoints(point1r,     Airfoil.points.leading_edge[1], Lines),
            LinefromPoints(point3r, Airfoil.points.trailing_edge[1], Lines),
            LinefromPoints(point7r, point7, Lines),
            LinefromPoints(point8r, point7, Lines),
            -1 .* LinefromPoints(Airfoil.points.trailing_edge[Airfoil.sharp_idx], point4r, Lines),
            LinefromPoints(point2r,     Airfoil.points.leading_edge[2], Lines)]
    else
        internal_lines = -1 .* [LinefromPoints(point1r,     Airfoil.points.leading_edge[1], Lines),
            LinefromPoints(point3r, Airfoil.points.trailing_edge[1], Lines),
            LinefromPoints(point7r, point7, Lines),
            LinefromPoints(point8r, point8, Lines),
            -1 .* LinefromPoints(Airfoil.points.trailing_edge[Airfoil.sharp_idx], point4r, Lines),
            LinefromPoints(point2r,     Airfoil.points.leading_edge[2], Lines)]
    end
    TransfiniteCurve(internal_lines, "N_refinement", "P_refinement", io)
    
    
    
    
    
    
    
    airfoil_lines = [LinefromPoints(point1, point3, Lines),
        LinefromPoints(point1r, point3r, Lines),
        LinefromPoints(Airfoil.points.trailing_edge[1], Airfoil.points.leading_edge[1], Lines),
        LinefromPoints(Airfoil.points.trailing_edge[Airfoil.sharp_idx], Airfoil.points.leading_edge[2], Lines),
        LinefromPoints(point2, point4, Lines),
        LinefromPoints(point2r, point4r, Lines)]
    TransfiniteCurve(airfoil_lines, "N_airfoil", 1.0, io)
    
    if is_sharp(Airfoil)
        shear_lines = [LinefromPoints(point3, point5, Lines),
            LinefromPoints(point3r, point7r, Lines),
            LinefromPoints(Airfoil.points.trailing_edge[1], point7, Lines),
            LinefromPoints(point4r, point8r, Lines),
            LinefromPoints(point4, point6, Lines)]
    else
        shear_lines = [LinefromPoints(point3, point5, Lines),
            LinefromPoints(point3r, point7r, Lines),
            LinefromPoints(Airfoil.points.trailing_edge[1], point7, Lines),
            LinefromPoints(Airfoil.points.trailing_edge[2], point8, Lines),
            LinefromPoints(point4r, point8r, Lines),
            LinefromPoints(point4, point6, Lines)]
    
        trailing_edge_lines = [LinefromPoints(Airfoil.points.trailing_edge[1], Airfoil.points.trailing_edge[2], Lines), LinefromPoints(point7, point8, Lines)]
    
        # N_edge = compute_non_sharp_divisions(h0, Airfoil.points.trailing_edge)
        println("N edge division = $N_edge")
        TransfiniteCurve(trailing_edge_lines, "N_edge", 1.0, io)
    
    
    end
    
    TransfiniteCurve(shear_lines, "N_shear", "P_shear",io)
    
    #Recombine and transfinite surfaces
    if ! is_sharp(Airfoil)
        TransfiniteSurfaces([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],io)
        RecombineSurfaces([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], recombine,io)
        #addPhysicalGroup("fluid", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "Surface")
    
    else
        TransfiniteSurfaces([1, 2, 3, 4, 5, 6, 7, 8, 9, 10],io)
        RecombineSurfaces([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], recombine,io)
        #addPhysicalGroup("fluid", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "Surface")
    
    end
    
    if dimension == 2
        #Recombine and transfinite surfaces
        if !is_sharp(Airfoil)
            addPhysicalGroup("fluid", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "Surface", PhysicalGroups, io)
        
        else
            addPhysicalGroup("fluid", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "Surface", PhysicalGroups, io)
    
        end
    #Add Physical Curve
    addPhysicalGroup("airfoil", [spline_airfoil_top, spline_airfoil_bottom, spline_airfoil_le], "Curve",PhysicalGroups, io)
    
    
    addPhysicalGroup("inlet", [circ], "Curve",PhysicalGroups, io)
    
    addPhysicalGroup("outlet", [LinefromPoints(point5, point7r, Lines), LinefromPoints(point7r, point7, Lines), LinefromPoints(point6, point8r, Lines)], "Curve", PhysicalGroups, io)
    
    addPhysicalGroup("limits", [LinefromPoints(point1, point3, Lines), LinefromPoints(point2, point4, Lines), LinefromPoints(point3, point5, Lines), LinefromPoints(point4, point6, Lines)], "Curve", PhysicalGroups, io)
    
    
    addPhysicalGroup("airfoil", [Airfoil.points.leading_edge[1], Airfoil.points.leading_edge[2], Airfoil.points.trailing_edge[1]], "Point", PhysicalGroups, io)
    
    addPhysicalGroup("limits", [point1, point2, point3, point4, point5, point6], "Point", PhysicalGroups, io)
    
    addPhysicalGroup("outlet", [point7, point7r, point8r], "Point", PhysicalGroups, io)
    

    if ! is_sharp(Airfoil)
        addPhysicalGroup("airfoil", [spline_airfoil_te], "Curve", PhysicalGroups, io; add=true)
        addPhysicalGroup("outlet", [LinefromPoints(point7, point8, Lines), LinefromPoints(point8, point8r, Lines)], "Curve", PhysicalGroups, io; add=true)
    
        addPhysicalGroup("airfoil", [Airfoil.points.trailing_edge[2]], "Point", PhysicalGroups, io; add=true)
        addPhysicalGroup("outlet", [point8], "Point", PhysicalGroups, io; add=true)
    else
        addPhysicalGroup("outlet", [LinefromPoints(point7, point8r, Lines)], "Curve", PhysicalGroups, io; add=true)
    
    end
    
    elseif dimension == 3
        #Extrude the z0 layer
    N_surf = length(Surfaces)
    if recombine
        extr_vol = "Extrude {0, 0, Hz} {
            Surface{1:$(N_surf)}; Layers {Nz}; Recombine; 
    }\n"
    else
        extr_vol = "Extrude {0, 0, Hz} {
        Surface{1:$(N_surf)}; Layers {Nz}; 
    }\n"
    
    
    end
    extr_vol = extr_vol * "Physical Volume(\"fluid\", 100) = {1:$N_surf}; \n Physical Surface(\"zm\", 101) = {1:$N_surf}; \n"
    
    write(io, extr_vol)
    
    
    map_entities(Airfoil, PhysicalGroups, io)
    
    end
    
    
    
    
    
    close(io)
    
return io    
 end


