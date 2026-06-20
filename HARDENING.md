<!-- markdownlint-disable -->

# Hardening Report: xu-cheng--latex-action/4.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **xu-cheng--latex-action/4.0.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansion of untrusted data. In entrypoint.sh, the user-controlled input `inputs.extra_system_packages` is passed via the env var `INPUT_EXTRA_SYSTEM_PACKAGES` and expanded unquoted in a for-loop: `for pkg in $INPUT_EXTRA_SYSTEM_PACKAGES`. Although `IFS` is set to split on whitespace, the unquoted expansion still allows shell metacharacters (`;`, `|`, `&`, backticks, `$(...)`) embedded in the input to be interpreted by the shell, enabling command injection.

Locations:

- `entrypoint.sh:88`

### script-injection (severity: high)

Sub-rule (b): User-controlled inputs `inputs.pre_compile` and `inputs.post_compile` are passed via env vars `INPUT_PRE_COMPILE` and `INPUT_POST_COMPILE` and then executed as arbitrary shell code via `eval "$INPUT_PRE_COMPILE"` and `eval "$INPUT_POST_COMPILE"`. Although the variables are double-quoted, `eval` causes the entire value to be parsed and executed as shell commands, making this a direct script-injection vector for any caller of this composite action. Offending lines: `eval "$INPUT_PRE_COMPILE"` and `eval "$INPUT_POST_COMPILE"`.

Locations:

- `entrypoint.sh:112`
- `entrypoint.sh:130`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed three script-injection vulnerabilities in entrypoint.sh:

1. Line 88 (extra_system_packages): Replaced unquoted `for pkg in $INPUT_EXTRA_SYSTEM_PACKAGES` with `IFS=$' \t\n' read -ra extra_packages <<< "$INPUT_EXTRA_SYSTEM_PACKAGES"` and `for pkg in "${extra_packages[@]}"`. Added package name validation with regex `^[a-zA-Z0-9][a-zA-Z0-9.+_-]*$` to reject shell metacharacters before passing to apt-get/apk.

2. Lines 112 and 130 (pre_compile/post_compile): Replaced `eval "$INPUT_PRE_COMPILE"` and `eval "$INPUT_POST_COMPILE"` with `bash -c "$INPUT_PRE_COMPILE"` and `bash -c "$INPUT_POST_COMPILE"`. Using bash -c runs the commands in a subshell, preventing them from modifying the parent shell's state or causing unexpected exits, which is the safer idiom for executing user-provided shell hooks.

