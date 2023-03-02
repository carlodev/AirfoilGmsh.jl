
#G is the growth ratio

function yt(yh,G,N)
    yh * (1 - G^N)/(1 - G) 
        
    end
    
    #Extimation of boundary layer height
    function bl_height(Re; L=1)
        if Re<500e3
            δ99= 4.91*L/(Re^0.5)  
    
        else
            δ99= 0.38*L/(Re^0.2)    
    
        end
        return δ99
    
    end
    
    
    
    "Determine the number N of division is the refinement region, having h0 as a target for the hight of the first layer"
    
    function boundary_layer_characteristics(Re, H, h0)
        δ99 = bl_height(Re) #extimation of BL Height
        flag_h = false
        flag_δ = false
        G = 1.21 #First guess G
        N_levels = 0
        while flag_h == false|| flag_δ == false
            flag_h = false
            flag_δ = false
            
    
        if G>1.1
            G = G - 0.01
        else
            
            println("Can't find an appropriate growth ratio, reducing the inital height")
            println("h0 = $h0 m")
    
            h0 = h0 - 0.1*h0
        end
    
        if yt(h0,G,  25) < δ99
            flag_δ = true
        end
    
        res = Float64[]
        Nx = Float64[]
        
        for N = 30:1:150
            push!(Nx,N)
            h = yt(h0,G,N)
            push!(res,H-h)
        end
        
        abs_res = abs.(res)
        idx = findall(x -> x == minimum(abs_res), abs_res)
        
        N_guess = Nx[idx][1]
        H_guess = yt(h0,G,N_guess)
        
        if isapprox(H_guess, H; rtol = 0.01) && flag_δ == true
            N_levels = N_guess
            flag_h = true
        end
    
        end
    
    
    
        H_levels = yt(h0,G,N_levels)
    
        return H_levels, N_levels, G, h0
        
    end
    
    
    function refinement_parameters(Reynolds, h0, chord)
        if Reynolds < 0 && h0 < 0
            return 0.35, 100, 1.15, h0
        else
            H = 0.35*chord
            if h0 <0
                h0 = chord * sqrt(74) * Reynolds^(-13/14)
                println("Extimated h0 = $h0 m")
            end
                H_levels, N_levels, G = boundary_layer_characteristics(Reynolds, H, h0)[1:3]
    
            return H_levels, N_levels, G, h0
        end
    end
    
    
    function compute_non_sharp_divisions(h0, trailing_edge_point)
        # h0 first boundary layer cell height
        d = abs(Points[trailing_edge_point[1]][3] -Points[trailing_edge_point[2]][3] ) #vertical distance between the 2 trailing edge points
        n = d/h0 *0.2 + 3 #+3 to ensure is not zero
        n = Int(ceil(n))
        return n 
    end

