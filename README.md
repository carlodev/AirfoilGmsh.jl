# AirfoilGmsh



**Documentation**

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://carlodev.github.io/AirfoilGmsh.jl/)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://carlodev.github.io/AirfoilGmsh.jl/)
[![Build Status](https://github.com/carlodev/AirfoilGmsh.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/carlodev/AirfoilGmsh.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/carlodev/AirfoilGmsh.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/carlodev/AirfoilGmsh.jl)


The package is thought to automatize and optimize the procedure for creating structured airfoil meshes using Gmsh.
Features:

## version 0.1.2
- Create the 3D mesh with periodic boundaries on Z directionµ
- You can spacify the type of elements: TRI/TETRA or QUAD/HEX

## version 0.1.1
- Create a region close to the airfoil for creating a refinement close to the airfoil
- You can specify the Reynolds and, if you prefer, the height of the first layer, the software automatically 
looks for the best combination of number of layers (<150 in the refinement region) and growth ratio



## version 0.1.0
- Generate a csv file from the url from http://airfoiltools.com/
- Create a .geo file ready to be opened by Gmsh
- The mesh generated has also physical group: airfoil, inlet, outlet, limits
- The mesh is compatible with the FEM Gridap
- It allows to manage both sharp and non-sharp trailing edges
- AoA, geometry dimensions, number of nodes and progression can be modified in Gmsh