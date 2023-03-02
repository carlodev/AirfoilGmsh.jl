
"""
    from_url_to_csv(url::String)

Provide an url from arifoiltools.com and it writes a formatted CSV.
"""
function from_url_to_csv(url::String)
    #Read From the website
    @chain url begin
        Downloads.download(IOBuffer())
        s = String(take!(_))
    end

    #Splitting rows
    s = split(s, "\r\n")
    
    coordinates = Float64[]
    empty_line = -1 #to identify if there is an empty line that distinguish the top from the bottom

    for  file_line=1:1:length(s)
        coordinates 
        empty_line
    
        coordinates_tmp = Float64[]
        
        a = split(s[file_line], " ")
    
        if length(a) > 2 #it can be a valid line
            val = 10
            for i = 1:1:length(a)
                if val < 0 #it means on the line a non valid value has been found
    
                elseif a[i] == "" # it is accettable 
    
                else
                    val = try
                        Base.parse(Float64, a[i])
                    catch
                        -10 #a char-type is found
                    end
    
                    if val > -10 && val <1.2
                        push!(coordinates_tmp, val)
                    else
                        val = -10 # a numeric value not-in-the-range
                    end
    
                end
            end
    
            if val > -10 #the line is good
                println(coordinates_tmp)
                if coordinates == Float64[] #first set of coordinates
                    coordinates = coordinates_tmp'
                    empty_line = file_line
                else
                    coordinates = vcat(coordinates, coordinates_tmp')
                end
            
                
            end
        elseif file_line>length(s)*0.2 && file_line<length(s)*0.9 #found an empty line in the middle
            empty_line = file_line - empty_line
        end
    
    end
    
    coordinates[end,:] == coordinates[empty_line,:]
    start_from_leading_edge = false
    first_equal = false
    last_equal = false
    
    if empty_line>length(s)*0.2
        if coordinates[empty_line+1,:] == coordinates[1,:]
            first_equal = true
            if coordinates[empty_line+1,:]  == [0.0, 0.0]
                start_from_leading_edge = true
            end
        end
    
        if coordinates[empty_line,:] == coordinates[end,:]
            last_equal = true
    
        end
     
    end
    
    #re-ordering the points
    if first_equal*last_equal*start_from_leading_edge
        coordinates= vcat(coordinates[empty_line:-1:1, :], coordinates[empty_line+2:1:end-1, :])
    elseif first_equal*start_from_leading_edge
        coordinates= vcat(coordinates[empty_line:-1:1, :], coordinates[empty_line+2:1:end, :])
    elseif last_equal
        coordinates= vcat(coordinates[1:end-1, :])
    end
    
    println("empty_line=$empty_line")
    z = zeros(length(coordinates[:,1]),1)
    coordinates = hcat(coordinates,z)
    df = DataFrame(coordinates, [:x, :y, :z])
    
    
    #find the name of the profile
    split_section = split(url[1:end-4], "/")
    profile_name = split_section[end]
    filename = "$profile_name.csv"

    #write csv file
    CSV.write(filename, df)
    return filename
end