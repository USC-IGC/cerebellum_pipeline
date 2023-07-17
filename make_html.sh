#!/bin/bash
# 06/27/2023
# Cerebellum QC Html
# This script is to be run on the outputs of script_02_QC.sh
# Written by Sunanda Somu and Iyad Ba Gari

function Usage(){
    cat << USAGE

Usage:

$(basename "$0") --subjects <subjects_list.txt> --pngdir <png/directory> --name <html/name>

Mandatory arguments:
	--subjects	Text file containing a list of subject IDs
	--pngdir	Directory containing the img folder
	--name		Name of the html to be generated

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
        --subjects)
            subjectID=$2
            shift 2
            ;;
        --pngdir)
            png_dir=$2
            shift 2
            ;;
        --name)
            html_name=$2
            shift 2
            ;;
        *) # Unexpected option
            Usage >&2
            ;;
    esac
done
echo $png_dir
echo $subjectID

# Create QC webpage
mkdir -p ${png_dir}
cd $png_dir

# Generate Coronal view Html
echo "<html>"                                                                           >> ${html_name}_coronal.html
echo "<style type=\"text/css\">"                                                        >> ${html_name}_coronal.html
echo "body {"                                                                           >> ${html_name}_coronal.html
echo "  background-color: black;"                                                       >> ${html_name}_coronal.html
echo "  color: white;"                                                                  >> ${html_name}_coronal.html
echo "}"                                                                                >> ${html_name}_coronal.html
echo "p {"                                                                              >> ${html_name}_coronal.html
echo "  font-size: 5px;"                                                                >> ${html_name}_coronal.html  # Set the desired text size
echo "  font-family: Arial, geneva;"                                                    >> ${html_name}_coronal.html  # Set the desired font
echo "}"                                                                                >> ${html_name}_coronal.html
echo ".image-container {"                                                               >> ${html_name}_coronal.html
echo "  display: grid;"                                                                 >> ${html_name}_coronal.html
echo "  grid-template-columns: repeat(5, 1fr);"                                         >> ${html_name}_coronal.html
echo "  gap: 1px;"                                                                      >> ${html_name}_coronal.html
echo "  width: auto;"                                                                   >> ${html_name}_coronal.html
echo "  height: auto;"                                                                  >> ${html_name}_coronal.html
echo "}"                                                                                >> ${html_name}_coronal.html
echo "</style>"                                                                         >> ${html_name}_coronal.html
echo "<body>"                                                                           >> ${html_name}_coronal.html
echo "<script>var all_subs = [];</script>"			                                    >> ${html_name}_coronal.html

for subj_id in `cat $subjectID`; do
    escaped_subj_id=$(echo "$subj_id" | sed 's/[\/&]/\\&/g')
    echo "<div style=\"border: 0.5px solid rgb(31.4, 78.4, 47.1);\">"                                                                                           >> ${html_name}_coronal.html
	echo "<script> all_subs.push('${escaped_subj_id}'); </script>"                                                                                              >> ${html_name}_coronal.html
    echo "<div class=\"image-container\">"                                                                                                                      >> ${html_name}_coronal.html
    echo "<img src=\"img/${escaped_subj_id}/coronal147.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_coronal.html
    echo "<img src=\"img/${escaped_subj_id}/coronal152.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_coronal.html
    echo "<img src=\"img/${escaped_subj_id}/coronal154.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_coronal.html
    echo "<img src=\"img/${escaped_subj_id}/coronal157.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_coronal.html
    echo "<img src=\"img/${escaped_subj_id}/coronal160.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_coronal.html
    echo "<button onclick=\"saveSubjectIDs('${escaped_subj_id}', 'button_${escaped_subj_id}')\" id=\"button_${escaped_subj_id}\">${escaped_subj_id}</button> <textarea id=\"notes_${escaped_subj_id}\" rows=\"1\" cols=\"300\"></textarea>"  >> ${html_name}_coronal.html
    echo "</div>"                                                                                                                                               >> ${html_name}_coronal.html
    echo "</div>"                                                                                                                                               >> ${html_name}_coronal.html
    echo "<br>"                                                                                                                                                 >> ${html_name}_coronal.html
done;

echo "<br/> <button onclick = \"makeCSV()\">Download CSV</button>"                                                                                              >> ${html_name}_coronal.html

echo "<script>"                                                                                                                                                 >> ${html_name}_coronal.html
echo "var subjectIDs = [];"                                                                                                                                     >> ${html_name}_coronal.html
echo "var data = [];"                                                                                                                                           >> ${html_name}_coronal.html
echo "var notes = {};"                                                                                                                                          >> ${html_name}_coronal.html

echo "function saveSubjectIDs(escaped_subj_id, buttonId) {"                                                                                                     >> ${html_name}_coronal.html
echo "  var data = subjectIDs.push(escaped_subj_id);"                                                                                                           >> ${html_name}_coronal.html
echo "  var button = document.getElementById(buttonId);"                                                                                                        >> ${html_name}_coronal.html
echo "  button.disabled = true;"                                                                                                                                >> ${html_name}_coronal.html
echo "  console.log(escaped_subj_id);"                                                                                                                          >> ${html_name}_coronal.html
echo "}"                                                                                                                                                        >> ${html_name}_coronal.html

echo "function makeCSV(){"																>> ${html_name}_coronal.html
echo "	for(var i = 0; i<all_subs.length; i++){"										>> ${html_name}_coronal.html
echo "		if(subjectIDs.includes(all_subs[i])){"							            >> ${html_name}_coronal.html
echo "          var note = document.getElementById('notes_' + all_subs[i]).value;"      >> ${html_name}_coronal.html
echo "          notes[all_subs[i]] = note;"                                             >> ${html_name}_coronal.html
echo "			data.push(all_subs[i] + ',QC_Fail' + note + '\n');"					    >> ${html_name}_coronal.html
echo "		}"																	        >> ${html_name}_coronal.html
echo "		else{"																	    >> ${html_name}_coronal.html
echo "			data.push(all_subs[i] + ',QC_Pass\n');"					                >> ${html_name}_coronal.html
echo "		}"																	        >> ${html_name}_coronal.html
echo "	}"																	            >> ${html_name}_coronal.html

echo "	const file = new File(data, 'AC3_QC_Coronal.csv', {type: \"text/plain\"});"		>> ${html_name}_coronal.html
echo "	const link = document.createElement('a');"										>> ${html_name}_coronal.html
echo "  const url = URL.createObjectURL(file);"										    >> ${html_name}_coronal.html
echo "	link.href = url;"															    >> ${html_name}_coronal.html
echo "  link.download = file.name;"													    >> ${html_name}_coronal.html
echo "  document.body.appendChild(link);"											    >> ${html_name}_coronal.html
echo "  link.click();"																    >> ${html_name}_coronal.html
echo "	document.body.removeChild(link);"											    >> ${html_name}_coronal.html
echo "  window.URL.revokeObjectURL(url);"											    >> ${html_name}_coronal.html
echo "}"																	            >> ${html_name}_coronal.html
echo "</script>"                                                                        >> ${html_name}_coronal.html

echo "</body>"                                                                          >> ${html_name}_coronal.html
echo "</html>"                                                                          >> ${html_name}_coronal.html

# Generate Sagittal view Html
echo "<html>"                                                                           >> ${html_name}_sagittal.html
echo "<style type=\"text/css\">"                                                        >> ${html_name}_sagittal.html
echo "body {"                                                                           >> ${html_name}_sagittal.html
echo "  background-color: black;"                                                       >> ${html_name}_sagittal.html
echo "  color: white;"                                                                  >> ${html_name}_sagittal.html
echo "}"                                                                                >> ${html_name}_sagittal.html
echo "p {"                                                                              >> ${html_name}_sagittal.html
echo "  font-size: 5px;"                                                                >> ${html_name}_sagittal.html  # Set the desired text size
echo "  font-family: Arial, geneva;"                                                    >> ${html_name}_sagittal.html  # Set the desired font
echo "}"                                                                                >> ${html_name}_sagittal.html
echo ".image-container {"                                                               >> ${html_name}_sagittal.html
echo "  display: grid;"                                                                 >> ${html_name}_sagittal.html
echo "  grid-template-columns: repeat(5, 1fr);"                                         >> ${html_name}_sagittal.html
echo "  gap: 5px;"                                                                      >> ${html_name}_sagittal.html
echo "  width: auto;"                                                                   >> ${html_name}_sagittal.html
echo "  height: auto;"                                                                  >> ${html_name}_sagittal.html
echo "}"                                                                                >> ${html_name}_sagittal.html
echo "</style>"                                                                         >> ${html_name}_sagittal.html
echo "<body>"                                                                           >> ${html_name}_sagittal.html
echo "<script>var all_subs = [];</script>"			                                    >> ${html_name}_sagittal.html

for subj_id in `cat $subjectID`; do
    escaped_subj_id=$(echo "$subj_id" | sed 's/[\/&]/\\&/g')
    echo "<div style=\"border: 0.5px solid rgb(31.4, 78.4, 47.1);\">"                                                                                           >> ${html_name}_sagittal.html
	echo "<script> all_subs.push('${escaped_subj_id}'); </script>"                                                                                              >> ${html_name}_sagittal.html
    echo "<div class=\"image-container\">"                                                                                                                      >> ${html_name}_sagittal.html
    echo "<img src=\"img/${escaped_subj_id}/sagittal84.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_sagittal.html
    echo "<img src=\"img/${escaped_subj_id}/sagittal88.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_sagittal.html
    echo "<img src=\"img/${escaped_subj_id}/sagittal94.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_sagittal.html
    echo "<img src=\"img/${escaped_subj_id}/sagittal97.png\" width=\"100%\" loading=\"lazy\">"                                                                  >> ${html_name}_sagittal.html
    echo "<img src=\"img/${escaped_subj_id}/sagittal113.png\" width=\"100%\" loading=\"lazy\">"                                                                 >> ${html_name}_sagittal.html
    echo "<button onclick=\"saveSubjectIDs('${escaped_subj_id}', 'button_${escaped_subj_id}')\" id=\"button_${escaped_subj_id}\">${escaped_subj_id}</button> <textarea id=\"notes_${escaped_subj_id}\" rows=\"1\" cols=\"300\"></textarea>"  >> ${html_name}_sagittal.html
    echo "</div>"                                                                                                                                               >> ${html_name}_sagittal.html
    echo "</div>"                                                                                                                                               >> ${html_name}_sagittal.html
    echo "<br>"                                                                                                                                                 >> ${html_name}_sagittal.html
done;

echo "<br/> <button onclick = \"makeCSV()\">Download CSV</button>"                                                                                              >> ${html_name}_sagittal.html

echo "<script>"                                                                                                                                                 >> ${html_name}_sagittal.html
echo "var subjectIDs = [];"                                                                                                                                     >> ${html_name}_sagittal.html
echo "var data = [];"                                                                                                                                           >> ${html_name}_sagittal.html
echo "var notes = {};"                                                                                                                                          >> ${html_name}_sagittal.html

echo "function saveSubjectIDs(escaped_subj_id, buttonId) {"                                                                                                     >> ${html_name}_sagittal.html
echo "  var data = subjectIDs.push(escaped_subj_id);"                                                                                                           >> ${html_name}_sagittal.html
echo "  var button = document.getElementById(buttonId);"                                                                                                        >> ${html_name}_sagittal.html
echo "  button.disabled = true;"                                                                                                                                >> ${html_name}_sagittal.html
echo "  console.log(escaped_subj_id);"                                                                                                                          >> ${html_name}_sagittal.html
echo "}"                                                                                                                                                        >> ${html_name}_sagittal.html

echo "function makeCSV(){"																>> ${html_name}_sagittal.html
echo "	for(var i = 0; i<all_subs.length; i++){"										>> ${html_name}_sagittal.html
echo "		if(subjectIDs.includes(all_subs[i])){"							            >> ${html_name}_sagittal.html
echo "          var note = document.getElementById('notes_' + all_subs[i]).value;"      >> ${html_name}_sagittal.html
echo "          notes[all_subs[i]] = note;"                                             >> ${html_name}_sagittal.html
echo "			data.push(all_subs[i] + ',QC_Fail' + note + '\n');"					    >> ${html_name}_sagittal.html
echo "		}"																	        >> ${html_name}_sagittal.html
echo "		else{"																	    >> ${html_name}_sagittal.html
echo "			data.push(all_subs[i] + ',QC_Pass\n');"					                >> ${html_name}_sagittal.html
echo "		}"																	        >> ${html_name}_sagittal.html
echo "	}"																	            >> ${html_name}_sagittal.html

echo "	const file = new File(data, 'AC3_QC_Sagittal.csv', {type: \"text/plain\"});"	>> ${html_name}_sagittal.html
echo "	const link = document.createElement('a');"										>> ${html_name}_sagittal.html
echo "  const url = URL.createObjectURL(file);"										    >> ${html_name}_sagittal.html
echo "	link.href = url;"															    >> ${html_name}_sagittal.html
echo "  link.download = file.name;"													    >> ${html_name}_sagittal.html
echo "  document.body.appendChild(link);"											    >> ${html_name}_sagittal.html
echo "  link.click();"																    >> ${html_name}_sagittal.html
echo "	document.body.removeChild(link);"											    >> ${html_name}_sagittal.html
echo "  window.URL.revokeObjectURL(url);"											    >> ${html_name}_sagittal.html
echo "}"																	            >> ${html_name}_sagittal.html
echo "</script>"                                                                        >> ${html_name}_sagittal.html

echo "</body>"                                                                          >> ${html_name}_sagittal.html
echo "</html>"                                                                          >> ${html_name}_sagittal.html

echo "Htmls generated at: $png_dir"

chmod 770 ${html_name}_sagittal.html
chmod 770 ${html_name}_coronal.html