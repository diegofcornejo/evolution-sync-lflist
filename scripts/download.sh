#!/bin/bash

# Create directories
mkdir -p projectignis
mkdir -p koishi

# Download the latest LFLists repository
# curl -L https://github.com/ProjectIgnis/LFLists/archive/refs/heads/master.zip -o projectignis/LFLists.zip
# unzip projectignis/LFLists.zip -d projectignis
# rm projectignis/LFLists.zip

# Clone the repository
git clone https://github.com/ProjectIgnis/LFLists projectignis

# Download the latest lflist.conf from YGOMobile-cn-ko-en
curl -L https://raw.githubusercontent.com/fallenstardust/YGOMobile-cn-ko-en/master/mobile/assets/data/conf/lflist.conf -o koishi/lflist.conf

# Split lflist.conf into multiple files
year=$(date +"%Y")
file_path="koishi/lflist.conf"
output_dir="koishi"

awk -v year="$year" -v output_dir="$output_dir" '
/^!/{if (out) close(out); out=""; if ($1 ~ "^!" year) {filename=substr($0, 2) ".KS.lflist.conf"; out=output_dir "/" filename; print "#[" substr($0, 2) "]\n" $0 > out; next}}
out {print >> out}' $file_path

# List the generated files from the split
echo "Archivos generados en la carpeta koishi:"
ls -l koishi

# Show the content of a specific file, just for testing
# if [ -f koishi/2024.4\ TCG.conf ]; then
#   echo "Contenido del archivo koishi/2024.4 TCG.conf:"
#   cat koishi/2024.4\ TCG.conf
# else
#   echo "El archivo koishi/2024.4 TCG.conf no existe."
# fi

# Delete lfList.conf
rm $file_path
