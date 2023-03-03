
"""
    yt(yh::Float64, G::Float64, N::Int)

It computes the total height covered by boundary layer cells. yh is the height of the first cell, G the growth ratio and N the total number of levels.
"""
function yt(yh::Float64, G::Float64, N::Int)
    yh * (1 - G^N) / (1 - G)

end

"""
    bl_height(Re::Real, L::Float64)

It provides an extimation of the total thickness of the boundary layer form physical characteristics.
```Re<500.000  δ99 = 4.91 * L / (Re^0.5)´´´
```Re>500.000  δ99 = 0.38 * L / (Re^0.2)´´´
"""
function bl_height(Re::Real, L::Float64)
    if Re < 500e3
        δ99 = 4.91 * L / (Re^0.5)

    else
        δ99 = 0.38 * L / (Re^0.2)

    end
    return δ99

end



"""
    boundary_layer_characteristics(Re::Real, H::Real, h0::Real)

Determine the number N of division is the refinement region. h0 is the target for the height of the first layer.
The growth ration G is set to be betweeen 1.1 and 1.21. It extimated the total height of the boundary layer and ensures that there are at least 25 cells.
It starts with a guess of G = 1.21, validate the condition of having at least 25 layers in the boundary layer. Then find the total amount of layers to cover the refinement region.
If conditions are not met, the G value is gradually reduced. If it cannot find a suitable G value, it reduce the guess of the first layer height.
"""
function boundary_layer_characteristics(Re::Real, H::Real, h0::Real, chord::Float64)
    δ99 = bl_height(Re, chord) #extimation of BL Height
    flag_h = false
    flag_δ = false
    G = 1.21 #First guess G
    N_levels = 0
    while flag_h == false || flag_δ == false
        flag_h = false
        flag_δ = false


        if G > 1.1
            G = G - 0.01
        else

            println("Can't find an appropriate growth ratio, reducing the inital height")
            println("h0 = $h0 m")

            h0 = h0 - 0.1 * h0
        end

        if yt(h0, G, 25) < δ99
            flag_δ = true
        end

        res = Float64[]
        Nx = Float64[]

        for N = 30:1:150
            push!(Nx, N)
            h = yt(h0, G, N)
            push!(res, H - h)
        end

        abs_res = abs.(res)
        idx = findall(x -> x == minimum(abs_res), abs_res)

        N_guess = Nx[idx][1]
        H_guess = yt(h0, G, N_guess)

        if isapprox(H_guess, H; rtol=0.01) && flag_δ == true
            N_levels = N_guess
            flag_h = true
        end

    end
    H_levels = yt(h0, G, N_levels)

    return H_levels, N_levels, G, h0

end


function refinement_parameters(Reynolds::Real, h0::Real, chord::Real)
    if Reynolds < 0 && h0 < 0 #If no reynolds or height specified
        return 0.35, 100, 1.15, h0
    else
        H = 0.35 * chord
        if h0 < 0
            h0 = chord * sqrt(74) * Reynolds^(-13 / 14)
            println("Extimated h0 = $h0 m")
        end
        H_levels, N_levels, G = boundary_layer_characteristics(Reynolds, H, h0, chord)[1:3]

        return H_levels, N_levels, G, h0
    end
end
