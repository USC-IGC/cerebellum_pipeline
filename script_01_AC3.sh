#!/bin/bash
# Wrapper for ACAPULCO 3.0
# This script is to be run on correctly oriented T1 images to perform Cerebellum Parcellation
# Written by Iyad Ba Gari, Siddharth Narula and Sunanda Somu

function Usage(){
    cat << USAGE

Usage:

$(basename "$0") --subject <subjectID> --input <T1/image/path/or/UNIT/image/path> --outdir <output/directory> --container <singularity/directory> --bind <singularity/bind/directory> --mp2rage <mp2rage/acquisition/true/false> --inv2image <inv2image/path/(optional)> --afnipath <AFNI/software/path> --rpath <R/software/path> --pythonpath <python/software/path> 

Mandatory arguments:
    --subject	    Provide a subject ID
    --input	    Input T1 image with absolute path or in case of MP2RAGE acquisition it will be the full path of the UNIT image
    --outdir	    Output directory
    --container	    Directory where singularity container is located
    --bind          Directory to which ingularity container is to be binded
    --mp2rage       If the input image is an MP2RAGE acquisition enter true else false
    --inv2image     Path to the second inversion image (INV2) image of a subject if it is MP2RAGE acquired
    --afnipath      path to AFNI software (optional)
    --rpath         path to R software (optional)
    --pythonpath    Path to PYTHON software (optional)

Please provide absolute path in all arguments
If your image is MP2RAGE acquired please ensure that AFNI, R and PYTHON are installed on your system before running this script

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
        --mp2rage)
            acq=$2
            shift 2
            ;;
        --inv2image)
            inv2image=$2
            shift 2
            ;;
        --afnipath)
            afnipath=$2
            shift 2
            ;;
        --rpath)
            rpath=$2
            shift 2
            ;;
        --pythonpath)
            python=$2
            shift 2
            ;;
        *) # Unexpected option
            Usage >&2
            ;;
    esac
done

# Checking mandatory arguments
if [[ -z ${subjectID} || -z ${input_image} ||  -z ${output_dir} || -z ${singularity_container_dir} || -z ${bind_dir} || -z ${acq} ]]; then
	echo "ERROR: --subject --input, --outdir, --container, --bind --mp2rage are mandatory arguments. Please see usage: \n"
    Usage >&2
fi

# Create Output Directory
echo "Running ACUPULCO 3 for ${subjectID}"
echo "Input Image: ${input_image}"
echo "Output Directory: ${output_dir}/${subjectID}"
rm -rf ${output_dir}/${subjectID}
mkdir -p ${output_dir}/${subjectID}

# For MP2RAGE
if [[ "$acq" == true ]]
then
    export PATH=$PATH:$afnipath
    export R_LIBS=$rpath
    export PYTHONPATH=$python
    # set up tab completion for AFNI programs
    if [ -f $HOME/.afni/help/all_progs.COMP.bash ]
    then
        source $HOME/.afni/help/all_progs.COMP.bash
    fi
    export AFNI_NIFTI_TYPE_WARN=NO
    export AFNI_ENVIRON_WARNINGS=NO

    3dcopy $inv2image ${output_dir}/${subjectID}/${subjectID}_bfc.nii
    out_name=${subjectID}_clean.nii
    int_max=$(3dinfo -dmaxus $inv2image)
    int_min=$(3dinfo -dminus $inv2image)
    3dcalc -overwrite -a ${output_dir}/${subjectID}/${subjectID}_bfc.nii -expr "( a - $int_min ) / ( $int_max - $int_min )" -prefix ${output_dir}/${subjectID}/${subjectID}_intnorm.nii
    3dcalc -overwrite -a $input_image -b  ${output_dir}/${subjectID}/${subjectID}_intnorm.nii -expr "a * b" -prefix ${output_dir}/${subjectID}/$out_name
    gzip  ${output_dir}/${subjectID}/$out_name
    rm ${output_dir}/${subjectID}/${subjectID}_bfc.nii ${output_dir}/${subjectID}/${subjectID}_intnorm.nii
    input_image=${output_dir}/${subjectID}/${out_name}.gz
    echo "AFNI is run on the unit image, new input image to ACAPULCO: $input_image"
fi

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

chmod 770 ${output_dir}/${subjectID}


