function map_entities(N_airfoil_points, sharp_end)

    folder_files = "Maps3D"
    
    if sharp_end
        sheet = "Sharp"
    else
        sheet = "NonSharp"
    end
    
    periodicmap = DataFrame(XLSX.readtable(joinpath(folder_files,"Periodic_Surfaces.xlsx") , sheet))
    
    points_phyisical_map = DataFrame(XLSX.readtable(joinpath(folder_files, "PointsPhysical.xlsx") , sheet))
    lines_phyisical_map = DataFrame(XLSX.readtable(joinpath(folder_files, "LinesPhysical.xlsx") , sheet))
    surfaces_phyisical_map = DataFrame(XLSX.readtable(joinpath(folder_files, "SurfacesPhysical.xlsx") , sheet))
    
    
    points_phyisical = Vector[]
    for i = 1:1:size(points_phyisical_map)[1]
    
        points_tmp = Int[]
        a = split(points_phyisical_map.Points[i], ", ")
        for  j = 1:1:length(a)
            push!(points_tmp, Base.parse(Int, a[j])+ N_airfoil_points)
    
        end
        
        addPhysicalGroup(points_phyisical_map.Physical[i], points_tmp, "Point")
    
        push!(points_phyisical, points_tmp)
    
    end
    
    lines_phyisical_map
    
    lines_phyisical = Vector[]
    for i = 1:1:size(lines_phyisical_map)[1]
    
        lines_tmp = Int[]
        a = split(lines_phyisical_map.Lines[i], ", ")
        for j = 1:1:length(a)
            push!(lines_tmp, Base.parse(Int, a[j]))
    
        end
        addPhysicalGroup(lines_phyisical_map.Physical[i], lines_tmp, "Curve")
    
        push!(lines_phyisical, lines_tmp)
    
    end
    
    
    surfaces_phyisical = Vector[]
    for i = 1:1:size(surfaces_phyisical_map)[1]
    
       
        if typeof(surfaces_phyisical_map.Surfaces[i]) <: String
        a = split(surfaces_phyisical_map.Surfaces[i], ", ")
        surface_tmp = Int[]
        for j = 1:1:length(a)
            push!(surface_tmp, Base.parse(Int, a[j]))
    
        end
        
    else
            surface_tmp = [surfaces_phyisical_map.Surfaces[i]]
        end
        addPhysicalGroup(surfaces_phyisical_map.Physical[i], surface_tmp, "Surface")
    
        push!(surfaces_phyisical, surface_tmp)
    
    end
    
    
    
    
    
    for i = 1:1:size(periodicmap)[1]
        str_tmp = "Periodic Surface {$(periodicmap.To[i])} = {$(periodicmap.From[i])} Translate {0, 0, Hz};\n"
        write(io, str_tmp)
    end
    
    
    
    end