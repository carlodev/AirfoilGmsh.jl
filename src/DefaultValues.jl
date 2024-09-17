abstract type ElementShape end

# Define concrete types for specific shapes
struct QUAD <: ElementShape end
struct TRI <: ElementShape end
struct HEX <: ElementShape end
struct TETRA <: ElementShape end


mutable struct DomainDivision
    numdiv::Int64
    progression::Float64
end

### Domain Mesh Divisions Default Parameters
@with_kw mutable struct DomainMeshDivisions
    Inlet::DomainDivision= DomainDivision(30,1.0)
    Vertical::DomainDivision= DomainDivision(30,1.1)
    Shear::DomainDivision= DomainDivision(30,1.2)
    Airfoil_Top::DomainDivision= DomainDivision(200,1.0)
    Airfoil_Bottom::DomainDivision = DomainDivision(50,1.0)
    Edge::DomainDivision= DomainDivision(7,1.0)
    Nz::DomainDivision= DomainDivision(16,1.0)
end

### Domain Size Default Parameters
@with_kw mutable struct DomainInfo
    AoA::Float64 = 0.0
    chord::Float64 = 1.0
    C::Float64 = 6.0*chord
    L::Float64 = 6.0*chord
    H_offset::Float64=0.35*chord
    Hz::Float64=0.2
    dimension::Int64=3
    elements::ElementShape=QUAD()
end

### Boundary Layer Default Parameters
@with_kw mutable struct BoundaryLayer
    H_levels::Float64 = 0.35
    N_levels::Float64 = 80
    G::Real = 1.12
    Reynolds::Int64=1e6
    h0::Float64=1e-4
end

