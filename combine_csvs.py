#!/bin/bash
# Combine csv
# This script is to be run on the outputs of script_01_AC3.sh
# Written by Siddharth Narula
# -*- coding: utf-8 -*-
#Not DONE

import os
import pandas as pd
import csv
import argparse
desc = ('Merge CSV Files from a folder')
formatter = argparse.ArgumentDefaultsHelpFormatter
parser = argparse.ArgumentParser(description=desc, formatter_class=formatter)

parser.add_argument('-i', '--input', required=True,
                    help='The Input Path where all the folders containing CSVs are located')
parser.add_argument('-o', '--output',
                    help='The corresponding output path for the csv file')
args = parser.parse_args()
parent = str(args.input)
print("Started")
subjects = [f.path for f in os.scandir(parent) if f.is_dir()]
list_subjects = []
file_paths = []
columns = ['Name','Background','Corpus Medullare','Left I-III','Right I-III','Left IV','Rigt IV','Left V','Right V','Vermis VI','Left VI','Right VI','Vermis VII','Left Crus I','Left Crus II','Left VIIB','Right Crus I','Right Crus II','Right VIIB','Vermis VIII','Left VIIIA','Left VIIIB','Right VIIIA','Right VIIIB','Vermis IX','Left IX','Right IX','Vermis X','Left X','Right X']
dict_columns = dict(zip(columns, [None]*len(columns)))
for sub_id in subjects:
    files_in_folder = os.listdir(sub_id)
    flag =False
    for f in files_in_folder:
        if f.endswith(".csv"):
            file_path = sub_id+"/"+f
            file_paths.append(file_path)
    if flag==False:
        list_subjects.append(sub_id.split("/")[-1])
main_dict =[]
for f in file_paths:
    dict_columns = dict(zip(columns, [None]*len(columns)))
    file = pd.read_csv(f)
    important_info = file[['name','volume']]
    #print(important_info['name'])
    xx= str(f.split("/")[-1])
    dict_columns['Name']= '_'.join(xx.split("_")[0:4])
    for name,vol in zip(important_info['name'],important_info['volume']):
        #print(files_in_folder.index(f))   
        dict_columns[name]=vol
    main_dict.append(dict_columns)
output = str(args.output)+"Cerebellum_data_all_csvs.csv"
with open(output, 'w', encoding='UTF8',newline='') as f:
    writer = csv.DictWriter(f, fieldnames=columns)
    writer.writeheader()
    writer.writerows(main_dict)
print("Done part 1")
