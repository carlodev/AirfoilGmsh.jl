using GridapGmsh
using Gridap
using AirfoilGmsh

url = "https://m-selig.ae.illinois.edu/ads/coord/n0012.dat"
filename = from_url_to_csv(url)

create_geofile(filename; Reynolds=200e3)
create_geofile(filename; Reynolds=200e3, dimension= 3)

model = GmshDiscreteModel("n0009sm_3D.msh")
model = GmshDiscreteModel("e1098_3D.msh")
writevtk(model, "Mesh3d")
