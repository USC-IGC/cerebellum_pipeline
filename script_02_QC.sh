#!/bin/bash
# 06/27/2023
# Cerebellum QC
# This script is to be run on the outputs of script_01_AC3.sh
# Written by Iyad Ba Gari and Siddharth Narula

function Usage(){
    cat << USAGE

Usage:

$(basename "$0") --subject <subjectID> --input </path/mni/xxxx_n4_mni.nii.gz> --slice </path/parc/xxxx_n4_mni_seg_post.nii.gz> --outdir <output/directory> --imagegen <cerebellum_image_generator.py/path> --label <colormap.txt> --bbfile <boundingboxfile/path/>

Mandatory arguments:
    --subject   Provide a subject ID
    --input     Input image (This is the /mni/xxxx_n4_mni.nii.gz inside AC3 output directory of a subject)
    --slice     Slice image (This is the /parc/xxx_n4_mni_seg_post.nii.gz  inside AC3 output directory of a subject)
    --outdir    Output directory to store pngs
    --imagegen  cerebellum_image_generator.py script path
    --label     colormap.txt file path
    --bbfile    Path along with textfile name to store bounding box failed subjects

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
        --slice)
            slice_image=$2
            shift 2
            ;;
        --outdir)
            output_dir=$2
            shift 2
            ;;
        --imagegen)
            image_generator_dir=$2
            shift 2
            ;;
        --label)
            colormap_txt=$2
            shift 2
            ;;
        --bbfile)
            bbfile=$2
            shift 2
            ;;
        *) # Unexpected option
            Usage >&2
            ;;
    esac
done

# Checking mandatory arguments
if [[ -z ${subjectID} || -z ${input_image} ||  -z ${slice_image} || -z ${output_dir} || -z ${image_generator_dir} || -z ${colormap_txt} || -z ${bbfile} ]]; then
	echo "ERROR: --subject --input, --slice, --outdir, --imagegen --label --bbfile are mandatory arguments. Please see usage: \n"
    Usage >&2
fi

echo "Running QC for ${subjectID}"
echo "Input Image: ${input_image}"
echo "Slice Image: ${slice_image}"
echo "Output Directory: ${output_dir}/img/${subjectID}"
rm -rf ${output_dir}/img/${subjectID}
mkdir -p ${output_dir}/img/${subjectID}

echo "Cerebellum image generation script located at: ${image_generator_dir}"
echo "Colormap text file: ${colormap_txt}"

python ${image_generator_dir}/cerebellum_image_generator.py -i $input_image -l $slice_image -c ${colormap_txt}/colormap.txt -o ${output_dir}/img/${subjectID}/ -t ${bbfile} -s ${subjectID} 

chmod -R 770 ${output_dir}/img/${subjectID}

echo "Done generating all pngs at: ${output_dir}/img/${subjectID}"
echo "Bounding box failed subject info at: $bbfile"
