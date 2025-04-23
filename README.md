# Running FHI-aims on the Duke Compute Cluster (DCC)

[FHI-aims](https://fhi-aims.org) [^1] is an all-electron, electronic structure Density Functional Theory (DFT)[^3] code based on numeric atom-centered orbitals. It enables first-principles materials simulations with very high numerical accuracy for production calculations, with excellent scalability up to very large system sizes (thousands of atoms) and up to very large, massively parallel supercomputers (ten thousand CPU cores)[^2].

> [!IMPORTANT]
> FHI-aims is a licensed code. If you are taking Dr. Volker Blum's ME511 class at Duke University, this is probably already taken care of. Otherwise, visit the FHI-aims website to obtain a license.

## Contents

- [Accessing FHI-aims on DCC](#accessing-fhi-aims-on-dcc)
- [Running FHI-aims on DCC](#running-fhi-aims-on-dcc)
- [Monitoring resource usage](#monitoring-resource-usage)

## Accessing FHI-aims on DCC

There are two ways to access the FHI-aims code on the DCC cluster.
1. Loading the pre-built module
2. Building from source

As a pre-requisite for both cases, append the dependency module locations to the $MODULEPATH environmental variable by adding the following to your `~/.bashrc`.

(a) If you are part of the ME511 course:
```bash
export MODULEPATH="/hpc/group/coursess25/ME511/modulefiles/:$MODULEPATH"
export MODULEPATH="/hpc/group/coursess25/ME511/intel/oneapi/modulefiles/:$MODULEPATH"
```

(b) If you are part of the Blum Lab:
```bash
export MODULEPATH="/hpc/group/blumlab/modulefiles/:$MODULEPATH"
export MODULEPATH="/hpc/group/blumlab/intel/oneapi/modulefiles/:$MODULEPATH"
```

> [!WARNING]
> On some DCC partitions, FHI-aims built with GNU compilers and OpenMPI terminates at runtime with MPI errors. Therefore, FHI-aims is built on Intel oneAPI compilers, Intel MPI and Intel MKL math libraries.

### 1. Loading the pre-built module

This is essentially a pre-built executable built using [method \#2](#2-building-from-source).
The FHI-aims module may be loaded with the following command,

```bash
module load FHIaims-intel
```

In addition to providing global access to the FHI-aims executable (now symlinked as `aims.x`), this also sets the `$SPECIES_DEFAULTS` environmental variable to access the basis set library and provides global access to scripts in `/hpc/group/coursess25/ME511/apps/FHIaims-intel/utilities` (or `/hpc/group/blumlab/apps/FHIaims-intel/utilities`).

To run calculations with GPU acceleration enabled, load the following module instead,

```bash
module load FHIaims-intel-gpu
```

### 2. Building from source

This approach is useful if you are a developer and wish to modify the source code of FHI-aims for your desired purposes.

1\. Get the code from [FHI-aims](https://fhi-aims.org) and place it in your HOME space (e.g., "/hpc/home/ukh/apps/FHIaims/").

2\. Assuming the intention is to build with an Intel environment, load the necessary compiler and library modules.

```
module load compiler/latest
module load mkl/latest
module load mpi/latest
module load cmake/3.28.3
```

3\. Navigate into the FHI-aims root directory and create a `build` directory within (e.g., "/hpc/home/ukh/apps/FHIaims/build"). Create the `initial_cache.cmake`  file shown below inside this directory.

`initial_cache.cmake`:
```cmake
set(CMAKE_Fortran_COMPILER "mpiifx" CACHE STRING "" FORCE)
set(CMAKE_Fortran_FLAGS "-O3 -fp-model precise" CACHE STRING "" FORCE)
set(Fortran_MIN_FLAGS "-O0 -fp-model precise" CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER "mpiicx" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS "-O3 -fp-model precise -std=gnu99" CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER "mpiicpx" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "-O3 -fp-model precise -std=c++11" CACHE STRING "" FORCE)

set(LIB_PATHS "$ENV{MKLROOT}/lib/intel64 " CACHE STRING "" FORCE)
set(LIBS "mkl_intel_lp64 mkl_sequential mkl_core mkl_blacs_intelmpi_lp64 mkl_scalapack_lp64 mkl_core" CACHE STRING "" FORCE)
set(USE_MPI ON CACHE BOOL "" FORCE)
set(USE_SCALAPACK ON CACHE BOOL "" FORCE)
set(USE_SPGLIB ON CACHE BOOL "" FORCE)
set(USE_LIBXC ON CACHE BOOL "" FORCE)
set(USE_HDF5 OFF CACHE BOOL "" FORCE)
set(USE_RLSY ON CACHE BOOL "" FORCE)
```

4\. Run the configuration with:
```
cmake -C initial_cache.cmake ..
```

5\. Build the code with:
```
make -j 8
```

Following a successful build, the executable `aims.X.scalapack.mpi.x` ("X" refers to the version number) should be generated within the `build` directory.

#### Building with GPU support

To build FHI-aims with GPU support, load the CUDA module in addition to the Intel modules and cmake.

```
module load compiler/latest
module load mkl/latest
module load mpi/latest
module load cmake/3.28.3
module load CUDA/12.4
```

Then add the following lines to the previous `initial_cache.cmake` file and follow the remaining steps as before.

```
########################### GPU Acceleration Flags #########################
set(USE_CUDA ON CACHE BOOL "")
set(CMAKE_CUDA_COMPILER nvcc CACHE STRING "")
set(CMAKE_CUDA_FLAGS "-O3 -DAdd_ -arch=sm_60 -lcublas " CACHE STRING "")
```

The flag `-arch=sm_60` is used here to comply with the NVIDIA Pascal GPU architecture found in the NVIDIA Tesla P100 GPUs available in `dcc-courses-gpu` nodes.

## Running FHI-aims on DCC

To demonstrate running FHI-aims, we will use the GaAs_HSE06+SOC example, which is a periodic GaAs structure with hybrid functionals and a spin-orbit coupling (SOC) correction. The necessary input files (control.in and geometry.in) are provided in the GaAs_HSE06+SOC directory. Copy this to your WORK space (e.g., "/work/ukh/GaAs_HSE06+SOC") and use one of the following job submission scripts to run the calculation.

### Basic

The basic run automatically sets the required number of nodes when the total number of cores are requested.

`jobscript-basic.sh`:
```bash
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
```

### Advanced

If more control of resources is required, the following job submission script is more suitable. This is tailored to the `courses` partition housing nodes consisting of Intel(R) Xeon(R) CPU E5-2699 v4 processors with 42 physical cores per node.

`jobscript-advanced.sh`:
```bash
#!/bin/bash
#SBATCH -J GaAs_HSE06+SOC-advanced   # Job name
#SBATCH -p courses        # Queue (partition) name
#SBATCH -N 2              # Total no. of cores
#SBATCH --ntasks-per-node=42  # Tasks per node
#SBATCH -c 2                # CPU's per task
#SBATCH --mem=466G  # Memory per node

### --- OPTIONAL --- ###
##SBATCH --mail-type=fail    # Send email at failed job
##SBATCH --mail-type=end     # Send email at end of job
##SBATCH --mail-user=your_email@duke.edu
##SBATCH --mem-per-cpu=5G    # Memory per CPU

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
```

The parameter `-c 2` is essential to obtain the highest efficiency by pairing both physical and hyper-threaded cores.

Run the calculation by submitting the job with the following command,

```
sbatch jobscript-advanced.sh
```

For GPU calculations, use the following submission script,

`jobscript-advanced-gpu.sh`:
```bash
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
```

and ensure you have the following flags in your `control.in`.

```
use_gpu
elsi_elpa_gpu 1
```

> [!NOTE]
> In case you are using FHI-aims purely for research purposes on DCC and don't have your own research nodes, you may have to use the "scavenger" partition for policy reasons. Replace "courses" with "scavenger" and add `#SBATCH --nodelist=dcc-courses-[1-50]` to the job submission script `jobscript-advanced.sh` above. Note that the flag `-N` has to be specified for this to work. For GPU calculations, use "scavenger-gpu" and `#SBATCH --nodelist=dcc-courses-gpu-[01-10]` instead.

For more information on running FHI-aims, please refer the [tutorials](https://fhi-aims-club.gitlab.io/tutorials/tutorials-overview/) webpage.

## Monitoring resource usage

For efficient running of the code, it is important to monitor how the resources are being utilized. The `jobstats.sh` script may be used for this purpose as follows,

```
jobstats.sh <JOBID>
```

`JOBID` is the ID of the job submitted through `sbatch`, which can be found from the `squeue` command.
Please refer to [this article](https://uthpalaherath.com/Advanced-resource-monitoring-on-HPC-clusters/) for further guidance on using this script.

# Reference

[^1]: V. Blum, R. Gehrke, F. Hanke, P. Havu, V. Havu, X. Ren, K. Reuter, and M. Scheffler, Ab initio molecular simulations with numeric atom-centered orbitals, Computer Physics Communications 180, 2175 (2009). DOI: [https://doi.org/10.1016/j.cpc.2009.06.022](https://doi.org/10.1016/j.cpc.2009.06.022)

[^2]: S. Kokott, F. Merz, Y. Yao, C. Carbogno, M. Rossi, V. Havu, M. Rampp, M. Scheffler, and V. Blum, Efficient all-electron hybrid density functionals for atomistic simulations beyond 10 000 atoms, The Journal of Chemical Physics (2024).

[^3]: P. Hohenberg and W. Kohn, Inhomogeneous Electron Gas, Phys. Rev. **136**, B864 (1964).
