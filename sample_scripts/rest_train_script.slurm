#!/bin/bash
#SBATCH -t 1:00:00
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --partition=aa100
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --output=R-%j-%x.out
#SBATCH --gres=gpu:1

module purge
module load anaconda

conda activate py39

export image_path="/scratch/alpine/alar6830/7.rest_MNI_to_TRs_znorm"
export neptune_project_name="SwiFT"
# --accelerator gpu
TRAINER_ARGS=' --max_epochs 1 --precision 16 --num_nodes 1 --devices 1 --strategy DDP --accelerator gpu' # specify the number of gpus as '--devices'
MAIN_ARGS='--loggername neptune --classifier_module v6 --dataset_name S1200 --image_path /scratch/alpine/alar6830/7.rest_MNI_to_TRs_znorm'
DATA_ARGS='--batch_size 8 --num_workers 8  --input_type rest'
DEFAULT_ARGS='--project_name Swin4D'
OPTIONAL_ARGS='--c_multiplier 2 --last_layer_full_MSA True --clf_head_version v1 --downstream_task sex' #--use_scheduler --gamma 0.5 --cycle 0.5'
RESUME_ARGS=''

export NEPTUNE_API_TOKEN="eyJhcGlfYWRkcmVzcyI6Imh0dHBzOi8vYXBwLm5lcHR1bmUuYWkiLCJhcGlfdXJsIjoiaHR0cHM6Ly9hcHAubmVwdHVuZS5haSIsImFwaV9rZXkiOiJlMTcxYmQ0OS1lNzRkLTRkMzEtYmY3Mi0yMzc2ZmIzYWQ4YjAifQ==" # when using neptune as a logger

python project/main.py $TRAINER_ARGS $MAIN_ARGS $DEFAULT_ARGS $DATA_ARGS $OPTIONAL_ARGS $RESUME_ARGS \
--dataset_split_num 1 --seed 1 --learning_rate 1e-5 --model swin4d_ver7 --depth 2 2 6 2 --embed_dim 36 --sequence_length 20 --first_window_size 4 4 4 4 --window_size 4 4 4 4 --img_size 96 96 96 20 #--train_split 0.5 --val_split 0.25
