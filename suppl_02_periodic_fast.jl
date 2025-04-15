using HighVoronoi

dim = 5
scalefactor = 4 # how often do I want to repeat the data in each direction, it fill be fitted into the unit cube.
VG2 = VoronoiGeometry( VoronoiNodes(rand(dim,2),periodic_grid=(periodic=[], dimensions=ones(Float64,dim), scale=scalefactor^(-1)*ones(Float64,dim), repeat=scalefactor*ones(Int64,dim), fast=true), integrator=HighVoronoi.VI_GEOMETRY))
