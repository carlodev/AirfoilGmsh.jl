using Parameters
mutable struct DomainDivision
    numdiv::Int64
    progression::Float64
end

@with_kw mutable struct DomainMeshDivisions
    Inlet::DomainDivision
    Vertical::DomainDivision
    Shear::DomainDivision
    Airfoil_Top::DomainDivision
    Airfoil_Bottom::DomainDivision
    Edge::DomainDivision
    Nz::DomainDivision
end

@with_kw mutable struct DomainSize
    AoA::Float64 = 0.0
    chord::Float64 = 1.0
    C::Float64 = 6.0*chord
    L::Float64 = 6.0*chord
    H_offset::Float64=0.35*chord
    Hz::Float64=0.2
    dimension::Int64=3
end

### DEFAULT VALUES FOR DIVISION AND SIZE

domain_size_default = DomainSize(chord=3.0)

inlet = DomainDivision(30,1.0)
vertical = DomainDivision(30,1.1)
shear = DomainDivision(30,1.2)
airfoil_top = DomainDivision(200,1.0)
airfoil_bottom = DomainDivision(50,1.0)
edge = DomainDivision(7,1.0)
nz = DomainDivision(16,1.0)

domain_mesh_divisions_default = DomainMeshDivisions(inlet, vertical, shear, airfoil_top, airfoil_bottom, edge, nz)







"""
    start_writing(Airfoil::AirfoilParams, dimension::Int64, chord::Float64, boundary_layer::BoundaryLayer)

It starts writing a new .geo file. It writes all the custom parameters that can be later modified when the file is opened in Gmsh.
"""
function start_writing(Airfoil::AirfoilParams, domain_size::DomainSize, domain_mesh_divisions::DomainMeshDivisions, boundary_layer::BoundaryLayer)
    @unpack H_levels,N_levels,G = boundary_layer
    @unpack AoA, chord, dimension,C,L, Hz  = domain_size


    io = open("$(Airfoil.name)_$(dimension)D.geo", "w")
    write(io, "SetFactory(\"OpenCASCADE\");\n")
    
    write(io, "N_inlet = DefineNumber[ $(domain_mesh_divisions.Inlet.numdiv), Name \"Parameters/N_inlet\" ];\n")
    write(io, "N_vertical = DefineNumber[ $(domain_mesh_divisions.Vertical.numdiv), Name \"Parameters/N_vertical\" ];\n")
    write(io, "P_vertical = DefineNumber[ $(domain_mesh_divisions.Vertical.progression), Name \"Parameters/P_vertical\" ];\n")
    
    write(io, "N_airfoil = DefineNumber[ $(domain_mesh_divisions.Airfoil_top.numdiv), Name \"Parameters/N_airfoil_top\" ];\n")
    write(io, "N_airfoil = DefineNumber[ $(domain_mesh_divisions.Airfoil_bottom.numdiv), Name \"Parameters/N_airfoil_bottom\" ];\n")

    write(io, "N_shear = DefineNumber[ $(domain_mesh_divisions.Shear.numdiv), Name \"Parameters/N_shear\" ];\n")
    write(io, "P_shear = DefineNumber[ $(domain_mesh_divisions.Shear.progression), Name \"Parameters/P_shear\" ];\n")
    write(io, "L = DefineNumber[ $(domain_mesh_divisions.L.numdiv), Name \"Parameters/L\" ];\n")
    write(io, "C = DefineNumber[ $(domain_mesh_divisions.C.numdiv), Name \"Parameters/C\" ];\n")
    
    write(io, "Hz = DefineNumber[ $(chord*Hz), Name \"Parameters/Hz\" ];\n")
    write(io, "Nz = DefineNumber[ $(domain_mesh_divisions.Nz.numdiv), Name \"Parameters/Nz\" ];\n")
    
    write(io, "Refinement_offset = DefineNumber[ $H_levels, Name \"Parameters/Refinement_offset\" ];\n")
    write(io, "N_refinement = DefineNumber[ $N_levels, Name \"Parameters/N_refinement\" ];\n")
    write(io, "P_refinement = DefineNumber[ $G, Name \"Parameters/P_refinement\" ];\n")

    write(io, "AoA_deg = DefineNumber[ $(AoA), Name \"Parameters/AoA\" ];\n")
    write(io, "AoA = AoA_deg*3.14159/180;\n")
    write(io, "a_dim = 2;\n")


        
    if !is_sharp(Airfoil) 
        write(io, "N_edge = DefineNumber[ $(domain_mesh_divisions.Edge.numdiv), Name \"Parameters/N_edge\" ];\n")
    end

return io
end



