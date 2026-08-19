<!-- markdownlint-disable -->

# Hardening Report: xu-cheng--latex-action/4.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **xu-cheng--latex-action/4.0.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The workflow file uses tag-based (non-SHA-pinned) action references, which are vulnerable to supply-chain attacks. Found: `actions/checkout@v4` and `actions/upload-artifact@v4`. These should be pinned to their full 40-character commit SHA (e.g., `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`).

Locations:

- `.github/workflows/test.yml:14`
- `.github/workflows/test.yml:148`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and the single `test` job also has no job-level `permissions:` key. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad. A minimal `permissions:` block (e.g., `contents: read`) should be added.

Locations:

- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions

**Notes:**

Fixed .github/workflows/test.yml: (1) Added top-level `permissions: contents: read` block to restrict default token permissions. (2) Pinned `actions/checkout@v4` to full SHA `34e114876b0b11c390a56381ad16ebd13914f8d5 # v4`. (3) Pinned `actions/upload-artifact@v4` to full SHA `ea165f8d65b6e75b540449e92b4886f43607fa02 # v4`.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection vulnerability in entrypoint.sh at line 80. Replaced the unquoted `for pkg in $INPUT_EXTRA_SYSTEM_PACKAGES` loop with `IFS=$' \t\n' read -r -a extra_packages <<< "$INPUT_EXTRA_SYSTEM_PACKAGES"` followed by `for pkg in "${extra_packages[@]}"`. This ensures the user-controlled input is quoted during word-splitting (preventing metacharacter injection) and each package name is treated as a literal string when passed to apt-get/apk.

