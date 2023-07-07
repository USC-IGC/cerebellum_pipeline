import argparse
import matplotlib
import numpy as np
import nibabel as nib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.ndimage import binary_erosion

import warnings
warnings.simplefilter('ignore')
plt.axis('off')

# Argument Parsing
desc = ('Convert a nii image to pictures of slices. '
        'If the image and the label image are both given, '
        'their overlay is converted')
parser = argparse.ArgumentParser(description=desc,
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('-i', '--image', required=True,
                    help='The image to convert.')
parser.add_argument('-l', '--label-image',
                    help='The corresponding label image.')
parser.add_argument('-v', '--view', choices=['axial', 'coronal', 'sagittal'],
                    default='axial', help='The view to convert into.')
parser.add_argument('-o', '--output', help='The output folder.')
parser.add_argument('-c', '--color_map', help='The file for colormap')

args = parser.parse_args()

def load_colors(colors_path):
    with open(colors_path) as colors_file:
        lines = colors_file.readlines()
    lines = [l.strip() for l in lines if not l.strip().startswith('#')]
    lines = np.array([list(map(float, l.split()[:5])) for l in lines])
    colors = np.zeros((int(np.max(lines[:, 0])) + 1, 4), dtype=np.uint8)
    indices = lines[:, 0].astype(int)
    colors[indices, :3] = lines[:, 1 : 4].astype(np.uint8)
    colors[indices, -1] = (lines[:, -1] * 255).astype(np.uint8)
    return colors

def assign_colors(label_image, colors):
    colors[0, 3] = 0  # background alpha
    label_image = np.round(label_image).astype(int)
    colorful_label_image = colors[label_image, :]
    return colorful_label_image

def create_images(view_slices, slice_range):
    plt.imshow(np.rot90(bg_image[slice_range]), cmap='gray',alpha=1)
    plt.imshow(np.rot90(label_image_erosion[slice_range]), cmap='afmhot', alpha=0.5)
    plt.imshow(np.rot90(coloured_labels[slice_range]), cmap='afmhot', alpha=0.25)
    plt.axis('off')
    op_name =  args.output+str(view_slices[i]) +".png"
    plt.savefig(op_name, format='png',dpi=1000,transparent=False,bbox_inches='tight',pad_inches=0.0)

# Main Process
bg_image = nib.load(args.image).get_fdata().squeeze()
label = nib.load(args.label_image).get_fdata().squeeze()
cl = load_colors(str(args.color_map))
# Apply erosion to get outlines
label_image_erosion = label.copy()
for l in np.unique(label_image_erosion):
    mask = label_image_erosion == l
    erosion = binary_erosion(mask, iterations=1)
    label_image_erosion[erosion] = 0

coloured_labels = assign_colors(label, cl)

# Define slice values for each region
view_slices = {
    'axial': [31, 38, 43, 44, 46, 49, 52, 53, 55, 56],
    'coronal': [137, 139, 141, 145, 147, 152, 154, 157, 160, 163],
    'sagittal': [60, 69, 74, 78, 84, 88, 94, 97, 113, 117],
}

assert len(view_slices[args.view]) == 10

if args.view == 'axial':
    for i in range(len(view_slices[args.view])):
       create_images(view_slices['axial'],[slice(None), slice(117, 200), view_slices['axial'][i]])
elif args.view == 'coronal':
    for i in range(len(view_slices[args.view])):
        create_images(view_slices['coronal'], [slice(None), view_slices['coronal'][i], slice(13, 90,1)])
elif args.view == 'sagittal':
    for i in range(len(view_slices[args.view])):
        create_images(view_slices['sagittal'], [view_slices['sagittal'][i], slice(110, 190,1), slice(13, 90,1)])

print("Done")



# import argparse
# import matplotlib
# import numpy as np
# import nibabel as nib
# matplotlib.use('Agg')
# import matplotlib.pyplot as plt
# from scipy.ndimage import binary_erosion

# import warnings
# warnings.simplefilter('ignore')
# plt.axis('off')

# # Argument Parsing
# desc = ('Convert a nii image to pictures of slices. '
#         'If the image and the label image are both given, '
#         'their overlay is converted')
# parser = argparse.ArgumentParser(description=desc,
#                                  formatter_class=argparse.ArgumentDefaultsHelpFormatter)

# parser.add_argument('-i', '--image', required=True,
#                     help='The image to convert.')
# parser.add_argument('-l', '--label_image',
#                     help='The corresponding label image.')
# parser.add_argument('-o', '--output', help='The output folder.')
# parser.add_argument('-c', '--color_map', help='The file for colormap')
# parser.add_argument('-t','--text_file',help='Output Text Path')
# parser.add_argument('-s','--subject_name',help='Name of Subject')
# args = parser.parse_args()

# def load_colors(colors_path):
#     with open(colors_path) as colors_file:
#         lines = colors_file.readlines()
#     lines = [l.strip() for l in lines if not l.strip().startswith('#')]
#     lines = np.array([list(map(float, l.split()[:5])) for l in lines])
#     colors = np.zeros((int(np.max(lines[:, 0])) + 1, 4), dtype=np.uint8)
#     indices = lines[:, 0].astype(int)
#     colors[indices, :3] = lines[:, 1 : 4].astype(np.uint8)
#     colors[indices, -1] = (lines[:, -1] * 255).astype(np.uint8)
#     return colors
# nifti_real = []
# def assign_colors(label_image, colors):
#     colors[0, 3] = 0  # background alpha
#     label_image = np.round(label_image).astype(int)
#     #print(np.delete(np.unique(label_image), 0))
#     inds = np.where(label_image!=0)
#     for l in range(len(inds[0])):
#         nifti_real.append([inds[0][l], inds[1][l], inds[2][l]] )
#     #real_pt = nib.affines.apply_affine(aff, nifti_real)
    
    
#     colorful_label_image = colors[label_image, :]
#     return colorful_label_image


# def check(orientation):
#     y = [item[1] for item in nifti_real]
#     z = [item[2] for item in nifti_real]
#     if orientation =="axial":
#         min_,max_ = min(y),max(y)
#         if min_<117 or max_>200:
#             return 0
#         #slice_range = [slice(None), slice(117, 200), val]
#     elif orientation =="sagittal":
#         min_,max_ = min(z),max(z)
#         if min_<13 or max_>90:
#             return 0
#        # slice_range = [val, slice(110, 190), slice(13, 90)]
#     elif orientation == "coronal":
#         min_,max_ = min(z),max(z)
#         if min_<13 or max_>90:
#             return 0
        

# def create_images(view_slices, orientation):
#     fig = plt.figure('QC Image', figsize=(13, 9))
#     plt.rcParams.update({'font.size': 25})
#     plt.figtext(x=0.452, y=0.96, s=str(args.subject_name))
#     #plt.figtext(x=0.452, y=0.92, s=str(args.label_image))
#     for i in range(9):
#         if orientation =="axial": 
#             val = view_slices['axial'][i]
#             slice_range = [slice(None), slice(117, 200), val]
#         if orientation =="coronal": 
#             val = view_slices['coronal'][i]
#             slice_range = [slice(None), val, slice(13, 90)]
#         if orientation =="sagittal": 
#             val = view_slices['sagittal'][i]
#             slice_range =  [val, slice(110, 190), slice(13, 90)]
#         fig.add_subplot(3,3,1+i)
#         plt.imshow(np.rot90(bg_image[slice_range]), cmap='gray',alpha=1)
#         plt.imshow(np.rot90(label_image_erosion[slice_range]), cmap='afmhot', alpha=0.5)
#         #print(slice_range)
#         plt.imshow(np.rot90(coloured_labels[slice_range]), cmap='afmhot', alpha=0.25)
#         plt.axis('off')
#     plt.subplots_adjust(wspace=None, hspace=None)
#     op_name =  args.output+args.subject_name+"_"+orientation+".png"
#     plt.savefig(op_name, format='png')
#     plt.figure().clear()
#     plt.close()
#     plt.cla()
#     plt.clf()
# # Main Process
# bg_image = nib.load(args.image).get_fdata().squeeze()
# aff = nib.load(args.image).affine
# label = nib.load(args.label_image).get_fdata().squeeze()
# cl = load_colors(str(args.color_map))
# # Apply erosion to get outlines
# label_image_erosion = label.copy()
# for l in np.unique(label_image_erosion):
#     mask = label_image_erosion == l
#     erosion = binary_erosion(mask, iterations=1)
#     label_image_erosion[erosion] = 0

# coloured_labels = assign_colors(label, cl)

# # Define slice values for each region
# view_slices = {
#     'axial': [38, 43, 44, 46, 49, 52, 53, 55, 56],
#     'coronal': [139, 141, 145, 147, 152, 154, 157, 160, 163],
#     'sagittal': [60, 69, 74, 78, 84, 88, 94, 97, 117],
# }

# sag = check("sagittal")
# cor = check("coronal")
# ax = check("axial")
# if sag!=0 and cor!=0 and ax!=0:
#     create_images(view_slices,"sagittal")
#     create_images(view_slices,"axial")
#     create_images(view_slices,"coronal")
    
# else:
#     create_images(view_slices,"sagittal")
#     create_images(view_slices,"axial")
#     create_images(view_slices,"coronal")
#     file1 = open(args.text_file, "a+")  # append mode
#     op = str(str(args.image).split('/')[-1].split('.')[0]+"\n")
#     file1.write(op)
#     file1.close()


# print("Done")

