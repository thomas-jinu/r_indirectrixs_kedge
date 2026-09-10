# This script loops into XAS for each site and processes the data, creating a local output file;
# Then it loops thru the sites and creates a total XAS file for all sites.


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
