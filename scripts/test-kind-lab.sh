#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
export CALLS="$scratch/calls"
export PATH="$scratch:$PATH"

cat > "$scratch/kind" <<'EOF'
#!/usr/bin/env bash
printf 'kind %s\n' "$*" >> "$CALLS"
EOF
cat > "$scratch/kubectl" <<'EOF'
#!/usr/bin/env bash
printf 'kubectl %s\n' "$*" >> "$CALLS"
EOF
chmod +x "$scratch/kind" "$scratch/kubectl"

cd "$scratch"
bash "$repo/scripts/kind-lab.sh" up
bash "$repo/scripts/kind-lab.sh" check
bash "$repo/scripts/kind-lab.sh" down
diff -u - "$CALLS" <<EOF
kind create cluster --name em-tst-00 --config $repo/kind-lab.yaml --wait 120s
kubectl --context kind-em-tst-00 cluster-info
kubectl --context kind-em-tst-00 wait --for=condition=Ready nodes --all --timeout=60s
kind delete cluster --name em-tst-00
EOF

if bash "$repo/scripts/kind-lab.sh" invalid > "$scratch/output" 2>&1; then
    echo "Expected an invalid action to fail" >&2
    exit 1
fi
grep -q '^Usage:' "$scratch/output"
test "$(wc -l < "$CALLS")" -eq 4
