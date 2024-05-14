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

# Set CmdStan installation directory
ENV CMDSTAN="/opt/cmdstan"

# Create the directory for CmdStan
RUN mkdir -p ${CMDSTAN}

# Install CmdStan manually
WORKDIR ${CMDSTAN}
RUN curl -L https://github.com/stan-dev/cmdstan/releases/download/v2.34.1/cmdstan-2.34.1.tar.gz | tar -xz
RUN cd cmdstan-2.34.1 && make build

# Set CMDSTAN environment variable for R
RUN echo "CMDSTAN='/opt/cmdstan/cmdstan-2.34.1'" >> /opt/conda/envs/R/lib/R/etc/Renviron.site

# Set CMDSTAN environment variable for the current session
ENV CMDSTAN="/opt/cmdstan/cmdstan-2.34.1"

# Verify CmdStan installation
RUN /opt/conda/envs/R/bin/R -s -e "Sys.setenv(CMDSTAN='/opt/cmdstan/cmdstan-2.34.1'); library(cmdstanr); cmdstanr::set_cmdstan_path(Sys.getenv('CMDSTAN')); print(cmdstanr::cmdstan_path()); print(cmdstanr::cmdstan_version())"

# Install the release version of rosace
RUN /opt/conda/envs/R/bin/R -s -e "Sys.setenv(CMDSTAN='/opt/cmdstan/cmdstan-2.34.1'); remotes::install_github('pimentellab/rosace@0d469506a02057f6402d6a0b9d075cd5eaa1a177')"
