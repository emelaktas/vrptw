# num customers
param N;

# num vehicles;
param K;

# demand vertices (customers)
set demand_vertices := 1..N;

# vehicles
set vehicles := 1..K;

# all vertices
set vertices := 0..N+1;

# arcs
set arcs := {i in vertices, j in vertices: i <> j};

# vehicle capacity
param Q;

# demand of each customer
param q{demand_vertices};

# distance
param c{arcs};

# service time
param s{vertices};

# travel time
param t{arcs};

# ready time
param a{vertices};

# due time
param b{vertices};

# M to linearise w
param M{arcs};

# binary variable showing that the arc is used
var x{arcs, vehicles}, binary;

# continuous variable showing when vehicle k starts serving vertex i
var w{vertices,vehicles} >= 0; 

# objective function: minimise distance
minimize total_distance: sum{k in vehicles, (i,j) in arcs} c[i,j] * x[i,j,k];

# visit each customer once
subject to visit_customer{i in demand_vertices}:
    sum{k in vehicles, (i,j) in arcs} x[i,j,k] = 1;

# use each vehicle once
subject to vehicle_use{k in vehicles}:
	sum{j in vertices: j <> 0} x[0,j,k] = 1;

# flow conservation
subject to flow_conservation{k in vehicles, j in demand_vertices}:
	sum{i in vertices: i <> j } x[i,j,k] - sum{i in vertices: i <> j} x[j,i,k] = 0;
	
# return to depot
subject to return_depot{k in vehicles}:
	sum{i in vertices: i <> N+1} x[i, N+1, k]  = 1; 
	
# consistency of time variables 
subject to time_consistency{(i,j) in arcs, k in vehicles}:
	w[j,k] >= w[i,k]+ s[i] + t[i,j] - M[i,j] * (1 - x[i,j,k]);
	
# start service
subject to service_start{k in vehicles, i in vertices}:
	w[i,k] >= a[i];

# finish service
subject to service_finish{k in vehicles, i in vertices}:
	w[i,k] <= b[i]	- s[i];
	
# vehicle capacity
subject to capacity{k in vehicles}:
	sum{i in demand_vertices, (i,j) in arcs} q[i] * x[i,j,k] <= Q;

