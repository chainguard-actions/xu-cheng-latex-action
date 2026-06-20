<!-- markdownlint-disable -->

# Hardening Report: xu-cheng--latex-action/4.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **xu-cheng--latex-action/4.1.0** was hardened automatically. 0 finding(s) were identified and resolved across 1 iteration(s).

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in entrypoint.sh at line 107. Replaced the unquoted `for pkg in $INPUT_EXTRA_SYSTEM_PACKAGES` loop (which allowed glob expansion and shell metacharacter interpretation) with a safe array-based approach: `IFS=$' \t\n' read -r -a extra_packages <<< "$INPUT_EXTRA_SYSTEM_PACKAGES"` followed by `for pkg in "${extra_packages[@]}"`. This ensures the input is split safely into an array without glob expansion, and each package name is treated as a literal string during iteration.

