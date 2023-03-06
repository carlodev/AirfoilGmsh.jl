# Package usage

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
