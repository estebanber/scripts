#!/bin/bash

# Archivo con los comandos en formato especial
commands_file="comandos.txt"

# Leer el archivo de comandos y extraer las descripciones
descriptions=$(awk -F "@@@ " '{print $2}' "$commands_file")
# Mostrar las descripciones en rofi y obtener el comando seleccionado
selected_description=$(echo "$descriptions" | rofi -dmenu -p "Seleccione un comando:" -markup)
# Buscar el comando correspondiente a la descripción seleccionada
selected_command=$(grep -F "@@@ $selected_description" "$commands_file" | awk -F " @@@" '{print $1}')
echo "$selected_command"

echo -n "$selected_command" | xclip -selection clipboard
#echo -n "$selected_command" | xdotool type --file -
