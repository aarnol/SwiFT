#!/bin/bash
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH --nodelist node1
#SBATCH -c 32
#SBATCH --ntasks-per-node=1
#SBATCH --output=sample-%j.out


module purge
module load anaconda
conda activate py39

echo "== This is the scripting step! =="
python /projects/alar6830/SwiFT/project/module/utils/data_preprocess_and_load/preprocessing.py
echo "== Finished =="
