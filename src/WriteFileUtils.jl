"""
    start_writing(Airfoil::AirfoilParams, domain_size::DomainInfo, domain_mesh_divisions::DomainMeshDivisions, boundary_layer::BoundaryLayer)

It starts writing a new .geo file. It writes all the custom parameters that can be later modified when the file is opened in Gmsh.
"""
function start_writing(Airfoil::AirfoilParams, domain_info::DomainInfo, domain_mesh_divisions::DomainMeshDivisions, boundary_layer::BoundaryLayer)
    @unpack H_levels,N_levels,G = boundary_layer
    @unpack AoA, chord, dimension,C,L, Hz  = domain_info


    io = open("$(Airfoil.name)_$(dimension)D.geo", "w")
    write(io, "SetFactory(\"OpenCASCADE\");\n")
    
    write(io, "N_inlet = DefineNumber[ $(domain_mesh_divisions.Inlet.numdiv), Name \"Parameters/N_inlet\" ];\n")
    write(io, "N_vertical = DefineNumber[ $(domain_mesh_divisions.Vertical.numdiv), Name \"Parameters/N_vertical\" ];\n")
    write(io, "P_vertical = DefineNumber[ $(domain_mesh_divisions.Vertical.progression), Name \"Parameters/P_vertical\" ];\n")
    
    write(io, "N_airfoil_top = DefineNumber[ $(domain_mesh_divisions.Airfoil_Top.numdiv), Name \"Parameters/N_airfoil_top\" ];\n")
    write(io, "N_airfoil_bottom = DefineNumber[ $(domain_mesh_divisions.Airfoil_Bottom.numdiv), Name \"Parameters/N_airfoil_bottom\" ];\n")

    write(io, "N_shear = DefineNumber[ $(domain_mesh_divisions.Shear.numdiv), Name \"Parameters/N_shear\" ];\n")
    write(io, "P_shear = DefineNumber[ $(domain_mesh_divisions.Shear.progression), Name \"Parameters/P_shear\" ];\n")
    write(io, "L = DefineNumber[ $(L), Name \"Parameters/L\" ];\n")
    write(io, "C = DefineNumber[ $(C), Name \"Parameters/C\" ];\n")
    
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



