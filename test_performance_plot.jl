using Plots
using SpecialFunctions
using DataFitting

# Definiere das Modell f(x, p1, p2, p3) = p1 + p2*x + p3*x*log(x)
f(x, p1, p2, p3) = @. (p1 + p2 * x + p3 * x * log(x))

# Funktion, die die Daten als Scatter plottet und mittels DataFitting anpasst
function plot_data_dfit!(plt, nodes, y_data; marker=:circle, color=:blue, label_scatter="Daten", label_fit="Fit")
    # Scatter: Originaldaten plotten
    scatter!(plt, nodes, y_data, marker=marker, color=color, label=label_scatter)
    
    # Erzeuge Domain und Messwerte (hier: Einheitliche Unsicherheit 1.0)
    dom = Domain(nodes)
    data = Measures(y_data, 1.0)
    
    # Initiale Schätzung der Parameter
    params = [1.0, 1.0, 1.0]
    
    # Erstelle das Modell mit FuncWrap (DataFitting erwartet einen Wrapper)
    model1 = Model(:comp1 => FuncWrap(f, params...))
    prepare!(model1, dom, :comp1)
    
    # Führe das Fit durch
    result1 = fit!(model1, data)
    
    # Extrahiere die angepassten Parameter
    my_p1 = result1.param[:comp1__p1].val
    my_p2 = result1.param[:comp1__p2].val
    my_p3 = result1.param[:comp1__p3].val
    
    # Definiere die angepasste Funktion
    fitted_f(x) = my_p1 + my_p2 * x + my_p3 * x * log(x)
    
    # Rundungsfunktion für die Label-Anzeige
    oRound(x) = round(x, digits = 3 - floor(Int, log10(abs(x))))
    
    # Plotten der angepassten Funktion: Wir verwenden hier einen Funktionsplot
    plot!(plt, x -> fitted_f(x), color=color,
          label = nothing)
    
    # Optional: Berechnung des relativen Gesamtfehlers (ab Index 1, kann angepasst werden)
    total_error = sum(map(i -> ((y_data[i] - fitted_f(nodes[i])) / y_data[i])^2, 1:length(nodes)))
    println("Totaler relativer Fehler: ", total_error)
    
    return result1
end

# Beispiel-Daten: Knotenanzahl und zugehörige Zeitmessungen (z. B. aus deiner time_matrix)

function plotbounded(nodes_2,time_matrix,dim,parallel="",parallel_file="")
    plt = plot(title="Nodes vs Time in $dim, bounded domain$parallel",
    xlabel="Nodes", ylabel="Time (s)", legend=:topleft)#,xscale=:log10,yscale=:log10)

    result1 = plot_data_dfit!(plt, nodes_2, time_matrix[1, :],
                     marker=:circle,  color=:red,   label_scatter="QuickHull unbounded", label_fit="Fit 1")
    result2 = plot_data_dfit!(plt, nodes_2, time_matrix[9, :],
                     marker=:square,  color=:blue,  label_scatter="RCOriginal bounded parallel", label_fit="Fit 2")
    result3 = plot_data_dfit!(plt, nodes_2, time_matrix[10, :],
                     marker=:diamond, color=:green, label_scatter="RCCombined bounded parallel", label_fit="Fit 3")
    result4 = plot_data_dfit!(plt, nodes_2, time_matrix[11, :],
                     marker=:utriangle, color=:purple, label_scatter="RCNonGeneral bounded parallel", label_fit="Fit 3")

    display(plt)
    savefig(plt, "plot_$(dim)_bounded$parallel_file.pdf")
end

function plotunbounded(nodes_2,time_matrix,dim,parallel="",parallel_file="")
    plt = plot(title="Nodes vs Time in $dim, unbounded domain$parallel",
    xlabel="Nodes", ylabel="Time (s)", legend=:topleft)#, xscale=:log10,yscale=:log10)

    result1 = plot_data_dfit!(plt, nodes_2, time_matrix[1, :],
                            marker=:circle,  color=:red,   label_scatter="QuickHull unbounded", label_fit="Fit 1")
    result2 = plot_data_dfit!(plt, nodes_2, time_matrix[7, :],
                            marker=:square,  color=:blue,  label_scatter="RCOriginal unbounded parallel", label_fit="Fit 2")
    result4 = plot_data_dfit!(plt, nodes_2, time_matrix[8, :],
                            marker=:utriangle, color=:purple, label_scatter="RCNonGeneral unbounded parallel", label_fit="Fit 3")

    display(plt)

    savefig(plt, "plot_$(dim)_unbounded$parallel_file.pdf")
end

nodes_ = [100, 500, 1000, 2500, 5000, 10000, 15000, 20000, 25000, 30000, 35000, 40000, 50000]
nodes_2 = 1.0 .* nodes_ #.* log.(nodes_)  # Compute transformed x-axis values
time_matrix = [0.055317362499999995 0.5648807375 1.4375110875 4.999402850000001 10.905955457142857 24.046014624999998 37.6948187 51.49411505 65.598315025 82.698478675 97.362018675 115.866744125 149.68336905; 0.0421688375 0.49278962500000006 1.30308285 4.4001156125 10.795953385714286 25.643979325 43.343291300000004 61.758729175 81.2336554 103.353497475 124.241892775 146.984702125 195.634492525; 0.05367395 0.6383529375 1.6782441125 5.8575646625 14.089175157142858 33.700327275 56.401682775000005 80.61098057499999 105.99946117500001 136.61754005 163.17886987499998 192.634248075 256.76828125; 0.043356349999999995 0.36694162500000005 0.8942474875 2.8332420625 6.5238460571428565 14.8707057 23.4757898 33.56967075 43.00042177500001 53.172713325000004 64.61672935 74.86925392500001 94.884558525; 0.03909355 0.33298646249999997 0.798342475 2.5707554375 5.899830571428573 13.446140725 21.036083400000003 30.049458825000002 38.239454175 47.3968849 56.995313475 65.911397 83.9767584; 0.058328262500000005 0.49234683749999997 1.2145141750000001 3.9310415125000002 9.235992614285715 20.95519075 33.430848675 47.936390474999996 62.007480075000004 77.80851179999999 94.043194775 109.926515825 141.9878679; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]

time_matrix = [0.055317362499999995 0.5648807375 1.4375110875 4.999402850000001 10.905955457142857 24.046014624999998 37.6948187 51.49411505 65.598315025 82.698478675 97.362018675 115.866744125 149.68336905; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0; 0.0304862 0.29160665 0.7235698666666667 2.6166937666666663 6.60103528 15.519707866666666 25.949960766666667 36.487813100000004 48.8072311 63.710386199999995 76.88017933333334 89.9530125 115.72083296666666; 0.03073005 0.3293018333333333 0.8423996499999999 3.024142133333333 7.643141900000001 18.340689533333332 30.457673533333335 43.25413003333333 57.27862480000001 74.62927486666666 89.82684006666666 105.5139342 135.7103595; 0.025961866666666666 0.19112303333333333 0.5008410833333333 1.5769580000000003 3.7299483799999997 8.6958153 13.141076533333333 19.162241266666665 24.090799399999998 28.9520223 37.06956363333333 41.4378654 49.01620343333334; 0.025103233333333332 0.19239326666666667 0.4629685833333333 1.5729511666666667 3.5115002599999996 7.993156466666666 12.488456266666667 18.047404866666668 22.642939833333333 27.055827266666665 35.15026509999999 37.87390473333333 45.472447433333336; 0.029981533333333334 0.24575911666666664 0.6102803833333332 2.0214133166666666 4.55277592 10.573020933333334 16.9367099 24.3345032 30.413271733333332 37.9687143 47.75063456666667 53.26890546666666 63.59088433333333]

plotbounded(nodes_2,time_matrix,"5D"," 4 threads parallel computing","_parallel")
plotunbounded(nodes_2,time_matrix,"5D")

#plt_relation = plot(title="Nodes vs Time in 5D, unbounded domain",xlabel="Nodes", ylabel="Time (s)", legend=:topleft,xscale=:log10)

#data = copy(time_matrix[1, :])
#data ./=time_matrix[3,:]
#plot!(plt_relation, nodes_2,data)