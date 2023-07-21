import os
import argparse

desc = ('checks if csvs have been generated in the AC3 output folder')

formatter = argparse.ArgumentDefaultsHelpFormatter
parser = argparse.ArgumentParser(description=desc, formatter_class=formatter)
parser.add_argument('-i', '--input', required=True,
                    help='The PARENT Folder you want to check.')
args = parser.parse_args()
parent = str(args.input)
print("Started")
subjects = [f.path for f in os.scandir(parent) if f.is_dir()]
list_subjects = []
count = 0
for sub_id in subjects:
    count+=1
    #print(len(os.listdir(sub_id)))
    #print(os.listdir(sub_id))
    files_in_folder = os.listdir(sub_id)
    flag =False
    for f in files_in_folder:
        if f.endswith(".csv"):flag=True
    if flag==False:
        list_subjects.append(sub_id.split("/")[-1])

print(len(list_subjects)," failed of ",count)
file = open('subjects_without_csv.txt','w')
for sub in list_subjects:
	file.write(sub+"\n")
file.close()
