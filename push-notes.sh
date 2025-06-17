#!/bin/bash

# Ruta al repositorio de notas
repo_dir="$HOME/repos/per/notas"

# Verificar si el directorio existe
if [[ ! -d "$repo_dir/.git" ]]; then
    echo "Error: El directorio '$repo_dir' no es un repositorio Git válido."
    exit 1
fi

# Cambiar al directorio del repositorio
cd "$repo_dir" || exit

# Generar mensaje de commit por defecto si no se proporciona uno
if [[ -z "$1" ]]; then
    current_date=$(date '+%Y-%m-%d %H:%M:%S')
    file_changes=$(git status --short | grep -E "^[ A|M]" | awk '{print $2}' | xargs)
    if [[ -z "$file_changes" ]]; then
        echo "No hay cambios para realizar commit."
        exit 0
    fi
    commit_message="[$current_date] Actualización: $file_changes"
else
    commit_message="$1"
fi

# Agregar cambios, hacer commit y push
git add .
git commit -m "$commit_message"
if git push; then
    echo "Cambios subidos exitosamente al repositorio."
else
    echo "Error al subir los cambios. Verifica tu conexión o configuración de Git."
    exit 1
fi
