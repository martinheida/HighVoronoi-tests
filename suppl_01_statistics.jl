## gather statistics of table 1 \label{tab:neighbors}

using HighVoronoi

## first part: general
for dim in 2:7 
    println( HighVoronoi.VoronoiStatistics( dim, 10; periodic=2, geodata=false ) ) 
end

## second part: periodic
for dim in 2:7 
    println( HighVoronoi.VoronoiStatistics( dim, 10; periodic=2, geodata=false ) ) 
end