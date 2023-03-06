# AirfoilGmsh



**Documentation**

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://carlodev.github.io/AirfoilGmsh.jl/)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://carlodev.github.io/AirfoilGmsh.jl/)
[![Build Status](https://github.com/carlodev/AirfoilGmsh.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/carlodev/AirfoilGmsh.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/carlodev/AirfoilGmsh.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/carlodev/AirfoilGmsh.jl)


The package is thought to automatize and optimize the procedure for creating structured airfoil meshes using Gmsh.
Features:

## version 0.1.2
- Create the 3D mesh with periodic boundaries on Z direction
- You can spacify the type of elements: TRI/TETRA or QUAD/HEX

## version 0.1.1
- Create a region close to the airfoil for creating a refinement close to the airfoil
- You can specify the Reynolds and, if you prefer, the height of the first layer, the software automatically 
looks for the best combination of number of layers (<150 in the refinement region) and growth ratio

## version 0.1.0
- Generate a csv file from the url from [airfoiltools](http://airfoiltools.com/) 
- Create a .geo file ready to be opened by Gmsh
- The mesh generated has also physical group: airfoil, inlet, outlet, limits
- The mesh is compatible with the FEM Gridap
- It allows to manage both sharp and non-sharp trailing edges
- AoA, geometry dimensions, number of nodes and progression can be modified in Gmsh

# Usage
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
Finally you can easily create the `.geo` file.

```julia
create_geofile(filename)
```
Please see the [Documentation](https://carlodev.github.io/AirfoilGmsh.jl/) for more detailed examples and description of the package features.
Finally, the `.geo` can be opened with [GMSH](https://gmsh.info/), an open source 3D finite element mesh generator.

Example of a 3D mesh for the profile `c141a`:

![3D mesh detail](https://github.com/carlodev/AirfoilGmsh.jl/tree/master/docs/src/assets/detail_c141a3D.png)

## Knwon issues
- In 3D case GMSH can have problems in re-creating the periodic mapping. It happens when the refinement is too high, lowering the `P_refinement` parameters can solve the problem (but keeping always >= 1)
- When using custom csv file is better to start from the top point of the leading edge in anti-clockwise sense
