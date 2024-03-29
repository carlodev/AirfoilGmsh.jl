

"""
    ClassFunction(x::Vector{Float64},N1::Real,N2::Real)

Compute the class function
    ``C = \\phi^N1 \\cdot(1-\\phi)^N2``
"""
function ClassFunction(x::Vector{Float64},N1::Real,N2::Real)
    @assert N1>0
    @assert N2>0 

    C = zeros(length(x))

    for (i,xi) in enumerate(x)
        C[i] = xi^N1*((1-xi)^N2)
    end

    return C    
end


"""
    ShapeFunction(w::Vector,x::Array{Float64})

Compute the shape function

"""
function ShapeFunction(w::Vector,x::Array{Float64})
 
    # Shape function; using Bernstein Polynomials
    n = length(w)-1 # Order of Bernstein polynomials
    
    K = zeros(n+1)
    
    for i = 1:n+1
         K[i] = factorial(n)/(factorial(i-1)*(factorial((n)-(i-1))))
    end
    
    S = zeros(length(x))
    
    for (i,xi) in enumerate(x)
        for j = 1:n+1
            S[i] = S[i] + w[j]*K[j]*xi^(j-1)*((1-xi)^(n-(j-1)))
        end
    end

    return S

end
    
function compute_airfoil_y(w::Vector,x::Array{Float64},N1::Real,N2::Real,dz::Real)

        #Compute Class Function
        C = ClassFunction(x,N1,N2)

        #Compute Shape Function
        S = ShapeFunction(w,x)
        #  Calculate y output
        y = zeros(length(x))
        for (i,xi) in enumerate(x)
           y[i] = C[i]*S[i] + xi*dz;
        end
                
        return y
end


""" 
    CST_airfoil(wl::Vector,wu::Vector,dz::Real,N::Int64; N1 = 0.5, N2 = 1)

Create a set of airfoil coordinates using CST parametrization method 
  Input  : wl = CST weight of lower surface
           wu = CST weight of upper surface
           dz = trailing edge thickness
  Output : x,y = set of x,y coordinates of airfoil generated by CST

  N1 = 0.5 and N2 = 1 for airfoil shape
"""
function CST_airfoil(wl::Vector,wu::Vector,dz::Real,N::Int64; N1 = 0.5, N2 = 1)
#  Create x coordinate
x=ones(N+1)
y=zeros(N+1)

#Zeta is used to have a better refinement close to trailing and leading edge
zeta=zeros(N+1)
for i=1:N+1
    zeta[i]=2*pi/N*(i-1)
    x[i]=0.5*(cos(zeta[i])+1)
end

zerind = findall(isapprox.(x,0.0))[1] # Used to separate upper and lower surfaces

#Here is important to dectect the orientation
xu= x[1:zerind-1] # Lower surface x-coordinates
xl = x[zerind:end] # Upper surface x-coordinates

yl = compute_airfoil_y(wl,xl,N1,N2,-dz) # Call ClassShape function to determine lower surface y-coordinates
yu = compute_airfoil_y(wu,xu,N1,N2,dz)  # Call ClassShape function to determine upper surface y-coordinates

y = [yu;yl] # Combine upper and lower y coordinates

return x, y 
end




function CST_airfoil(wl::Vector,wu::Vector,dz::Real,xl::Vector, xu::Vector; N1 = 0.5, N2 = 1)

    yl = compute_airfoil_y(wl,xl,N1,N2,-dz) # Call ClassShape function to determine lower surface y-coordinates
    yu = compute_airfoil_y(wu,xu,N1,N2,dz)  # Call ClassShape function to determine upper surface y-coordinates
    
    y = [yu;yl] # Combine upper and lower y coordinates
    x = [xu;xl]

    return x, y 

end



