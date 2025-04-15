using Revise
using HighVoronoi
using StaticArrays
using LinearAlgebra
using Delaunay

const index_delaunay = 1
const index_unbounded = 2
const index_unbounded_nongeneral = 3
const index_bounded = 4
const index_bounded_combined = 5
const index_bounded_nongeneral = 6
const index_parallel_unbounded = 7
const index_parallel_unbounded_combined = 8
const index_parallel_bounded = 9 
const index_parallel_bounded_combined = 10
const index_parallel_bounded_nongeneral = 11
const index_max = 11

#number = 1000
const th_mode = SingleThread()

nodes_array  = [100, 500, 1000, 2500, 5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 50000]
repeat_array = [10 , 10 , 10  , 10  , 8   , 5    , 5    , 5    , 5    , 5    , 5    , 5    , 5    ]

function lift_data(number,dim,data)
    data2 = rand(number,dim+1)
    l = size(data)[1]
    data2[1:l,1:dim] .= data 
    for i in 1:l 
        data2[i,dim+1] = sum(abs2,data[i,:]) 
    end
    return data2
end

function run_tests(nodes_, dim, repeat, printall,_silence=true)
    cube = cuboid(dim, periodic=Int64[])
    t = 0.0
    for _ in 1:1
        silence=_silence
        data = rand(100,dim)
        xs = VoronoiNodes(data')
        t += @elapsed delaunay(data)#lift_data(100,dim,data))
        t += @elapsed VoronoiGeometry(xs, search_settings=_ss3 = (method=RCOriginal,threading=th_mode), integrate=false, silence=silence)
        t += @elapsed VoronoiGeometry(xs, search_settings=_ss3 = (method=RCNonGeneral,threading=th_mode), integrate=false, silence=silence)
        t += @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCOriginal,threading=th_mode), integrate=false, silence=silence)
        t += @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCNonGeneral,threading=th_mode), integrate=false, silence=silence)
        t += @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCCombined,threading=th_mode), integrate=false, silence=silence)
    end
    println("Ground time: $t")
    time_matrix = zeros(Float64, index_max, length(nodes_))
    cube = cuboid(dim, periodic=Int64[])
    for i in 1:length(nodes_)
        t = 0.0
        number = nodes_[i]
        silence = _silence || number<=1000
        t1 = t2 = t3 = t4 = t5 = t6 = 0.0
        count = 0
        for kk in 1:repeat[i]
            try
                t1 = t2 = t3 = t4 = t5 = t6 = 0.0
                data = rand(number,dim)
                xs = VoronoiNodes(data')
                #ldata = lift_data(number,dim,data)
                GC.gc()
                time_matrix[index_delaunay,i] += t1 = @elapsed delaunay(data)
                printall && println("delaunay: nodes=$number, repeat=$kk, time=$t1")
                GC.gc()
                time_matrix[index_unbounded,i] += t2 = @elapsed VoronoiGeometry(xs, search_settings=_ss3 = (method=RCOriginal,threading=th_mode), integrate=false, silence=silence)
                printall && println("unbounded: nodes=$number, repeat=$kk, time=$t2")
                GC.gc()
                time_matrix[index_unbounded_nongeneral,i] += t3 = @elapsed VoronoiGeometry(xs, search_settings=_ss3 = (method=RCNonGeneral,threading=th_mode), integrate=false, silence=silence)
                printall && println("unbounded_nongeneral: nodes=$number, repeat=$kk, time=$t3")
                GC.gc()
                time_matrix[index_bounded,i] += t4 = @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCOriginal,threading=th_mode), integrate=false, silence=silence)
                printall && println("bounded: nodes=$number, repeat=$kk, time=$t4")
                GC.gc()
                time_matrix[index_bounded_nongeneral,i] += t5 = @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCNonGeneral,threading=th_mode), integrate=false, silence=silence)
                printall && println("bounded_nongeneral: nodes=$number, repeat=$kk, time=$t5")
                GC.gc()
                time_matrix[index_bounded_combined,i] += t6 = @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCCombined,threading=th_mode), integrate=false, silence=silence)
                printall && println("bounded_combined: nodes=$number, repeat=$kk, time=$t6")
                printall && println("")
                count += 1
                println("total time: nodes=$number, repeat=$kk, time=$(t1+t2+t3+t4+t5+t6)")
                println()
            catch 
                println("crashed!")
                time_matrix[index_delaunay,i] -= t1 
                time_matrix[index_unbounded,i] -= t2 # @elapsed VoronoiGeometry(xs, search_settings=_ss3 = (method=RCOriginal,threading=th_mode), integrate=false, silence=true)
                time_matrix[index_unbounded_nongeneral,i] -= t3 # @elapsed VoronoiGeometry(xs, search_settings=_ss3 = (method=RCNonGeneral,threading=th_mode), integrate=false, silence=true)
                time_matrix[index_bounded,i] -= t4 # @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCOriginal,threading=th_mode), integrate=false, silence=true)
                time_matrix[index_bounded_nongeneral,i] -= t5 # @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCNonGeneral,threading=th_mode), integrate=false, silence=true)
                time_matrix[index_bounded_combined,i] -= t6 # @elapsed VoronoiGeometry(xs,cube, search_settings=_ss3 = (method=RCCombined,threading=th_mode), integrate=false, silence=true)
                t1 = t2 = t3 = t4 = t5 = t6 = 0.0
            end
        end
        count != 0 && (time_matrix[:,i] ./= count) 
    end
    file_name = "results-$(dim)D.txt"

    open(file_name, "w") do file
        write(file, "time_matrix:\n")
        println(file, time_matrix)
        write(file, "\nnodes_:\n")
        println(file, nodes_)
        write(file, "\nrepeat:\n")
        println(file, repeat)
    end
end

#run_tests(nodes_array[1:13], 2, repeat_array, false)
#run_tests(nodes_array[1:13], 3, repeat_array, false)
#run_tests(nodes_array[1:13], 4, repeat_array, true)
repeat_array = [6  , 6  , 6   , 6   , 5   , 3    , 4    , 4    , 4    , 4    , 4    , 4    , 4    ]
run_tests(nodes_array[1:6], 6, repeat_array, true,false)
error()

using JLD2

xs = VoronoiNodes(rand(5,40000))
#@save "xs-5D.jld2" xs
#@load "xs-5D.jld2" xs
#println(xs[1:10])
#error()
GC.gc()
cube = cuboid(5,periodic=Int64[])
VoronoiGeometry(xs,  search_settings= (method=RCNonGeneral,threading=th_mode), integrate=false, silence=false)
error()
GC.gc()
VoronoiGeometry(xs, cube, search_settings= (method=RCNonGeneralFast,threading=th_mode), integrate=false, silence=false)
println()
error()
#using ProfileView
GC.gc()
@profview VoronoiGeometry(xs, cube, search_settings= (method=RCNonGeneralHP,threading=th_mode), integrate=false, silence=false)
GC.gc()
@profview VoronoiGeometry(xs, cube, search_settings= (method=RCNonGeneralFast,threading=th_mode), integrate=false, silence=false)
#println()
#@profview VoronoiGeometry(xs, search_settings = (method=RCNonGeneral,threading=th_mode), integrate=false, silence=false)
