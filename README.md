# Running FHI-aims on the Duke Compute Cluster (DCC)

[FHI-aims](https://fhi-aims.org)[^1] is an all-electron electronic structure, Density Functional Theory (DFT)[^3] code based on numeric atom-centered orbitals. It enables first-principles materials simulations with very high numerical accuracy for production calculations, with excellent scalability up to very large system sizes (thousands of atoms) and up to very large, massively parallel supercomputers (ten thousand CPU cores)[^2].

## Accessing FHI-aims on DCC

There are two ways to access the FHI-aims code on the DCC cluster.
1. Loading the pre-built module
2. Building from source

As a pre-requisite for both cases, append the dependency module locations to the $MODULEPATH environmental variable by adding the following to your `~/.bashrc`. 

```bash
export MODULEPATH="/hpc/group/coursess25/ME511/modulefiles/:$MODULEPATH"
export MODULEPATH="/hpc/group/coursess25/ME511/intel/oneapi/modulefiles/:$MODULEPATH"
```

{: .notice--warning}
On some partitions, FHI-aims built with GNU compilers and OpenMPI cause issues. Therefore, FHI-aims is built on Intel oneAPI compilers, Intel MPI and Intel MKL math libraries. 

### 1. Loading the pre-built module 



### 2. Building from source

If you wish to build FHI-aims from source, these are the steps.

1\. Get the code from [FHI-aims](https://fhi-aims.org).
2\. Load the necessary compiler and library modules. 










# Reference

[^1]: V. Blum, R. Gehrke, F. Hanke, P. Havu, V. Havu, X. Ren, K. Reuter, and M. Scheffler, Ab initio molecular simulations with numeric atom-centered orbitals, Computer Physics Communications 180, 2175 (2009). DOI: [https://doi.org/10.1016/j.cpc.2009.06.022](https://doi.org/10.1016/j.cpc.2009.06.022)

[^2]: S. Kokott, F. Merz, Y. Yao, C. Carbogno, M. Rossi, V. Havu, M. Rampp, M. Scheffler, and V. Blum, Efficient all-electron hybrid density functionals for atomistic simulations beyond 10 000 atoms, The Journal of Chemical Physics (2024).

[^3]: P. Hohenberg and W. Kohn, Inhomogeneous Electron Gas, Phys. Rev. **136**, B864 (1964).
