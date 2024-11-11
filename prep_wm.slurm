#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=02:00:00
#SBATCH --partition=amem
#SBATCH --qos=mem 
#SBATCH -c 16
#SBATCH --output=prep_hcp-%j.out

module purge

module load anaconda 
conda activate py39

cd /projects/alar6830/SwiFT

python getWM.py

echo "done prepping"
