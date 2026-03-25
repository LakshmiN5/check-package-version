# Check Installed Package Version

A bash script to check Python package versions across multiple environment types (venv, conda, pyenv).

## Features

- 🔍 Scans for virtual environments (venv/virtualenv)
- 🐍 Checks conda environments
- 🔧 Inspects pyenv versions
- 📊 Displays results in a formatted table
- 🖥️ Cross-platform support (Unix/Windows)

## Requirements

- Bash shell
- Python 3.x (with `importlib.metadata` or `importlib_metadata`)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/LakshmiN5/check-package-version.git
cd check-package-version
```

2. Make the script executable:
```bash
chmod +x check_installed_package_version.sh
```

## Usage

```bash
./check_installed_package_version.sh <library_name> [root_dir]
```

### Arguments

- `library_name` - Package/distribution name to check (e.g., requests, numpy, pandas)
- `root_dir` - Root folder to search under (default: current directory)

### Examples

Check for `requests` package in current directory:
```bash
./check_installed_package_version.sh requests
```

Check for `numpy` in a specific directory:
```bash
./check_installed_package_version.sh numpy /home/user/projects
```

## Output

The script displays a formatted table showing:
- **ENV TYPE**: Type of Python environment (venv, conda, pyenv)
- **PATH / IDENTIFIER**: Location of the environment
- **VERSION**: Installed version of the package (or "NOT INSTALLED")

Example output:
```
ENV TYPE             | PATH / IDENTIFIER                                            | VERSION             
---------------------+--------------------------------------------------------------+---------------------
venv                 | /home/user/project/venv                                      | 2.28.1
conda                | /home/user/anaconda3/envs/myenv                              | 1.24.3
pyenv                | /home/user/.pyenv/versions/3.9.7                             | NOT INSTALLED
```

## How It Works

1. **Virtual Environments**: Searches for `pyvenv.cfg` files to identify venv/virtualenv installations
2. **Conda Environments**: Uses `conda info --envs` to list all conda environments
3. **Pyenv Versions**: Scans `$PYENV_ROOT/versions` directory for pyenv-managed Python versions

For each environment found, the script:
- Locates the Python executable
- Runs an inline Python snippet to check the package version using `importlib.metadata`
- Reports the version or installation status

## Error Handling

- Validates input arguments
- Checks directory existence
- Handles missing Python executables gracefully
- Reports environments without the specified package

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created by Lakshmi N

## Acknowledgments

- Uses Python's `importlib.metadata` for reliable package version detection
- Supports multiple Python environment management tools