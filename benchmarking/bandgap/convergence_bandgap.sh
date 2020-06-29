#!/bin/bash
#
#SBATCH -A venkvis
#SBATCH -p cpu
#SBATCH -n 2 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem-per-cpu=8000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -o output.%j # File to which STDOUT will be written
#SBATCH -e error.%j # File to which STDERR will be written
#SBATCH --time=0-08:00
#SBATCH -J conv

echo "Job started on `hostname` at `date`"
/home/abills/julia-1.4.0/bin/julia convergence.jl
echo " "
echo "Job Ended at `date`"
