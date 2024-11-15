#!/bin/zsh

# Exit on error
set -e

# Variables
INPUT_FILE="talsec_pigeon_api.dart"

# Check current directory
if [ "$(basename "$PWD")" != "pigeons" ]; then
  echo "⚠️ Not in the /pigeons directory."
  echo "⚠️ Current directory: $PWD"
  echo "Run this script from the /pigeons directory"
  exit 1
fi

# Generate Pigeon code
cd ..
dart run pigeon \
  --input pigeons/$INPUT_FILE
