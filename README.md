# SDSC "fftw" roll

## Overview

This roll bundles the FFTW library.  

For more information about FFTW please visit the official web page:

- <a href="http://www.fftw.org" target="_blank">FFTW</a> is a C subroutine library for computing the discrete Fourier transform (DFT) in one or more dimensions, of arbitrary input size, and of both real and complex data.


## Requirements

To build/install this roll you must have root access to a Rocks development
machine (e.g., a frontend or development appliance).

If your Rocks development machine does *not* have Internet access you must
download the appropriate fftw source file(s) using a machine that does
have Internet access and copy them into the `src/<package>` directories on your
Rocks development machine.


## Dependencies

Unknown at this time.


## Building

To build the fftw-roll, execute these instructions on a Rocks development
machine (e.g., a frontend or development appliance):

```shell
% make 2>&1 | tee build.log
% grep "RPM build error" build.log
```

If nothing is returned from the grep command then the roll should have been
created as... `fftw-*.iso`. If you built the roll on a Rocks frontend then
proceed to the installation step. If you built the roll on a Rocks development
appliance you need to copy the roll to your Rocks frontend before continuing
with installation.

This roll source supports building with different compilers and for different
network fabrics and mpi flavors.  By default, it builds using the gnu compilers
for openmpi ethernet.  To build for a different configuration, use the
`ROLLCOMPILER`, `ROLLMPI` and `ROLLNETWORK` make variables, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mpich2 ROLLNETWORK=mx 
```

The build process currently supports one or more of the values "intel", "pgi",
and "gnu" for the `ROLLCOMPILER` variable, defaulting to "gnu".  It supports
`ROLLMPI` values "openmpi", "mpich2", and "mvapich2", defaulting to "openmpi".
It uses any `ROLLNETWORK` variable value(s) to load appropriate mpi modules,
assuming that there are modules named `$(ROLLMPI)_$(ROLLNETWORK)` available
(e.g., `openmpi_ib`, `mpich2_mx`, etc.).  The build process uses the
ROLLCOMPILER value to load an environment module, so you can also use it to
specify a particular compiler version, e.g.,

```shell
% make ROLLCOMPILER=gnu/4.8.1 ROLLMPI=mpich2 ROLLNETWORK=ib
```

If the `ROLLCOMPILER`, `ROLLNETWORK` and/or `ROLLMPI` variables are specified,
their values are incorporated into the names of the produced rpms, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mvapich2 ROLLNETWORK=ib
```
produces a roll containging an rpm with a name that begins
"`fftw_intel_mvapich2_ib`".

For gnu compilers, the roll also supports a `ROLLOPTS` make variable value of
'avx', indicating that the target architecture supports AVX instructions.


## Installation

To install, execute these instructions on a Rocks frontend:

```shell
% rocks add roll *.iso
% rocks enable roll fftw
% cd /export/rocks/install
% rocks create distro
% rocks run roll fftw | bash
```

In addition to the software itself, the roll installs fftw environment
module files in:

```shell
/opt/modulefiles/applications/.(compiler)/fftw|fftw_2.1.5.
```


## Testing

The fftw-roll includes a test script which can be run to verify proper
installation of the fftw-roll documentation, binaries and module files. To
run the test scripts execute the following command(s):

```shell
% /root/rolltests/fftw.t 
```
