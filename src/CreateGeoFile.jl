using Revise
using AirfoilGmsh
using DataFrames
using CSV



# function main_create_geofile(filename; Reynolds = -1, h0 = -1, leading_edge_points = [], trailing_edge_point =[], chord=1, dimension=2, elements = :QUAD)

filename = "c141a.csv"
Reynolds = -1
h0 = -1
leading_edge_points = Int64[]
trailing_edge_points = Int64[]
chord=1.0
dimension=2
elements = :QUAD

    # h0 first boundary layer cell height
    
    
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
    

Airfoil.points.leading_edge[1]
Airfoil.points.trailing_edge[1]
Airfoil.sharp_end

    # Create airfoil lines
    
    spline_airfoil_top = addSpline(Airfoil.points.trailing_edge[1] : Airfoil.points.leading_edge[1], Lines, io)
    spline_airfoil_le = addSpline(Airfoil.points.leading_edge[1] : Airfoil.points.leading_edge[2], Lines, io)
    spline_airfoil_bottom = addSpline(Airfoil.points.leading_edge[2] : Airfoil.points.trailing_edge[Airfoil.sharp_idx] , Lines, io)
    
    if ! is_sharp(Airfoil)
        spline_airfoil_te = addLine(Airfoil.points.trailing_edge[1], Airfoil.points.trailing_edge[2], Lines, io)
    end
    

    
    #External Domain points
    point1 = addPoint(0, "C", 0)[end][1]
    point2 = addPoint(0, "-C", 0)[end][1]
    
    point5 = addPoint("L", "C", 0)[end][1]
    point6 = addPoint("L", "-C", 0)[end][1]
    
    point3 = addPoint(chord, "C", 0)[end][1]
    point4 = addPoint(chord, "-C", 0)[end][1]
    
    #Trailing edge point at the rear part
    #This allows the shear to rotate as the AoA impose it
    x_tmp, y_tmp = Points[trailing_edge_point[1]][2:3]
    point7 = addPoint("L", "-L* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*L*Cos(AoA)", 0)[end][1]
    
    
    
    
    if !sharp_end
        x_tmp, y_tmp = Points[trailing_edge_point[2]][2:3]
        point8 = addPoint("L", "-L* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*L*Cos(AoA)", 0)[end][1]
    end
    
    
    origin_idx = addPoint(0, 0, 0)[end][1]
    println("new origin point")
    
    #add Refinement points
    
    
    point1r = addPoint(" Refinement_offset*Sin(AoA)", " Refinement_offset*Cos(AoA)", 0)[end][1]
    point2r = addPoint(" - Refinement_offset*Sin(AoA)", " - Refinement_offset*Cos(AoA)", 0)[end][1]
    
    
    x_tmp, y_tmp = Points[trailing_edge_point[1]][2:3]
    point3r = addPoint("$chord*Cos(AoA)", "-$chord* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*$chord*Cos(AoA) + Refinement_offset", 0)[end][1]
    point7r = addPoint("L", "-L* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*L*Cos(AoA)+ Refinement_offset", 0)[end][1]
    
    if !sharp_end
        x_tmp, y_tmp = Points[trailing_edge_point[2]][2:3]
    end
    
    point8r = addPoint("L", "-L* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*L*Cos(AoA) - Refinement_offset", 0)[end][1]
    point4r = addPoint("$chord*Cos(AoA)", "-$chord* " * string(x_tmp) * "*Sin(AoA) + " * string(y_tmp) * "*$chord*Cos(AoA) - Refinement_offset", 0)[end][1]
    
    
    
    
    
    
    circ = addCirc(point2, origin_idx, point1)[end][1]
    
    
    l1 = addLine(point1, point3)
    l2 = addLine(point2, point4)
    l3 = addLine(point3, point5)
    l3t = addLine(point3r, trailing_edge_point[1])
    
    l2t = addLine(point4r, trailing_edge_point[idx_sharp])
    
    l4 = addLine(point4, point6)
    l1l = addLine(point1, point1r)
    l1lr = addLine(point1r, leading_edge_points[1])
    
    l2l = addLine(point2, point2r)
    l2lr = addLine(point2r, leading_edge_points[2])
    
    
    l5 = addLine(point5, point7r)
    l5r = addLine(point7r, point7)
    
    if sharp_end
        l7 = addLine(point7, point8r)
        l7 = addLine(point6, point8r)
    else
        l7 = addLine(point7, point8)
        l8r = addLine(point8, point8r)
        l6r = addLine(point6, point8r)
        l8t = addLine(point8, trailing_edge_point[2])
    
        #l3ter = addLine(point4r, trailing_edge_point[2])
    end
    l7t = addLine(point7, trailing_edge_point[1])
    
    #Add Refinement lines
    circr = addCirc(point2r, origin_idx, point1r)[end][1]
    l13r = addLine(point1r, point3r)
    l24r = addLine(point2r, point4r)
    l37r = addLine(point3r, point7r)
    l48r = addLine(point4r, point8r)
    
    
    l33r = addLine(point3, point3r)
    l44r = addLine(point4, point4r)
    
    
    
    loop1 = LoopfromPoints([point1, point1r, point2r, point2])
    loop1r = LoopfromPoints([point1r, leading_edge_points[1], leading_edge_points[2], point2r])
    
    loop2 = LoopfromPoints([point1, point3, point3r, point1r])
    loop2r = LoopfromPoints([point1r, point3r, trailing_edge_point[1], leading_edge_points[1]])
    
    loop3 = LoopfromPoints([point2, point4, point4r, point2r])
    loop3r = LoopfromPoints([point2r, point4r, trailing_edge_point[idx_sharp], leading_edge_points[2]])
    
    LinefromPoints(point8r, point6)
    
    loop4 = LoopfromPoints([point3, point5, point7r, point3r])
    loop4r = LoopfromPoints([point3r, point7r, point7, trailing_edge_point[1]])
    
    loop5 = LoopfromPoints([point4, point6, point8r, point4r])
    if sharp_end
    
        loop5r = LoopfromPoints([point4r, point8r, point7, trailing_edge_point[idx_sharp]])
    
    else
        loop5r = LoopfromPoints([point4r, point8r, point8, trailing_edge_point[idx_sharp]])
    
    
    end
    
    loop1 = addLoop(loop1)[end][1]
    loop2 = addLoop(loop2)[end][1]
    loop3 = addLoop(loop3)[end][1]
    loop4 = addLoop(loop4)[end][1]
    loop5 = addLoop(loop5)[end][1]
    
    loop1r = addLoop(loop1r)[end][1]
    loop2r = addLoop(loop2r)[end][1]
    loop3r = addLoop(loop3r)[end][1]
    loop4r = addLoop(loop4r)[end][1]
    loop5r = addLoop(loop5r)[end][1]
    
    addPlaneSurface(loop1)
    addPlaneSurface(loop2)
    addPlaneSurface(loop3)
    addPlaneSurface(loop4)
    addPlaneSurface(loop5)
    
    addPlaneSurface(loop1r)
    addPlaneSurface(loop2r)
    addPlaneSurface(loop3r)
    addPlaneSurface(loop4r)
    addPlaneSurface(loop5r)
    
    if !sharp_end
        loop6 = LoopfromPoints([point7, point8, trailing_edge_point[2], trailing_edge_point[1]])
        loop6 = addLoop(loop6)[end][1]
        addPlaneSurface(loop6)
    end
    
    
    
    
    
    
    
    #Transfinite Curves
    
    #Leading Edge
    leading_edge_lines = [LinefromPoints(point1, point2), LinefromPoints(point1r, point2r), LinefromPoints(leading_edge_points[1], leading_edge_points[2])]
    TransfiniteCurve(leading_edge_lines, "N_inlet", 1.0)
    
    
    #Internal Lines
    internal_lines = -1 .* [LinefromPoints(point1, point1r),
        LinefromPoints(point3, point3r),
        LinefromPoints(point5, point7r),
        LinefromPoints(point6, point8r),
        LinefromPoints(point4, point4r),
        LinefromPoints(point2, point2r)]
    
    TransfiniteCurve(internal_lines, "N_vertical", "P_vertical")
    
    
    #Refinement
    if sharp_end
        internal_lines = -1 .* [LinefromPoints(point1r, leading_edge_points[1]),
            LinefromPoints(point3r, trailing_edge_point[1]),
            LinefromPoints(point7r, point7),
            LinefromPoints(point8r, point7),
            -1 .* LinefromPoints(trailing_edge_point[idx_sharp], point4r),
            LinefromPoints(point2r, leading_edge_points[2])]
    else
        internal_lines = -1 .* [LinefromPoints(point1r, leading_edge_points[1]),
            LinefromPoints(point3r, trailing_edge_point[1]),
            LinefromPoints(point7r, point7),
            LinefromPoints(point8r, point8),
            -1 .* LinefromPoints(trailing_edge_point[idx_sharp], point4r),
            LinefromPoints(point2r, leading_edge_points[2])]
    end
    TransfiniteCurve(internal_lines, "N_refinement", "P_refinement")
    
    
    
    
    
    
    
    airfoil_lines = [LinefromPoints(point1, point3),
        LinefromPoints(point1r, point3r),
        LinefromPoints(trailing_edge_point[1], leading_edge_points[1]),
        LinefromPoints(trailing_edge_point[idx_sharp], leading_edge_points[2]),
        LinefromPoints(point2, point4),
        LinefromPoints(point2r, point4r)]
    TransfiniteCurve(airfoil_lines, "N_airfoil", 1.0)
    
    if sharp_end
        shear_lines = [LinefromPoints(point3, point5),
            LinefromPoints(point3r, point7r),
            LinefromPoints(trailing_edge_point[1], point7),
            LinefromPoints(point4r, point8r),
            LinefromPoints(point4, point6)]
    else
        shear_lines = [LinefromPoints(point3, point5),
            LinefromPoints(point3r, point7r),
            LinefromPoints(trailing_edge_point[1], point7),
            LinefromPoints(trailing_edge_point[2], point8),
            LinefromPoints(point4r, point8r),
            LinefromPoints(point4, point6)]
    
        trailing_edge_lines = [LinefromPoints(trailing_edge_point[1], trailing_edge_point[2]), LinefromPoints(point7, point8)]
    
        N_edge = compute_non_sharp_divisions(h0, trailing_edge_point)
        println("N edge division = $N_edge")
        TransfiniteCurve(trailing_edge_lines, N_edge, 1.0)
    
    
    end
    
    TransfiniteCurve(shear_lines, "N_shear", "P_shear")
    
    #Recombine and transfinite surfaces
    if !sharp_end
        TransfiniteSurfaces([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        RecombineSurfaces([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], recombine)
        #addPhysicalGroup("fluid", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "Surface")
    
    else
        TransfiniteSurfaces([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        RecombineSurfaces([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], recombine)
        #addPhysicalGroup("fluid", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "Surface")
    
    end
    
    if dimension == 2
        #Recombine and transfinite surfaces
    if !sharp_end
       addPhysicalGroup("fluid", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "Surface")
    
    else
        addPhysicalGroup("fluid", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], "Surface")
    
    end
    #Add Physical Curve
    addPhysicalGroup("airfoil", [spline_airfoil_top, spline_airfoil_bottom, spline_airfoil_le], "Curve")
    
    
    addPhysicalGroup("inlet", [circ], "Curve")
    
    addPhysicalGroup("outlet", [LinefromPoints(point5, point7r), LinefromPoints(point7r, point7), LinefromPoints(point6, point8r)], "Curve")
    
    addPhysicalGroup("limits", [LinefromPoints(point1, point3), LinefromPoints(point2, point4), LinefromPoints(point3, point5), LinefromPoints(point4, point6)], "Curve")
    
    
    addPhysicalGroup("airfoil", [leading_edge_points[1], leading_edge_points[2], trailing_edge_point[1]], "Point")
    
    addPhysicalGroup("limits", [point1, point2, point3, point4, point5, point6], "Point")
    
    addPhysicalGroup("outlet", [point7, point7r, point8r], "Point")
    
    
    if !sharp_end
        addPhysicalGroup("airfoil", [line_airfoil_te], "Curve"; add=true)
        addPhysicalGroup("outlet", [LinefromPoints(point7, point8), LinefromPoints(point8, point8r)], "Curve"; add=true)
    
        addPhysicalGroup("airfoil", [trailing_edge_point[2]], "Point"; add=true)
        addPhysicalGroup("outlet", [point8], "Point"; add=true)
    else
        addPhysicalGroup("outlet", [LinefromPoints(point7, point8r)], "Curve"; add=true)
    
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
    
    
    map_entities(N_airfoil_points, sharp_end)
    
    end
    
    
    
    
    
    close(io)
    
    
    # end


