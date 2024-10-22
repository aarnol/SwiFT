#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=06:00:00
#SBATCH --partition=amilan

#SBATCH -c 1
#SBATCH --output=download-%j.out

module purge

module load anaconda 
conda activate py39

cd /projects/alar6830/SwiFT

python download_WM.py