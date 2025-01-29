#!/bin/bash

# Define the list of input files for pandoc
INPUT_FILES=(
  "./README.md"
  "./Install.md"
  "./helm/openshift-gitops/README.md"
  "./helm/openshift-gitops-day2/README.md"
  "./docs/vm-migration-notes.md"
)

# Ensure required packages are installed
install_packages() {
  echo "Checking for required packages..."

  if ! command -v pandoc >/dev/null; then
    echo "Installing Pandoc..."
    sudo dnf install -y pandoc || sudo apt-get install -y pandoc || sudo yum install -y pandoc
  fi

  if ! command -v pdflatex >/dev/null; then
    echo "Installing TeX Live LaTeX..."
    sudo dnf install -y texlive-latex || sudo apt-get install -y texlive-latex || sudo yum install -y texlive-latex
  fi
}

# Generate PDF with pandoc
generate_pdf() {
  pandoc -f markdown -o install_instructions.pdf -V geometry:margin=1in \
    --metadata=title["Disconnected OpenShift"] "${INPUT_FILES[@]}"
  echo "PDF generated: install_instructions.pdf"
}

install_packages
generate_pdf
