#= Julia file that loads manipulates DMRG files
=#

# DMRG++ Loading File Functions
module DMRG_Load

    using DelimitedFiles
    using Revise


    # Returns data reshaped for plotting
    function reshape_RIXS_pitopi(data)
        val_N = length(unique(data[:,1])) 
        val_Omega = length(unique(data[:,2]))
        dims = (val_N,val_Omega) 
        reshaped_data = reshape(data[:,3],dims)
        return append_q0_pitopi(reshaped_data,val_N)
    end

    function append_q0_pitopi(data,val_N)
        q_BZ_middle = div(val_N,2)
        new_data = [data[q_BZ_middle+1:end,:];transpose(data[1,:]);data[2:q_BZ_middle+1,:]]
        return new_data
    end

    # Returns the grid for plotting
    function get_grid_pitopi(data)
        omega_grid = unique(data[:,2])
        q_grid = push!(unique(data[:,1]),2*π) .- π
        return omega_grid,q_grid 
    end

    # Function to load data once the address for file is given
    function load_rixs_data_qrenormalized_pitopi(file_address::String)
        # Parameters
        delim=' '         # Spacing character
        eol='\n'          # New line
        use_mmap = false  # Potential speedups if the file is large. 
        data = readdlm(file_address,delim::AbstractChar, eol::AbstractChar;
        header=false, skipstart=0, skipblanks=true, use_mmap, quotes=true, comments=false, comment_char='#');

        heatmap_data = reshape_RIXS_pitopi(data)
        omega_grid,q_grid = get_grid_pitopi(data)

        return omega_grid,q_grid/(2π),heatmap_data
    end
    

    # Returns data reshaped for plotting
    function reshape_RIXS_appendq2π(data)
        val_N = length(unique(data[:,1])) 
        val_Omega = length(unique(data[:,2]))
        dims = (val_N,val_Omega) 
        reshaped_data = reshape(data[:,3],dims)
        return append_qπ(reshaped_data)
    end

    # Returns data reshaped for plotting
    function reshape_RIXS(data)
        val_N = length(unique(data[:,1])) 
        val_Omega = length(unique(data[:,2]))
        dims = (val_N,val_Omega) 
        reshaped_data = reshape(data[:,3],dims)
        return reshaped_data
    end


    # Returns the grid for plotting
    function get_grid(data)
        omega_grid = unique(data[:,2])
        q_grid = push!(unique(data[:,1]),2*π)
        return omega_grid,q_grid 
    end

    # Append the q=0 at the end of the array
    function append_qπ(data)
        return [data;transpose(data[1,:])]
    end

    # Function to load data once the address for file is given
    function load_rixs_data(file_address::String)
        # Parameters
        delim=' '         # Spacing character
        eol='\n'          # New line
        use_mmap = false  # Potential speedups if the file is large. 
        data = readdlm(file_address,delim::AbstractChar, eol::AbstractChar;
        header=false, skipstart=0, skipblanks=true, use_mmap, quotes=true, comments=false, comment_char='#');

        heatmap_data = reshape_RIXS_appendq2π(data)
        omega_grid,q_grid = get_grid(data)

        return omega_grid,q_grid,heatmap_data
    end


        # Function to load data once the address for file is given
    function load_rixs_data_qrenormalized(file_address::String)
            # Parameters
            delim=' '         # Spacing character
            eol='\n'          # New line
            use_mmap = false  # Potential speedups if the file is large. 
            data = readdlm(file_address,delim::AbstractChar, eol::AbstractChar;
            header=false, skipstart=0, skipblanks=true, use_mmap, quotes=true, comments=false, comment_char='#');
    
            heatmap_data = reshape_RIXS_appendq2π(data)
            omega_grid,q_grid = get_grid(data)
    
            return omega_grid,q_grid/(2π),heatmap_data
t    end


    # Function to load data once the address for file is given
    function load_phonon_data_qrenormalized_pitopi(file_address::String)
            # Parameters
            delim=' '         # Spacing character
            eol='\n'          # New line
            use_mmap = false  # Potential speedups if the file is large. 
            data = readdlm(file_address,delim::AbstractChar, eol::AbstractChar;
            header=false, skipstart=0, skipblanks=true, use_mmap, quotes=true, comments=false, comment_char='#');



            omega_grid = unique(data[:,2])
            q_grid = (unique(data[:,1])) .- π

            val_N = length(q_grid) 
            val_Omega = length(omega_grid)

            q_BZ_middle = div(val_N,2)

            heatmap_data = reshape_RIXS(data)

            new_data = [heatmap_data[q_BZ_middle+1:end,:];heatmap_data[2:q_BZ_middle+1,:]]

            return omega_grid,q_grid/(2π),new_data
    end

        # Function to load data once the address for file is given
    function load_phonon_data_qrenormalized(file_address::String)
            # Parameters
            delim=' '         # Spacing character
            eol='\n'          # New line
            use_mmap = false  # Potential speedups if the file is large. 
            data = readdlm(file_address,delim::AbstractChar, eol::AbstractChar;
            header=false, skipstart=0, skipblanks=true, use_mmap, quotes=true, comments=false, comment_char='#');
    
            # Already contains the q=2π data
            omega_grid = unique(data[:,2])
            q_grid = unique(data[:,1])

            heatmap_data = reshape_RIXS(data)
    
            return omega_grid,q_grid/(2π),heatmap_data
    end

    # Function to load data once the address for file is given
    function load_Nqw_data_qrenormalized(file_address::String)
            # Parameters
            delim=' '         # Spacing character
            eol='\n'          # New line
            use_mmap = false  # Potential speedups if the file is large. 
            data = readdlm(file_address,delim::AbstractChar, eol::AbstractChar;
            header=false, skipstart=0, skipblanks=true, use_mmap, quotes=true, comments=false, comment_char='#');
    
            # Already contains the q=2π data
            omega_grid = unique(data[:,2])
            q_grid = unique(data[:,1])

            heatmap_data = reshape_RIXS(data)
    
            return omega_grid,q_grid/(2π),heatmap_data
    end

    # Function to load xas data once the address for file is given.Assumes 2 columns from the perl script. 
    function load_xas_data(file_address::String)
        # Parameters
        delim=' '         # Spacing character
        eol='\n'          # New line
        use_mmap = false  # Potential speedups if the file is large. 
        data = readdlm(file_address,delim::AbstractChar, eol::AbstractChar;
        header=false, skipstart=0, skipblanks=true, use_mmap, quotes=true, comments=false, comment_char='#');

        ω_in  = data[:,1];
        I_xas = data[:,2];

        return ω_in,I_xas
    end

    # Extract q=0 data from perl script generated spectra for a chain of length N
    function extract_q0(data_DMRG)
        return data_DMRG[1,:];
    end
    
    # Extract q=π data from perl script generated spectra for a chain of length N
    function extract_qπ(data_DMRG)
        N = round.(Int,size(data_DMRG,1)/2);
        return data_DMRG[N+1,:];
    end
    
    function extract_qπover2(data_DMRG)
        N = round.(Int,size(data_DMRG,1)/4);
        return data_DMRG[N+1,:];
    end

    export load_rixs_data,load_xas_data,extract_q0,extract_qπ,load_rixs_data_qrenormalized,extract_qπover2,load_phonon_data_qrenormalized,load_Nqw_data_qrenormalized,
    load_rixs_data_qrenormalized_pitopi,load_phonon_data_qrenormalized_pitopi

end


module Lang_Firsov

    using Revise
    using DelimitedFiles

    # Load the files from HH Single Site XAS and RIXS
    function load_1site(file_address::String)
        # Parameters
        delim='\t'         # Spacing character
        eol='\n'          # New line
        use_mmap = false  # Potential speedups if the file is large. 
        data = readdlm(file_address,delim::AbstractChar, eol::AbstractChar;
        header=false, skipstart=0, skipblanks=true, use_mmap, quotes=true, comments=false, comment_char='#');

        ω  = data[1,:];
        I = data[2,:];

        return ω_in,I_xas
    end

    export load_1site
end


module Peak_Analysis

    using FindPeaks1D


    # Find the first peak and returns its values for its energy and intensity
    function first_peak(ω_1D, I_1D,Γ)
        pkindices, pkproperties = findpeaks1d(I_1D);
        return ω_1D[pkindices[1]],I_1D[pkindices[1]];
    end

     # Find all peaks and returns its values for its energy and intensity
    function all_peaks(ω_1D, I_1D,Γ)
        pkindices, pkproperties = findpeaks1d(I_1D);
        return ω_1D[pkindices],I_1D[pkindices];
    end

    function find_peaks_2D_alongrows(data_2D)
        # Find the peaks in the 2D data for rows, returns the values and the column and row index arrays
        pkvalues, pkindices = findmax(data_2D,dims=2);
        return pkvalues, getindex.(pkindices,1), getindex.(pkindices,2);
    end

    function find_peaks_2D_alongcols(data_2D)
        # Find the peaks in the 2D data for rows
        pkvalues, pkindices = findmax(data_2D,dims=1);
        return pkvalues, getindex.(pkindices,1), getindex.(pkindices,2);
    end

    export first_peak,all_peaks,find_peaks_2D_alongcols,find_peaks_2D_alongrows

end


module Curve_Fitting

    # To find that area under a discrete curve using Simpsons Rule
    using Integrals,Revise
    function compute_area_under_curve_simpsons(x::Array,y::Array)
        problem = SampledIntegralProblem(y,x)
        method = SimpsonsRule()
        return solve(problem,method)
    end

    # To find that area under a discrete curve using Trapezoidal Rule
    function compute_area_under_curve_trapez(x::Array,y::Array)
        problem = SampledIntegralProblem(y,x)
        method = TrapezoidalRule()
        return solve(problem,method)
    end

    function compute_area_under_curve_simpsons_2D(x::Array,y::Array,z::Array)
        # For performance reasons the last axis is integrated first.
        # Here I assume we are integrating the x axis first and then the y axis, with data provided for z in dimensions (x,y)   

        z_transpose = transpose(z)
        problem_x = SampledIntegralProblem(z_transpose,x)
        method = SimpsonsRule()
        z_xintegrated = solve(problem_x,method)
        problem_y = SampledIntegralProblem(z_xintegrated,y)
        return solve(problem_y,method)
    end

    export compute_area_under_curve_simpsons,compute_area_under_curve_trapez,compute_area_under_curve_simpsons_2D
end


