#!/usr/bin/env bash

set -uo pipefail

usage() {
    cat <<EOF
Usage:
  $(basename "$0") <library_name> [root_dir]

Arguments:
  library_name   Package/distribution name to check (e.g. requests, numpy, pandas)
  root_dir       Root folder to search under (default: current directory)

Examples:
  $(basename "$0") requests
  $(basename "$0") numpy /home/user/projects
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage
    exit 1
fi

LIB_NAME="$1"
ROOT_DIR="${2:-.}"

if [[ ! -d "$ROOT_DIR" ]]; then
    echo "Error: root directory does not exist: $ROOT_DIR" >&2
    exit 1
fi

# Inline Python snippet to check package version
PY_CHECK=$(cat <<'PY'
import sys
try:
    from importlib import metadata
except ImportError:
    import importlib_metadata as metadata

name = sys.argv[1]
try:
    print(metadata.version(name))
except metadata.PackageNotFoundError:
    print("NOT INSTALLED")
except Exception as e:
    print(f"ERROR: {e}")
PY
)

# Print header
printf "%-20s | %-60s | %-20s\n" "ENV TYPE" "PATH / IDENTIFIER" "VERSION"
printf "%-20s-+-%-60s-+-%-20s\n" "$(printf '%.0s-' {1..20})" "$(printf '%.0s-' {1..60})" "$(printf '%.0s-' {1..20})"

found_any=0

# ──────────────────────────────────────────────
# 1. venv / virtualenv  (pyvenv.cfg marker)
# ──────────────────────────────────────────────
while IFS= read -r -d '' cfg; do
    found_any=1
    venv_dir="$(dirname "$cfg")"

    if [[ -x "$venv_dir/bin/python" ]]; then
        py="$venv_dir/bin/python"
    elif [[ -x "$venv_dir/Scripts/python.exe" ]]; then
        py="$venv_dir/Scripts/python.exe"
    elif [[ -x "$venv_dir/Scripts/python" ]]; then
        py="$venv_dir/Scripts/python"
    else
        printf "%-20s | %-60s | %-20s\n" "venv" "$venv_dir" "NO PYTHON"
        continue
    fi

    version="$("$py" - "$LIB_NAME" 2>/dev/null <<< "$PY_CHECK")"
    printf "%-20s | %-60s | %-20s\n" "venv" "$venv_dir" "$version"
done < <(find "$ROOT_DIR" -type f -name "pyvenv.cfg" -print0 2>/dev/null | sort -z)

# ──────────────────────────────────────────────
# 2. Conda environments
# ──────────────────────────────────────────────
if command -v conda &>/dev/null; then
    # Collect all conda env paths via `conda info --envs`
    while IFS= read -r env_path; do
        [[ -z "$env_path" ]] && continue
        found_any=1

        if [[ -x "$env_path/bin/python" ]]; then
            py="$env_path/bin/python"
        elif [[ -x "$env_path/python.exe" ]]; then
            py="$env_path/python.exe"
        else
            printf "%-20s | %-60s | %-20s\n" "conda" "$env_path" "NO PYTHON"
            continue
        fi

        version="$("$py" - "$LIB_NAME" 2>/dev/null <<< "$PY_CHECK")"
        printf "%-20s | %-60s | %-20s\n" "conda" "$env_path" "$version"
    done < <(conda info --envs 2>/dev/null \
        | grep -v '^\s*#' \
        | grep -v '^\s*$' \
        | awk '{print $NF}')
else
    echo "(conda not found — skipping conda environments)" >&2
fi

# ──────────────────────────────────────────────
# 3. pyenv versions
# ──────────────────────────────────────────────
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
if [[ -d "$PYENV_ROOT/versions" ]]; then
    while IFS= read -r py_ver_dir; do
        found_any=1

        if [[ -x "$py_ver_dir/bin/python" ]]; then
            py="$py_ver_dir/bin/python"
        else
            printf "%-20s | %-60s | %-20s\n" "pyenv" "$py_ver_dir" "NO PYTHON"
            continue
        fi

        version="$("$py" - "$LIB_NAME" 2>/dev/null <<< "$PY_CHECK")"
        printf "%-20s | %-60s | %-20s\n" "pyenv" "$py_ver_dir" "$version"
    done < <(find "$PYENV_ROOT/versions" -mindepth 1 -maxdepth 1 -type d | sort)
else
    echo "(pyenv not found — skipping pyenv versions)" >&2
fi

if [[ $found_any -eq 0 ]]; then
    echo "No virtual environments found under: $ROOT_DIR" >&2
    exit 2
fi
```
