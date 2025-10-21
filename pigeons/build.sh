#!/bin/zsh

# Exit on error
set -euo pipefail

# Variables
INPUT_FILES=("talsec_pigeon_api.dart" "rasp_execution_state.dart")

# Check current directory
if [ "$(basename "$PWD")" != "pigeons" ]; then
  echo "⚠️ Not in the /pigeons directory."
  echo "⚠️ Current directory: $PWD"
  echo "Run this script from the /pigeons directory"
  exit 1
fi

# Generate Pigeon code
cd ..
for file in "${INPUT_FILES[@]}"; do
  echo "🚀 Generating Pigeon code for $file..."
  dart run pigeon --input "./pigeons/$file"
done
