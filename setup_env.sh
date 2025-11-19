#!/usr/bin/env bash
set -e

echo "=== Paramak Environment Setup ==="

PYTHON_VERSION="3.12"
ENV_DIR=".venv"
OPENMC_SRC="$HOME/openmc-src"
START_DIR=$(pwd)

OS="$(uname -s)"
echo "Detected OS: $OS"

if ! command -v uv >/dev/null 2>&1; then
    echo "uv not found. Installing uv..."
    if [ "$OS" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
        brew install uv
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
fi
echo "Using uv: $(uv --version)"

if ! uv python list | grep -q "$PYTHON_VERSION"; then
    echo "Python $PYTHON_VERSION not found. Installing via uv..."
    uv python install "$PYTHON_VERSION"
fi
uv python pin "$PYTHON_VERSION"

if [ ! -d "$ENV_DIR" ]; then
    echo "Creating virtual environment at $ENV_DIR..."
    uv venv --python "$PYTHON_VERSION" "$ENV_DIR"
fi

if [ ! -f "$ENV_DIR/bin/activate" ]; then
    echo "Error: Virtual environment activation script not found!"
    exit 1
fi
source "$ENV_DIR/bin/activate"

while true; do
    echo
    echo "=== Paramak Setup Menu ==="
    echo "1) Build OpenMC from source (macOS/Linux)"
    echo "2) Sync dependencies with uv (from pyproject.toml)"
    echo "3) Run tests"
    echo "4) Build documentation"
    echo "5) Run examples"
    echo "6) Install Paramak in dev mode"
    echo "7) Delete venv"
    echo "0) Exit"
    read -p "Choose an option: " choice

    case $choice in
        1)
            echo "Building OpenMC from source..."
            if [ "$OS" = "Darwin" ]; then
                brew install cmake hdf5 libpng git gcc || true
            elif [ "$OS" = "Linux" ]; then
                sudo apt-get update
                sudo apt-get install -y cmake libhdf5-dev libpng-dev git g++ || true
            fi

            if [ ! -d "$OPENMC_SRC" ]; then
                git clone --recurse-submodules https://github.com/openmc-dev/openmc.git "$OPENMC_SRC"
            fi

            cd "$OPENMC_SRC"
            mkdir -p build && cd build
            cmake .. -DCMAKE_INSTALL_PREFIX="$ENV_DIR" -DOPENMC_USE_MPI=OFF -DOPENMC_USE_OPENMP=ON
            make -j$(nproc || sysctl -n hw.ncpu)
            make install
            cd "$START_DIR"
            ;;
        2)
            echo "Syncing Python dependencies from pyproject.toml..."
            uv sync || echo "Warning: Some dependencies may not resolve (OpenMC is built from source)"
            ;;
        3)
            echo "Running tests..."
            uv run pytest
            ;;
        4)
            echo "Building documentation..."
            DOCS_DIR="docs"
            if [ -d "$DOCS_DIR" ]; then
                uv run pip install --upgrade -e ".[docs]"
                cd "$DOCS_DIR"
                uv run make html
                echo "Documentation built at $DOCS_DIR/_build/html"
                cd "$START_DIR"
            else
                echo "Docs directory not found. Skipping."
            fi
            ;;
        5)
            EXAMPLES_DIR="examples"
            if [ -d "$EXAMPLES_DIR" ]; then
                echo "Running examples in $EXAMPLES_DIR..."
                for example in "$EXAMPLES_DIR"/*.py; do
                    uv run python "$example"
                done
            else
                echo "Examples directory not found. Skipping."
            fi
            ;;
        6)
            echo "Installing Paramak in editable dev mode..."
            uv add --dev .
            ;;
        7)
            echo "Removing the virutal environment"
            rm -rf .venv
            ;;
        0)
            echo "Exiting."
            break
            ;;
        *)
            echo "Invalid choice. Try again."
            ;;
    esac
done

echo "=== Done ==="
echo "Activate the venv with: source $ENV_DIR/bin/activate"
