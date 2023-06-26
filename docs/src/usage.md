# Package usage

## Installation
The package has not been registered yet, so you can install the most recent release as:
```julia
using Pkg
Pkg.add(url="https://github.com/carlodev/AirfoilGmsh.jl")
```
It also necessary to install [GMSH](https://gmsh.info/), a free open source mesh generator. To get the most out of the package, it is suggested to add `gmsh` to `PATH` environment variable.

## Create .csv from [airfoiltools](http://airfoiltools.com/) 
The usage of the package is extremely simple.
The user can naviagate on aifoilttols.com and find the profile of interest and copy the url.
The function `from_url_to_csv` locally creates a `.csv` file.
```julia
using AirfoilGmsh
url = "https://m-selig.ae.illinois.edu/ads/coord/c141a.dat"
filename = from_url_to_csv(url)
```

It is possible to skip the previous step is you already have the `.csv` file.
The software tries to re-order the sequence of points in anti-clockwise order and starting from the top point at the trailing edge. If you experience any trouble, it is better to manually format you file of points following this order.

## Create .geo file
Finally you can easily create the `.geo` file.

```julia
create_geofile(filename)
```
It is possible specify different keywords argument, see the documentation function [`create_geofile`](@ref) for more detail.
Finally, the `.geo` can be opened with [GMSH](https://gmsh.info/), an open source 3D finite element mesh generator. From the gaphical interface in GMSH the user can modify:
- Domain dimensions
- Cells progression
- Angle of attack
- Refinement region
- Shear opening

## Use Class Shape Transformation
In case of airfoil defined by a non satisfactory number of points, or for increasing the mesh resolution, it is possible to use the CST (Class Shape Transformation).
Providing the airfoil file coordinates it exploits the CST method to provide the same airfoil but defined in more points. It solves a minimization problem internally, it can take a while (some minutes).
```julia
using Plots
x,y,wl,wu = increase_resolution_airfoil("e1098.csv",500)
x0,y0 = get_airfoil_coordinates_("e1098.csv")

scatter(x,y, markersize=2.5, label = "CST")
scatter!(x0,y0,markersize=2.5, markercolor= :red, label = "Original")
plot!(xlims =(0.0,1.0), ylims =(-0.2,0.65))
plot!(xlabel = "x", ylabel = "y")
```

