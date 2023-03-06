var documenterSearchIndex = {"docs":
[{"location":"usage/#Package-usage","page":"Usage","title":"Package usage","text":"","category":"section"},{"location":"usage/#Create-.csv-from-[airfoiltools](http://airfoiltools.com/)","page":"Usage","title":"Create .csv from airfoiltools","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"The usage of the package is extremely simple. The user can naviagate on aifoilttols.com and find the profile of interest and copy the url. The function from_url_to_csv locally creates a .csv file.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"using AirfoilGmsh\nurl = \"https://m-selig.ae.illinois.edu/ads/coord/c141a.dat\"\nfilename = from_url_to_csv(url)","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"It is possible to skip the previous step is you already have the .csv file. The software tries to re-order the sequence of points in anti-clockwise order and starting from the top point at the trailing edge. If you experience any trouble, it is better to manually format you file of points following this order.","category":"page"},{"location":"usage/#Create-.geo-file","page":"Usage","title":"Create .geo file","text":"","category":"section"},{"location":"usage/","page":"Usage","title":"Usage","text":"Finally you can easily create the .geo file.","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"create_geofile(filename)","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"It is possible specify different keywords argument, see the documentation function create_geofile for more detail. Finally, the .geo can be opened with GMSH, an open source 3D finite element mesh generator. From the gaphical interface in GMSH the user can modify:","category":"page"},{"location":"usage/","page":"Usage","title":"Usage","text":"Domain dimensions\nCells progression\nAngle of attack\nRefinement region\nShear opening","category":"page"},{"location":"gallery/#Index","page":"Gallery","title":"Index","text":"","category":"section"},{"location":"gallery/","page":"Gallery","title":"Gallery","text":"Graphical user interface of GMSH. For generating the 2D mesh just click on Mesh->2D, and for 3D mesh, Mesh->3D.","category":"page"},{"location":"gallery/","page":"Gallery","title":"Gallery","text":"(Image: Screenshot Gmsh)","category":"page"},{"location":"gallery/","page":"Gallery","title":"Gallery","text":"(Image: 3D mesh detail)","category":"page"},{"location":"gallery/","page":"Gallery","title":"Gallery","text":"(Image: sharp)","category":"page"},{"location":"gallery/","page":"Gallery","title":"Gallery","text":"(Image: non sharp)","category":"page"},{"location":"#AifoilGmsh.jl","page":"Introduction","title":"AifoilGmsh.jl","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"Documentation of AifoilGmsh.jl for speeding up the creation of airfoil in GMSH","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"create_geofile\nfrom_url_to_csv","category":"page"},{"location":"#AirfoilGmsh.create_geofile","page":"Introduction","title":"AirfoilGmsh.create_geofile","text":"create_geofile(filename::String; Reynolds = -1, h0 = -1, leading_edge_points = Int64[], trailing_edge_points = Int64[], chord=1.0, dimension=2, elements = :QUAD)\n\nIt is the main function of the package. From a csv file containing the airfoil points it creates a .geo file. The .geo file can be created using the function from_url_to_csv. The user can specify just the file name. ´´´julia     create_geofile(\"naca0012.csv\") ´´´ It is also possibile to provide extra arguments such as the Reynolds number and/or the first layer height for a better extimation of the boundary-cell properties. It is possible to overwrite the extimation of the trailing edge and leading edge made by the code providing the relative points numbers. The mesh can be created in 2D or 3D. In 3D case by default are created periodic boundary conditions in the z direction. It is possible to create a mesh with the following options:\n\n|Type of element | Dimension | Symbol | |Quadrilateral | 2D | :QUAD| |Hexaedral | 3D | :HEX| |Triangular | 2D | :TRI| |Thetraedreal | 3D | :TETRA|\n\n\n\n\n\n","category":"function"},{"location":"#AirfoilGmsh.from_url_to_csv","page":"Introduction","title":"AirfoilGmsh.from_url_to_csv","text":"from_url_to_csv(url::String)\n\nProvide an url from arifoiltools.com and it writes a formatted CSV.\n\n\n\n\n\n","category":"function"}]
}
