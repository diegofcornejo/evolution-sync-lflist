#!/bin/bash

# Crear directorios necesarios
mkdir -p projectignis
mkdir -p koishi

# Descargar el archivo de ProjectIgnis
curl -L https://github.com/ProjectIgnis/LFLists/archive/refs/heads/master.zip -o projectignis/LFLists.zip
unzip projectignis/LFLists.zip -d projectignis
rm projectignis/LFLists.zip

# Descargar el archivo lflist.conf de YGOMobile
curl -L https://raw.githubusercontent.com/fallenstardust/YGOMobile-cn-ko-en/master/mobile/assets/data/conf/lflist.conf -o koishi/lflist.conf

# Dividir lflist.conf en múltiples archivos
year=$(date +"%Y")
file_path="koishi/lflist.conf"
output_dir="koishi"

awk -v year="$year" -v output_dir="$output_dir" '
/^!/{if (out) close(out); out=""; if ($1 ~ "^!" year) {filename=substr($0, 2) ".conf"; out=output_dir "/" filename; print "#[" substr($0, 2) "]\n" $0 > out; next}}
out {print >> out}' $file_path

# Listar archivos en el directorio koishi
echo "Archivos generados en la carpeta koishi:"
ls -l koishi

# Mostrar el contenido de un archivo específico
if [ -f koishi/2024.4\ TCG.conf ]; then
  echo "Contenido del archivo koishi/2024.4 TCG.conf:"
  cat koishi/2024.4\ TCG.conf
else
  echo "El archivo koishi/2024.4 TCG.conf no existe."
fi
