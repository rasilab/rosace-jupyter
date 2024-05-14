# Base miniconda3 image
FROM continuumio/miniconda3:24.1.2-0

# Install mamba installer for quick conda installations
RUN conda install mamba -c conda-forge

# Install Python packages in base environment
RUN mamba install -y -c conda-forge jupyter

# Install R conda environment
RUN mamba create -y -n R

RUN mamba install -y -n R -c conda-forge \
    r-tidyverse \
    r-irkernel \
    r-devtools \
    r-cmdstanr

# Install system dependencies
RUN apt-get update && apt-get install -y git cmake g++ && apt-get clean

# Set up R jupyter kernel and make it visible to python
RUN /opt/conda/envs/R/bin/R -s -e "IRkernel::installspec(sys_prefix = TRUE)"

# Make R visible to python environment
ENV PATH="$PATH:/opt/conda/envs/R/bin"

# Install the release version of rosace
RUN /opt/conda/envs/R/bin/R -s -e "remotes::install_github('pimentellab/rosace@0d469506a02057f6402d6a0b9d075cd5eaa1a177')"

# Install CmdStan
RUN /opt/conda/envs/R/bin/R -s -e "library(cmdstanr); install_cmdstan(cores = 4)"
