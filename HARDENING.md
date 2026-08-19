<!-- markdownlint-disable -->

# Hardening Report: xu-cheng--latex-action/3.3.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **xu-cheng--latex-action/3.3.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The workflow file uses mutable tag refs instead of full 40-character SHA commit hashes, making the workflow vulnerable to supply-chain attacks if the referenced action tags are moved or compromised. Failing references: `actions/checkout@v4` and `actions/upload-artifact@v4`.

Locations:

- `.github/workflows/test.yml:14`
- `.github/workflows/test.yml:165`

### missing-permissions (severity: medium)

The workflow file has no top-level `permissions:` key and the single job (`test`) also has no `permissions:` key. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be broader than necessary (e.g., write access to contents). A minimal permissions block such as `permissions: read-all` or specific scopes should be added.

Locations:

- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions

**Notes:**

Fixed hardened/action/.github/workflows/test.yml: (1) Pinned actions/checkout@v4 to SHA 11d5960a326750d5838078e36cf38b85af677262 # v4; (2) Pinned actions/upload-artifact@v4 to SHA ea165f8d65b6e75b540449e92b4886f43607fa02 # v4; (3) Added top-level permissions block with contents: read to restrict default token permissions.

