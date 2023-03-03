#Default Values
const N_inlet = 30
const N_vertical = 30
const P_vertical = 1.1

const N_airfoil = 50
const N_shear = 30
const P_shear = 1.2
const L_domain = 6
const C_domain = 6

const Hz_coeff = 0.2
const Nz_default = 22

const N_edge = 7 #minimum value, it will be overwritten



"""
    start_writing(Airfoil::AirfoilParams, dimension::Int64, chord::Float64, refinement_params::Tuple)

It starts writing a new .geo file. It writes all the custom parameters that can be later modified when the file is opened in Gmsh.
"""
function start_writing(Airfoil::AirfoilParams, dimension::Int64, chord::Float64, refinement_params::Tuple)
    Refinement_offset, N_refinement, P_refinement, h0 = refinement_params

    io = open("$(Airfoil.name)_$(dimension)D.geo", "w")
    write(io, "SetFactory(\"OpenCASCADE\");\n")
    
    write(io, "N_inlet = DefineNumber[ $(N_inlet), Name \"Parameters/N_inlet\" ];\n")
    write(io, "N_vertical = DefineNumber[ $(N_vertical), Name \"Parameters/N_vertical\" ];\n")
    write(io, "P_vertical = DefineNumber[ $(P_vertical), Name \"Parameters/P_vertical\" ];\n")
    
    write(io, "N_airfoil = DefineNumber[ $(N_airfoil), Name \"Parameters/N_airfoil\" ];\n")
    
    write(io, "N_shear = DefineNumber[ $(N_shear), Name \"Parameters/N_shear\" ];\n")
    write(io, "P_shear = DefineNumber[ $(P_shear), Name \"Parameters/P_shear\" ];\n")
    write(io, "L = DefineNumber[ $(L_domain), Name \"Parameters/L\" ];\n")
    write(io, "C = DefineNumber[ $(C_domain), Name \"Parameters/C\" ];\n")
    
    write(io, "Hz = DefineNumber[ $(chord*Hz_coeff), Name \"Parameters/Hz\" ];\n")
    write(io, "Nz = DefineNumber[ $(Nz_default), Name \"Parameters/Nz\" ];\n")
    
    write(io, "Refinement_offset = DefineNumber[ $Refinement_offset, Name \"Parameters/Refinement_offset\" ];\n")
    write(io, "N_refinement = DefineNumber[ $N_refinement, Name \"Parameters/N_refinement\" ];\n")
    write(io, "P_refinement = DefineNumber[ $P_refinement, Name \"Parameters/P_refinement\" ];\n")

    write(io, "AoA_deg = DefineNumber[ 0, Name \"Parameters/AoA\" ];\n")
    write(io, "AoA = AoA_deg*3.14159/180;\n")
    write(io, "a_dim = 0.2;\n")


        
    if !is_sharp(Airfoil) 
        write(io, "N_edge = DefineNumber[ $N_edge, Name \"Parameters/N_edge\" ];\n")
    end

return io
end



