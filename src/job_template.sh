#! /bin/bash -l
#SBATCH --partition=scu-gpu,scu-cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=2-00:00:00
#SBATCH --mem=50G   # memory requested, units available: K,M,G,T
#SBATCH --cpus-per-task=8
#SBATCH --output=slurm_output/slurm-%j.out

