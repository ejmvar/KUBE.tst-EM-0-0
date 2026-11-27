#/usr/bin/env bash
#!/bin/bash

set -euo pipefail
lab_dir=$(ssh acer 'mktemp -d "$HOME/kind-phase0.XXXXXXXX"')
tar -cf - mise.toml kind-lab.yaml mise/tasks/kind.toml \
  scripts/kind-lab.sh scripts/test-kind-lab.sh README.md \
  docs/phase-0-kind-lab.md |
  ssh acer "tar -xf - -C \"$lab_dir\""
printf 'On acer, use: cd "%s"\n' "$lab_dir"
