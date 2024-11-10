#!/bin/bash
# Ruta del directorio donde está el script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repos_file="$script_dir/repos.txt"

# Función para crear estructura de directorios en el path indicado
create_repo_structure() {
    local base_path=$1
    mkdir -p "$base_path/per" "$base_path/pro" "$base_path/3rd"
    echo "Estructura de directorios creada en $base_path"
}

# Función para clonar repositorios según una categoría
clone_repos() {
    local category=$1
    local dest_folder=$2
    local started=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "$category" ]]; then
            started=1
            continue
        elif [[ "$line" == \#* ]]; then
            started=0
        fi

        if [[ $started -eq 1 && -n "$line" ]]; then
            # Extrae el nombre del repositorio de la URL
            repo_name=$(basename -s .git "$line")
            repo_path="$dest_folder/$repo_name"

            # Verifica si la carpeta ya existe antes de clonar
            if [[ -d "$repo_path" ]]; then
                echo "El repositorio '$repo_name' ya existe en '$repo_path'. Saltando clonación."
            else
                git clone "$line" "$repo_path"
            fi
        fi
    done < "$repos_file"
}

# Comprobación de argumentos
if [[ $# -lt 2 ]]; then
    echo "Uso: $0 <comando> <ruta_base>"
    echo "Comandos disponibles:"
    echo "  crear_estructura     - Crear estructura de directorio para el repositorio"
    echo "  clonar_personal      - Clonar repositorios personales en repos/per"
    echo "  clonar_3rd_party     - Clonar repositorios de terceros en repos/3rd"
    echo "  clonar_profesional    - Clonar repositorios profesionales en repos/pro"
    exit 1
fi

# Ejecutar el comando seleccionado
case $1 in
    crear_estructura)
        create_repo_structure "$2"
        ;;
    clonar_personal)
        clone_repos "#Personal" "$2/per"
        ;;
    clonar_3rd_party)
        clone_repos "#3rd-party" "$2/3rd"
        ;;
    clonar_profesional)
        clone_repos "#Profesional" "$2/pro"
        ;;
    *)
        echo "Comando no reconocido: $1"
        exit 1
        ;;
esac
