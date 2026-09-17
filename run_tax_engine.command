#!/bin/bash

# Ensure we are in the directory of the script
cd "$(dirname "$0")"

echo "=========================================="
echo "   Austrian Tax Engine - Setup & Run"
echo "=========================================="

# 1. Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed."
    echo "Please install Python 3 from https://www.python.org/downloads/"
    echo "or run 'brew install python' if you have Homebrew."
    read -p "Press Enter to exit..."
    exit 1
fi

# Define the base directory of the script
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON_BIN="$BASE_DIR/.venv/bin/python3"
PLAYWRIGHT_BIN="$BASE_DIR/.venv/bin/playwright"

# 2. Create or repair the virtual environment
# Checking the executable, rather than only the directory, handles copied or
# partially-created environments whose interpreter symlink is broken.
if [ ! -x "$PYTHON_BIN" ]; then
    if [ -d "$BASE_DIR/.venv" ]; then
        echo "Removing incomplete virtual environment (.venv)..."
        rm -rf "$BASE_DIR/.venv"
    fi

    echo "Creating Python virtual environment (.venv)..."
    # Use a copied interpreter because symlinks can become invalid when the
    # project directory is copied or mounted in a different filesystem.
    python3 -m venv --copies "$BASE_DIR/.venv"
    if [ $? -ne 0 ]; then
        echo "Error creating virtual environment."
        read -p "Press Enter to exit..."
        exit 1
    fi
fi

# 3. Install Dependencies (using venv python directly)
echo "Checking/Installing dependencies..."
"$PYTHON_BIN" -m pip install --upgrade pip setuptools wheel
"$PYTHON_BIN" -m pip install -e .
if [ $? -ne 0 ]; then
    echo "Error installing dependencies."
    #read -p "Press Enter to exit..."
    exit 1
fi

# 4. Install Playwright Browsers
echo "Checking Playwright browsers..."
"$PLAYWRIGHT_BIN" install chromium
if [ $? -ne 0 ]; then
    echo "Error installing Playwright browsers."
    #read -p "Press Enter to exit..."
    exit 1
fi

# 5. Main Menu Loop
while true; do
    clear
    echo "=========================================="
    echo "   Austrian Tax Engine for E-Trade"
    echo "=========================================="
    echo "1. Login to E-Trade (Required first)"
    echo "2. Download All Data (ESPP, Orders, RSU)"
    echo "3. Calculate Tax"
    echo "4. Run Demo"
    echo "5. Exit"
    echo "=========================================="
    read -p "Select an option (1-5): " choice

    case "$choice" in
        1)
            echo "------------------------------------------"
            echo "Running Login..."
            echo "A browser window will open. Please log in."
            echo "------------------------------------------"
            "$BASE_DIR/.venv/bin/tax-login"
            echo ""
            #read -p "Press Enter to return to menu..."
            ;;
        2)
            echo "------------------------------------------"
            echo "Downloading Data..."
            echo "------------------------------------------"
            "$BASE_DIR/.venv/bin/tax-download"
            echo ""
            #read -p "Press Enter to return to menu..."
            ;;
        3)
            echo "------------------------------------------"
            echo "Calculating Tax..."
            echo "------------------------------------------"
            "$BASE_DIR/.venv/bin/tax-engine"
            echo ""
            #read -p "Press Enter to return to menu..."
            ;;
        4)
            echo "------------------------------------------"
            echo "Running Demo..."
            echo "------------------------------------------"
            "$BASE_DIR/.venv/bin/tax-demo"
            echo ""
            #read -p "Press Enter to return to menu..."
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option."
            #read -p "Press Enter to continue..."
            ;;
    esac
done
