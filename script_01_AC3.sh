#!/bin/bash
# 06/27/2023
# Wrapper for ACAPULCO 3.0
# This script is to be run on correctly oriented T1 images to perform Cerebellum Parcellation
# Written by Iyad Ba Gari and Siddharth Narula

function Usage(){
    cat << USAGE

Usage:

$(basename "$0") --subject <subjectID> --input <T1/image/path> --outdir <output/directory> --container <singularity/directory> --bind <singularity/bind/directory> 

Mandatory arguments:
	--subject	Provide a subject ID
	--input		Input T1 image path
	--outdir	Output directory
	--container	Directory where singularity container is located
	--bind      Directory to which ingularity container is to be binded

Please provide absolute path in all arguments

USAGE
    exit 1
}

if [[ $# -eq 0 ]]; then
    Usage >&2
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            Usage >&2
            exit 0
            ;;
        --subject)
            subjectID=$2
            shift 2
            ;;
        --input)
            input_image=$2
            shift 2
            ;;
        --outdir)
            output_dir=$2
            shift 2
            ;;
        --container)
            singularity_container_dir=$2
            shift 2
            ;;
        --bind)
            bind_dir=$2
            shift 2
            ;;
        *) # Unexpected option
            Usage >&2
            ;;
    esac
done

# Checking mandatory arguments
if [[ -z ${subjectID} || -z ${input_image} ||  -z ${output_dir} || -z ${singularity_container_dir} || -z ${bind_dir} ]]; then
	echo "ERROR: --subject --input, --outdir, --container, --bind are mandatory arguments. Please see usage: \n"
    Usage >&2
fi

# Create Output Directory
echo "Running ACUPULCO 3 for ${subjectID}"
echo "Input Image: ${input_image}"
echo "Output Directory: ${output_dir}/${subjectID}"
rm -rf ${output_dir}/${subjectID}
mkdir -p ${output_dir}/${subjectID}

# Load Singularity 
ml load singularity/3.4.1
which singularity
echo "Singularity located at: ${singularity_container_dir}"
echo "Singularity loaded"

# Mount singularity
echo "Singularity Bind Path: ${bind_dir}"

# Command to run AC3
CMD="singularity run --cleanenv -B ${bind_dir}:${bind_dir} ${singularity_container_dir}/acapulco_030.sif -i ${input_image} -o ${output_dir}/${subjectID}";

echo "Running: ${CMD}"
eval $CMD

echo "ACUPULCO 3.0 outputs available for ${subjectID}"