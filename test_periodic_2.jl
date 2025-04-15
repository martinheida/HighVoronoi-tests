using ProfileView

function test_periodic_mesh(dim,nn,f=true,scalefactor=4)
    nodes = VoronoiNodes(round.(rand(dim,nn),digits=2))
    @ProfileView.profview VG2 = VoronoiGeometry( nodes, periodic_grid=(periodic=[], dimensions=ones(Float64,dim), scale=scalefactor^(-1)*ones(Float64,dim), repeat=scalefactor*ones(Int64,dim),fast=f), integrator=HighVoronoi.VI_GEOMETRY, silence=true)
end

cases = [3,4,5,6]
for c in cases
    @time test_periodic_mesh(5,2,false,k)
end
