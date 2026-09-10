# This script creates folders and files for running XAS for all sites .
# To run load python module


# What are the steps for this code:

# 1. Load the modules and get the current directory. (XAS_Header File)
# 2. Take the input parameters.
# 3. Create n folders for n sites and create the input files and batch files for each site.
# 3.1 - Edge sites need to be treated specially.
# Step 4 - Check if the run is the last om_IN file and then run the perl script.
# Submit all the batches from the script once created ?


# Step 1: importing os module for opening and changing directories
import os  # changing/opening etc. with directories
import shutil  # for copying files
import numpy as np  # for doing numerical operations
import subprocess  # for running the perl script

parent_dir = os.getcwd()  # Parent XAS directory.

# shutil.copy2(
#        "../../dataGS_L64_N56_1500.hd5",
#    parent_dir,
#    follow_symlinks=True,
# )  # Copy the GS file from the upper file directory to parent.


# Step 2
# Hilbert Space Parameters
N = int(input("Total number of sites: "))
Up = int(input("Number of up electrons: "))
Dn = int(input("Number of down electrons: "))
Total_electrons = int(Up + Dn)


# Model Parameters
U = float(input("Hubbard U: "))
V_ch = float(input("Core_Hole Potential: "))
V_NN = float(input("Nearest neighbor repulsion/attraction V along leg: "))


# Spectra Parameters
omega_in = float(input("Starting value for omega: "))
omega_tot = int(input("Total number of omega points: "))
omega_step = float(input("Spacing between omega points: "))
gamma = float(input("Lorentzian Spectral Broadening Gamma: "))
# site_xas = int(input("Site for which XAS is computed: "))

om_IN = np.zeros(
    omega_tot
)  # Create an array of zeros for the omegas to check if the file is created.

XAS_total = np.zeros(
    omega_tot
)  # Create an array of zeros for the XAS values to check if the file is created.
# Step 3
# Create the folders for each site:
for site_xas in range(0, N):

    directory = str("XAS" + str(site_xas))  # Name of the directory
    path = os.path.join(parent_dir, directory)  # Create the path
    os.makedirs(path, exist_ok=True)  # Create the directory
    os.chdir(path)  # Go intothatdirectory

    shutil.copy2("../myprocOmegashhXAS.pl", path, follow_symlinks=True)

    with open("out.txt", "w+") as fout:
        with open("err.txt", "w+") as ferr:
            # Runs the perl manyOmegas.pl
            result = subprocess.call(
                [
                    "perl",
                    "myprocOmegashhXAS.pl",
                    str(N),
                    str(Total_electrons),
                    "1",
                    str(site_xas),
                    str(omega_in),
                    str(omega_step),
                    str(omega_tot),
                    str(gamma),
                    str(V_ch),
                    str(U),
                    str(V_NN),
                ],
                stdout=fout,
                stderr=ferr,
            )

    om_IN, XAS_val = np.loadtxt(
        f"outSpectrumXAS.chain.L.{N}.N.{Total_electrons}.Gamma.{gamma}.Vc.{V_ch}.U.{U}.V.{V_NN}.center.{site_xas}.gnuplot",
        dtype=float,
        unpack=True,
    )  # Load the omegas to check if the file is created.

    XAS_total += XAS_val  # Add the XAS values for each site to get the total XAS.

os.chdir(parent_dir)  # Go into parent directory after all the site folders are done.

np.savetxt(
    f"outSpectrumXAS.chain.L.{N}.N.{Total_electrons}.Gamma.{gamma}.Vc.{V_ch}.U.{U}.V.{V_NN}.allsites.gnuplot",
    np.column_stack((om_IN, XAS_total)),
)  # Save the total XAS values to a file.
