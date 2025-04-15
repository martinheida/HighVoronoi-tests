using HighVoronoi
dim = 5
A = HighVoronoi.collect_statistics( rand(dim,2), dim, 2*ones(Int64,dim), 10*ones(Int64,dim),txt="resultsper$(dim)D-8000-new.txt")
