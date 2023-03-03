function map_entities(airfoil::AirfoilParams, PhysicalGroups::DataFrame, io::IOStream)
    
    N_airfoil_points = airfoil.points.num
    sharp_end = airfoil.sharp_end

    folder_files = "src/Maps3D"

    if sharp_end
        sheet = "Sharp"
    else
        sheet = "NonSharp"
    end
    
    periodicmap = DataFrame(XLSX.readtable(joinpath(folder_files,"Periodic_Surfaces.xlsx") , sheet))
    
    points_physical_map = DataFrame(XLSX.readtable(joinpath(folder_files, "PointsPhysical.xlsx") , sheet))
    lines_physical_map = DataFrame(XLSX.readtable(joinpath(folder_files, "LinesPhysical.xlsx") , sheet))
    surfaces_physical_map = DataFrame(XLSX.readtable(joinpath(folder_files, "SurfacesPhysical.xlsx") , sheet))
    
    
    points_physical = Vector[]
    for i = 1:1:size(points_physical_map)[1]
    
        points_tmp = Int[]
        a = split(points_physical_map.Points[i], ", ")
        for  j = 1:1:length(a)
            push!(points_tmp, Base.parse(Int, a[j])+ N_airfoil_points)
    
        end
        
        addPhysicalGroup(points_physical_map.Physical[i], points_tmp, "Point", PhysicalGroups, io)
    
        push!(points_physical, points_tmp)
    
    end
    
    lines_physical_map
    
    lines_physical = Vector[]
    for i = 1:1:size(lines_physical_map)[1]
    
        lines_tmp = Int[]
        a = split(lines_physical_map.Lines[i], ", ")
        for j = 1:1:length(a)
            push!(lines_tmp, Base.parse(Int, a[j]))
    
        end
        addPhysicalGroup(lines_physical_map.Physical[i], lines_tmp, "Curve", PhysicalGroups, io)
    
        push!(lines_physical, lines_tmp)
    
    end
    
    
    surfaces_physical = Vector[]
    for i = 1:1:size(surfaces_physical_map)[1]
    
       
        if typeof(surfaces_physical_map.Surfaces[i]) <: String
        a = split(surfaces_physical_map.Surfaces[i], ", ")
        surface_tmp = Int[]
        for j = 1:1:length(a)
            push!(surface_tmp, Base.parse(Int, a[j]))
    
        end
        
    else
            surface_tmp = [surfaces_physical_map.Surfaces[i]]
        end
        addPhysicalGroup(surfaces_physical_map.Physical[i], surface_tmp, "Surface", PhysicalGroups, io)
    
        push!(surfaces_physical, surface_tmp)
    
    end
    
    
    for i = 1:1:size(periodicmap)[1]
        str_tmp = "Periodic Surface {$(periodicmap.To[i])} = {$(periodicmap.From[i])} Translate {0, 0, Hz};\n"
        write(io, str_tmp)
    end
    
    
    
    end