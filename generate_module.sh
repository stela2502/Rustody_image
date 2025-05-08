#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <path> <version> <name>"
    exit 1
fi

# Variables from arguments
PATH_ARG=$1
VERSION=$2
IMAGE_NAME=$3

# Define the output module file path
MODULE_FILE="modules/${IMAGE_NAME}/${VERSION}.lua"

# Ensure the directory exists
mkdir -p "$(dirname "$MODULE_FILE")"

# Create the module file
cat <<EOF 
help([[Rustody mapps single cell fastq to either a targetet set of genes
or a whole genome index.
Usage: Rustody <command you want to run> ]])

local base = pathJoin("${PATH_ARG}")

--setenv("ANACONDA_ROOT",base)
prepend_path("PATH",pathJoin( base ,"bin"))


whatis("Name         : Rustody singularity image")
whatis("Version      : Rustody 2.2.2")
whatis("Category     : Image")
whatis("Description  : Check the documentation on GitHub https://github.com/stela2502/Rustody_singularity")
whatis("Installed on : 22/08/2024")
whatis("Modified on  : --- ")
whatis("Installed by : stefanl")

family("chipanalysisimage")

EOF


