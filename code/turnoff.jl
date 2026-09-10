#=
Function to check if all runFor* have "Turned off"
    - Reading .cout files
    - Check "Turning off" is in each file
    - Reports files not turned off
=#



using DelimitedFiles

function input(prompt::AbstractString="")
    print(prompt)
    return chomp(readline())
end

#=Function to read only the last line picked up from
https://discourse.julialang.org/t/how-to-read-only-the-last-line-of-a-file-txt/68005/11
=#
function read_last(file)
    open(file) do io
      seekend(io)
      seek(io, position(io) - 2)
      while Char(peek(io)) != '\n'
        seek(io, position(io) - 1)
      end
      read(io, Char)
      read(io, String)
    end
end

#cd("/Users/jinuthomas/Library/CloudStorage/OneDrive-UniversityofTennessee/research_projects/r_SUNNY/code/dmrg_scripts/testing_FT")

w_num = parse(Int64,input("Enter number of omega points: "))
n_sites = parse(Int64,input("Enter number of sites: "))

for site in 0:n_sites-1
    println("Checking site $site")
    for om in 0:w_num-1
        l = read_last("XAS$site/runForinputXAS.L=$n_sites.$om.cout")
        if occursin("Turning off",l)
            continue
        else
            println("File runForinputXAS.L=$n_sites.$om.cout is not turned off")
        end
    end
end


