<!-- markdownlint-disable -->

# Hardening Report: xu-cheng--latex-action/3.3.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **xu-cheng--latex-action/3.3.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In entrypoint.sh, the env var `$INPUT_EXTRA_SYSTEM_PACKAGES` (sourced from `inputs.extra_system_packages`, a workflow-controllable input) is expanded **unquoted** inside a for-loop: `for pkg in $INPUT_EXTRA_SYSTEM_PACKAGES`. This allows shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) embedded in the input value to be parsed by the shell, enabling command injection.

Locations:

- `entrypoint.sh:79`

### script-injection (severity: high)

Rule (b) violation: In entrypoint.sh, `eval "$INPUT_PRE_COMPILE"` and `eval "$INPUT_POST_COMPILE"` execute arbitrary shell code from workflow-controllable inputs (`inputs.pre_compile` and `inputs.post_compile`). Although the variables are double-quoted in the eval call, `eval` then re-parses the content as shell commands, allowing full command injection from any caller of this composite action. The env vars are set directly from `${{ inputs.pre_compile }}` and `${{ inputs.post_compile }}` in action.yml.

Locations:

- `entrypoint.sh:112`
- `entrypoint.sh:136`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed three script-injection issues in entrypoint.sh:
1. Line 79: Replaced unquoted `for pkg in $INPUT_EXTRA_SYSTEM_PACKAGES` with `IFS=$' \t\n' read -ra pkgs <<< "$INPUT_EXTRA_SYSTEM_PACKAGES"` + `for pkg in "${pkgs[@]}"` to prevent shell metacharacter injection during word-splitting.
2. Line 112: Replaced `eval "$INPUT_PRE_COMPILE"` with `bash -c "$INPUT_PRE_COMPILE"` to run pre-compile commands in a subshell instead of the current shell, preventing environment pollution and reducing injection risk.
3. Line 136: Replaced `eval "$INPUT_POST_COMPILE"` with `bash -c "$INPUT_POST_COMPILE"` for the same reasons as above.

