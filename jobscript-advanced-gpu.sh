#!/bin/bash
#SBATCH -J GaAs_HSE06+SOC-advanced-gpu   # Job name
#SBATCH -p courses-gpu        # Queue (partition) name
#SBATCH -N 2              # Total no. of cores
#SBATCH --ntasks-per-node=42  # Tasks per node
#SBATCH -c 2                # CPU's per task
#SBATCH --mem=466G  # Memory per node
#SBATCH --gres=gpu:p100:2   # P100 GPU X2
#SBATCH --exclusive

### --- OPTIONAL --- ###
##SBATCH --mail-type=fail    # Send email at failed job
##SBATCH --mail-type=end     # Send email at end of job
##SBATCH --mail-user=your_email@duke.edu
##SBATCH --mem-per-cpu=5G    # Memory per CPU

# Initialization
source ~/.bashrc
module load FHIaims-intel-gpu
ulimit -s unlimited

# Execution
cd $SLURM_SUBMIT_DIR
mpirun -n $SLURM_NTASKS aims.x > aims.out 2> aims.err

### If you built from source, use the following instead.
# module load compiler/latest
# module load mkl/latest
# module load mpi/latest
# module load CUDA/12.4
# ulimit -s unlimited

# cd $SLURM_SUBMIT_DIR
# mpirun -n $SLURM_NTASKS /hpc/home/ukh/apps/FHIaims/build_gpu/aims.X.scalapack.mpi.x > aims.out 2> aims.err
