#!/bin/bash
# Fake docker for testing xu-cheng/latex-action
# Simulates 'docker run' for LaTeX compilation without pulling real images.
# Mirrors the behavior of entrypoint.sh + latexmk for path/PDF placement.

set -eo pipefail

# Only intercept 'docker run'
if [[ "${1:-}" != "run" ]]; then
  if command -v /usr/bin/docker &>/dev/null; then
    exec /usr/bin/docker "$@"
  else
    echo "fake-docker: unsupported command: $*" >&2
    exit 1
  fi
fi

# ---- Simulate docker run for latex-action ----
# The action passes env vars by name (-e VAR), so they are already in our environment.

# Check for conflicting engines (mirrors entrypoint.sh behavior)
if [[ "${INPUT_LATEXMK_USE_LUALATEX:-}" == "true" && "${INPUT_LATEXMK_USE_XELATEX:-}" == "true" ]]; then
  echo "::error :: Input 'latexmk_use_lualatex' and 'latexmk_use_xelatex' cannot be used at the same time."
  exit 1
fi

# Determine working directory (mirrors entrypoint.sh)
WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
if [[ -n "${INPUT_WORKING_DIRECTORY:-}" ]]; then
  WORK_DIR="$WORKSPACE/$INPUT_WORKING_DIRECTORY"
  mkdir -p "$WORK_DIR"
else
  WORK_DIR="$WORKSPACE"
fi

# Run pre_compile if set (runs in working directory, like entrypoint.sh)
if [[ -n "${INPUT_PRE_COMPILE:-}" ]]; then
  (cd "$WORK_DIR" && eval "$INPUT_PRE_COMPILE")
fi

# Process root files
readarray -t root_files <<< "${INPUT_ROOT_FILE:-}"
exit_code=0

for f in "${root_files[@]}"; do
  # Trim whitespace
  f="${f#"${f%%[![:space:]]*}"}"
  f="${f%"${f##*[![:space:]]}"}"
  [[ -z "$f" ]] && continue

  if [[ "${INPUT_WORK_IN_ROOT_FILE_DIR:-}" == "true" ]]; then
    # Change to the directory containing the file (mirrors entrypoint.sh pushd behavior)
    file_dir="$WORK_DIR/$(dirname "$f")"
    base_name="$(basename "${f%.tex}")"
    src_path="$file_dir/$(basename "$f")"
    # latexmk creates PDF in the directory it's run from
    pdf_path="$file_dir/$base_name.pdf"
  else
    # latexmk creates PDF in the current working directory (WORK_DIR)
    # named after the basename of the input file
    base_name="$(basename "${f%.tex}")"
    src_path="$WORK_DIR/$f"
    pdf_path="$WORK_DIR/$base_name.pdf"
  fi

  if [[ ! -f "$src_path" ]]; then
    echo "::error :: File '$f' cannot be found from the directory '$WORK_DIR'."
    if [[ "${INPUT_CONTINUE_ON_ERROR:-}" == "true" ]]; then
      exit_code=1
      continue
    else
      exit 1
    fi
  fi

  # Simulate compilation failure for files containing \badcommand
  if grep -q '\\badcommand' "$src_path" 2>/dev/null; then
    echo "! Undefined control sequence."
    echo "l.3 \\badcommand"
    if [[ "${INPUT_CONTINUE_ON_ERROR:-}" == "true" ]]; then
      exit_code=1
      continue
    else
      exit 1
    fi
  fi

  # Create a minimal valid fake PDF
  mkdir -p "$(dirname "$pdf_path")"
  printf '%%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Kids [] /Count 0 >>\nendobj\nxref\n0 3\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \ntrailer\n<< /Size 3 /Root 1 0 R >>\nstartxref\n110\n%%%%EOF\n' > "$pdf_path"
  echo "Compiled $f -> $pdf_path"
done

# Run post_compile if set
if [[ -n "${INPUT_POST_COMPILE:-}" ]]; then
  (cd "$WORK_DIR" && eval "$INPUT_POST_COMPILE")
fi

exit "$exit_code"
