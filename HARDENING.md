<!-- markdownlint-disable -->

# Hardening Report: xu-cheng--latex-action/4.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **xu-cheng--latex-action/4.1.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The workflow file uses tag-based (non-SHA-pinned) action references, making the workflow vulnerable to supply-chain attacks if the tag is moved or the upstream repository is compromised. Failing references: `uses: actions/checkout@v6` (line 20) and `uses: actions/upload-artifact@v6` (near end of file). These should be pinned to full 40-character commit SHAs.

Locations:

- `.github/workflows/test.yml:20`
- `.github/workflows/test.yml:148`

### script-injection (severity: high)

Rule (b) violation in entrypoint.sh: the env var `INPUT_EXTRA_SYSTEM_PACKAGES` (sourced from `${{ inputs.extra_system_packages }}` via the action.yml env: block) is expanded unquoted in the shell command `for pkg in $INPUT_EXTRA_SYSTEM_PACKAGES`. An attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`) would be interpreted by the shell, enabling arbitrary command injection. The fix is to quote the expansion or use a safe read-array approach.

Locations:

- `entrypoint.sh:101`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

1. Pinned actions/checkout@v6 to SHA d23441a48e516b6c34aea4fa41551a30e30af803 and actions/upload-artifact@v6 to SHA b7c566a772e6b6bfb58ed0dc250532a479d7789f in .github/workflows/test.yml, preserving the tag as a comment. 2. Fixed script injection in entrypoint.sh line 101: replaced unquoted `for pkg in $INPUT_EXTRA_SYSTEM_PACKAGES` with a safe `read -r -a` array split (`IFS=$' \t\n' read -r -a extra_packages <<< "$INPUT_EXTRA_SYSTEM_PACKAGES"`) followed by iteration over the quoted array `"${extra_packages[@]}"`, preventing shell metacharacters in the input from being interpreted as commands.

