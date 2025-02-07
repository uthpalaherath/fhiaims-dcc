#!/bin/bash
#SBATCH -J GaAs_HSE06+SOC-basic   # Job name
#SBATCH -p courses        # Queue (partition) name
#SBATCH -n 100             # Total no. of tasks
#SBATCH --mem-per-cpu=5G  # Memory per CPU

### --- OPTIONAL --- ###
##SBATCH --mail-type=fail    # Send email at failed job
##SBATCH --mail-type=end     # Send email at end of job
##SBATCH --mail-user=your_email@duke.edu

# Initialization
source ~/.bashrc
module load FHIaims-intel
ulimit -s unlimited

# Execution
cd $SLURM_SUBMIT_DIR
mpirun -n $SLURM_NTASKS aims.x > aims.out 2> aims.err

### If you built from source, use the following instead.
# module load compiler/latest
# module load mkl/latest
# module load mpi/latest
# ulimit -s unlimited

# cd $SLURM_SUBMIT_DIR
# mpirun -n $SLURM_NTASKS /hpc/home/ukh/apps/FHIaims/build/aims.X.scalapack.mpi.x > aims.out 2> aims.err
