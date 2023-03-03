function map_entities(airfoil::AirfoilParams, PhysicalGroups::DataFrame, io::IOStream)
    
    N_airfoil_points = airfoil.points.num
    sharp_end = airfoil.sharp_end


    if sharp_end
        sheet = "Sharp"
    else
        sheet = "NonSharp"
    end
    
    periodicmap = get_map_periodic_surfaces(sharp_end)
    
    points_physical_map = get_map_points(sharp_end) 
    lines_physical_map = get_map_lines(sharp_end) 
    surfaces_physical_map = get_map_surfaces(sharp_end) 
    
    
    points_physical = Vector[]
    for i = 1:1:size(points_physical_map)[1]
    
        points_tmp = Int[]
        a = points_physical_map.Points[i]
        for  j = 1:1:length(a)
            push!(points_tmp, a[j]+ N_airfoil_points)
    
        end
        
        addPhysicalGroup(points_physical_map.Physical[i], points_tmp, "Point", PhysicalGroups, io)
    
        push!(points_physical, points_tmp)
    
    end
    
    lines_physical_map
    
    lines_physical = Vector[]
    for i = 1:1:size(lines_physical_map)[1]
    
        lines_tmp = Int[]
        a = lines_physical_map.Lines[i]
        for j = 1:1:length(a)
            push!(lines_tmp, a[j])
    
        end
        addPhysicalGroup(lines_physical_map.Physical[i], lines_tmp, "Curve", PhysicalGroups, io)
    
        push!(lines_physical, lines_tmp)
    
    end
    
    
    surfaces_physical = Vector[]
    for i = 1:1:size(surfaces_physical_map)[1]
    
       
        
            a = surfaces_physical_map.Surfaces[i]
            surface_tmp = Int[]
            for j = 1:1:length(a)
                push!(surface_tmp, a[j])
        
            end
        
        
        addPhysicalGroup(surfaces_physical_map.Physical[i], surface_tmp, "Surface", PhysicalGroups, io)
    
        push!(surfaces_physical, surface_tmp)
    
    end
    
    
    for i = 1:1:length(periodicmap.To[1])
        write(io, "Periodic Surface {$(periodicmap.To[1][i])} = {$(periodicmap.From[1][i])} Translate {0, 0, Hz};\n")
    end
    
    
end



function get_map_points(sharp_end::Bool)
if sharp_end
    v1 = 7, 13, 12,  26, 30, 24
    v2 = 2, 6, 4, 18, 21, 25, 1, 5, 3, 15, 19, 23
    v3 = 27, 28, 29

else
    v1 = 14, 7, 8, 13, 27, 25, 32, 33
    v2 = 2, 6, 4, 1, 5, 3, 19, 22, 26, 16, 20, 24
    v3 = 28, 29, 30, 31
end

    return DataFrame(Points =[v1, v2, v3], Physical=["outlet", "limits", "airfoil"])
end


function get_map_lines(sharp_end::Bool)
    if sharp_end
        v1 = 1, 2, 3, 58, 62, 64, 57, 55, 60
        v2 = 4, 34
        v3 = 27, 35, 45, 32, 40, 50, 5, 7, 36, 46, 41, 51
        v4 = 15, 16, 17, 18, 48, 66, 68, 53, 47, 52, 65
      

    
    else
        v1 = 1, 2, 3, 4, 60, 58, 66, 63, 61, 65, 68, 76
        v2= 5, 37
        v3= 6, 7, 8, 11, 30, 38, 48, 35, 43, 53, 44, 54, 39, 49
        v4= 16, 17, 18, 19, 20, 55, 72, 69, 50, 56, 73, 75, 70, 51

    end
    
        return DataFrame(Lines =[v1, v2, v3, v4], Physical=["airfoil", "inlet", "limits", "outlet"])
end


function get_map_surfaces(sharp_end::Bool)
    if sharp_end
        v1 =14
        v2 =29, 45, 42, 25
       v3 = 16, 24, 20, 28
       v4 = 33, 37, 40
       
      

    
    else
        v1 =15
        v2 = 30, 46, 43, 26, 49
        v3 = 21, 29, 17, 25
        v4 = 34, 41, 38, 50


    end
    
        return DataFrame(Surfaces =[v1, v2, v3, v4], Physical=["inlet", "outlet", "limits", "airfoil"])
end


function get_map_periodic_surfaces(sharp_end::Bool)
if sharp_end
    from = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    to = 15,    19,    23,27,31,35,38,41,44,46
    
else
    from = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11
    to = 16,    20,    24,    28,    32,    36,    39,    42,    45,    48,    51
    
end
return DataFrame(From =from, To=to)
end

sa = get_map_periodic_surfaces(false)
sa
for i = 1:1:length(sa.To[1])

    println(sa.To[1][i]) 
end

