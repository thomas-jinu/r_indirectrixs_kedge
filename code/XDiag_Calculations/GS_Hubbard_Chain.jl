# Using XDiag package; more documentation here https://awietek.github.io/xdiag/examples/ahm_correlations/#__tabbed_1_2
# Scipost article https://arxiv.org/pdf/2505.02901
using XDiag
say_hello()
using Plots


################################``##############################
# Define the Hilbert Space
N = 12   # number of sites
nup = 10  # number of spin up electrons
ndown = 10  # number of spin down electrons
hs = Electron(N, nup, ndown)

################################``##############################
# Build the Hubbard Hamiltonian

# Define the holder for all operators
ops = OpSum()

# Define Hamiltonian Terms (negative sign is in included in the Op for Hop definition but should be checked)
t_x = 1.0
# t_y = -1.0
# t_perp = 0.0
U = 8.0
V = -1.0
Uc = 20.0

################################``##############################
# Build the Hopping Term along x-direction ( complicated logic needed for )
ops += "t_x" * Op("Hop", [1, 2])
ops += "t_x" * Op("Hop", [2, 3])
ops += "t_x" * Op("Hop", [3, 4])
ops += "t_x" * Op("Hop", [4, 5])
ops += "t_x" * Op("Hop", [5, 6])
ops += "t_x" * Op("Hop", [6, 7])
ops += "t_x" * Op("Hop", [7, 8])
ops += "t_x" * Op("Hop", [8, 9])
ops += "t_x" * Op("Hop", [9, 10])
ops += "t_x" * Op("Hop", [10, 11])
ops += "t_x" * Op("Hop", [11, 12])
ops += "t_x" * Op("Hop", [12, 1])
ops["t_x"] = t_x

# # Build the Hopping Term along y-direction ( complicated logic needed for )
# ops += "t_y" * Op("Hop" , [1 , 3])
# ops += "t_y" * Op("Hop" , [2 , 4])
# ops["t_y"] = t_y

# # Build the Hopping Term along t-perp ( complicated logic needed for )
# ops += "t_perp" * Op("Hop" , [1 , 4])
# ops += "t_perp" * Op("Hop" , [2 , 3])
# ops["t_perp"] = t_perp

################################``##############################
# Build the Onsite Interaction Term
for i in 1:N
    global ops += "U" * Op("Nupdn", [i])
end
ops["U"] = U

for i in [7]
    global ops += "Uc" * Op("Ntot", [i])
end
ops["Uc"] = Uc


# Build the nearest neighbor interaction term (complicated logic needed for )

ops += "V" * Op("NtotNtot", [1, 2])
ops += "V" * Op("NtotNtot", [2, 3])
ops += "V" * Op("NtotNtot", [3, 4])
ops += "V" * Op("NtotNtot", [4, 5])
ops += "V" * Op("NtotNtot", [5, 6])
ops += "V" * Op("NtotNtot", [6, 7])
ops += "V" * Op("NtotNtot", [7, 8])
ops += "V" * Op("NtotNtot", [8, 9])
ops += "V" * Op("NtotNtot", [9, 10])
ops += "V" * Op("NtotNtot", [10, 11])
ops += "V" * Op("NtotNtot", [11, 12])
ops += "V" * Op("NtotNtot", [12, 1])
# for i in 1:(N-1)
#     j_plus = mod1(i + 1, N)
#     println("Adding nearest neighbor interaction between sites $i and $j_plus")
#     global ops += "V" * Op("NtotNtot", [i, j_plus])
# end
ops["V"] = V




# Diagonalize the Hamiltonian to get the ground state energy
# set_verbosity(2)
e0, psi0 = eig0(ops, hs)    # compute ground state energy


# Compute the correlations needed
expectation_Sz = zeros(N)
for j in 1:N
    op_correlator = Op("Sz", [j])
    expectation_Sz[j] = inner(op_correlator, psi0)
end

expectation_N_tot = zeros(N)
for j in 1:N
    op_correlator = Op("Ntot", [j])
    expectation_N_tot[j] = inner(op_correlator, psi0)
end

expectation_N = zeros(N)
for j in 1:N
    op_correlator = Op("Nupdn", [j])
    expectation_N[j] = inner(op_correlator, psi0)
end

println("Ground State Energy: ", e0)
println("Expectation values of Sz at each site: ", expectation_Sz)
println("Expectation values of Ntot at each site: ", expectation_N_tot)
println("Expectation values of Nupdn at each site: ", expectation_N)

# plot!(expectation_Sz, label="Sz")
plot!(expectation_N_tot, label="Ntot", ylim=(0, 2))
# plot(expectation_N, label="Nupdn")
xlabel!("Site")
ylabel!("Expectation Value")
title!("Expectation Values of Correlators at Each Site")