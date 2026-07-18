#!/usr/bin/env bash
#
# inject-agent-model.sh
#
# Set the `model:` field in the frontmatter of the two frontend agent files
# (frontend-developer.md, frontend-acceptance.md) under the INSTALLED plugin dir.
#
# The model value has the form:  custom:<provider-key>:<model-id>
#   - provider-key: read from ~/.zcode/v2/config.json; colons are URL-encoded
#     to %3A because ':' is the field separator (e.g. builtin:bigmodel ->
#     builtin%3Abigmodel). A UUID key like the default kimi one needs no encoding.
#   - model-id: a model key nested under the chosen provider in config.json.
#
# Defaults to the Kimi K3 model:
#   provider = 623553b2-da8a-4b43-9320-90b1ed62a12b   (value: custom:<kimi provider key>)
#   modelid  = k3
#
# Usage:
#   bash scripts/inject-agent-model.sh                       # kimi/k3, latest installed version
#   bash scripts/inject-agent-model.sh --version 1.0.2
#   bash scripts/inject-agent-model.sh --provider <key> --model <id>
#   bash scripts/inject-agent-model.sh --provider <key> --model <id> --version 1.0.2
#
# Behavior:
#   - If the agent file has a `model:` line, replace it in place.
#   - If it has no `model:` line, insert one right before the closing `---` of
#     the frontmatter.
#   - Backs up each file to <file>.bak before editing.
#   - Idempotent: re-running with the same value is a no-op (exit 0).
#   - Validates that provider and model exist in config.json before writing.
#
set -euo pipefail

# ----------------------------- config -----------------------------
PLUGIN_GROUP="annopick-plugin"
PLUGIN_NAME="annopick-plugin"
INSTALL_ROOT="$HOME/.zcode/cli/plugins/cache/${PLUGIN_GROUP}/${PLUGIN_NAME}"
CONFIG_FILE="$HOME/.zcode/v2/config.json"
AGENTS_SUBDIR="agents"
AGENT_FILES=("frontend-developer.md" "frontend-acceptance.md")

# defaults: Kimi K3
DEFAULT_PROVIDER="623553b2-da8a-4b43-9320-90b1ed62a12b"
DEFAULT_MODEL="k3"

# ----------------------------- color -----------------------------
if [ -t 1 ]; then
    GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
else
    GREEN=''; YELLOW=''; RED=''; RESET=''
fi
ok()   { printf '%s%s%s\n' "$GREEN"  "$*" "$RESET"; }
warn() { printf '%s%s%s\n' "$YELLOW" "$*" "$RESET" >&2; }
err()  { printf '%s%s%s\n' "$RED"    "$*" "$RESET" >&2; }

# ----------------------------- parse args -----------------------------
PROVIDER="$DEFAULT_PROVIDER"
MODELID="$DEFAULT_MODEL"
VERSION=""

while [ $# -gt 0 ]; do
    case "$1" in
        --provider) PROVIDER="$2"; shift 2 ;;
        --model)    MODELID="$2"; shift 2 ;;
        --version)  VERSION="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *)
            err "Unknown argument: $1"
            err "See --help for usage."
            exit 2 ;;
    esac
done

# ----------------------------- sanity: provider/model non-empty -----------------------------
if [ -z "$PROVIDER" ] || [ -z "$MODELID" ]; then
    err "Error: --provider and --model must both be non-empty."
    exit 2
fi

# ----------------------------- validate against config.json -----------------------------
if [ ! -f "$CONFIG_FILE" ]; then
    err "Error: config file not found: $CONFIG_FILE"
    err "Cannot verify provider/model. Ensure ZCode is initialized."
    exit 1
fi

VALIDATE=$(python3 - "$CONFIG_FILE" "$PROVIDER" "$MODELID" << 'PYEOF'
import json, sys
cfg_path, provider, model = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    cfg = json.load(open(cfg_path))
except Exception as e:
    print("ERRJSON" + str(e)); sys.exit(0)
providers = cfg.get("provider", {})
if provider not in providers:
    print("ERRPROV"); sys.exit(0)
models = providers[provider].get("models", {})
if model not in models:
    print("ERRMODEL"); sys.exit(0)
print("OK")
PYEOF
)

case "$VALIDATE" in
    OK) ;;
    ERRJSON*)
        err "Error: failed to parse $CONFIG_FILE: ${VALIDATE#ERRJSON}"; exit 1 ;;
    ERRPROV)
        err "Error: provider '$PROVIDER' not found in $CONFIG_FILE."
        err "Available providers:"
        python3 -c 'import json,sys;[print("   -",k) for k in json.load(open(sys.argv[1])).get("provider",{})]' "$CONFIG_FILE" >&2
        exit 1 ;;
    ERRMODEL)
        err "Error: model '$MODELID' not found under provider '$PROVIDER'."
        err "Available models for this provider:"
        python3 -c 'import json,sys;p=sys.argv[2];[print("   -",k) for k in json.load(open(sys.argv[1])).get("provider",{}).get(p,{}).get("models",{})]' "$CONFIG_FILE" "$PROVIDER" >&2
        exit 1 ;;
    *)
        err "Error: unexpected validation result: $VALIDATE"; exit 1 ;;
esac

# ----------------------------- build model value -----------------------------
# URL-encode ':' in provider key to %3A (it's the field separator in the value).
PROVIDER_ENC="${PROVIDER//:/__COLON__}"
PROVIDER_ENC="${PROVIDER_ENC//__COLON__/%3A}"
MODEL_VALUE="custom:${PROVIDER_ENC}:${MODELID}"

# ----------------------------- locate plugin dir -----------------------------
if [ ! -d "$INSTALL_ROOT" ]; then
    err "Error: plugin install dir not found: $INSTALL_ROOT"
    err "Please install the plugin in the ZCode client first, then re-run this script."
    exit 1
fi

if [ -n "$VERSION" ]; then
    :
else
    VERSION=$(ls -1 "$INSTALL_ROOT" 2>/dev/null \
        | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
        | sort -V \
        | tail -1 || true)
    if [ -z "$VERSION" ]; then
        err "Error: no version directory (x.y.z) found under $INSTALL_ROOT."
        err "Pass the version explicitly:  bash $0 --version 1.0.2"
        exit 1
    fi
fi

VERSION_DIR="$INSTALL_ROOT/$VERSION"
AGENTS_DIR="$VERSION_DIR/$AGENTS_SUBDIR"

printf 'Plugin version: %s\n' "$VERSION"
printf 'Agents dir:     %s\n' "$AGENTS_DIR"
printf 'Model value:    %s\n' "$MODEL_VALUE"
printf '\n'

if [ ! -d "$AGENTS_DIR" ]; then
    err "Error: agents dir not found: $AGENTS_DIR"
    exit 1
fi

# ----------------------------- per-file edit -----------------------------
# For each agent file:
#   1. if a `^model:` line exists with the same value -> skip (idempotent)
#   2. elif a `^model:` line exists with a different value -> replace it
#   3. elif no `model:` line -> insert one before the closing `---` of frontmatter
# Uses a small python helper so we avoid fragile sed escaping of the value.
edit_file() {
    local file="$1"
    local value="$2"

    if [ ! -f "$file" ]; then
        warn "  skip: file not found: $file"
        return 1
    fi

    # idempotency: already the target value
    if grep -qE "^model:[[:space:]]*\"?${value}\"?[[:space:]]*\$" "$file" 2>/dev/null; then
        printf '  %-28s already set, skip\n' "$(basename "$file")"
        return 0
    fi

    # backup
    cp -f "$file" "$file.bak"

    python3 - "$file" "$value" << 'PYEOF'
import sys, re
path, value = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as f:
    lines = f.readlines()

model_line = f'model: "{value}"\n'
done = False

# 1) replace existing ^model: line
for i, ln in enumerate(lines):
    if re.match(r'^model:', ln):
        lines[i] = model_line
        done = True
        break

# 2) no model line -> insert before the closing '---' of the frontmatter
if not done:
    # frontmatter must start with '---' on the first line
    if not lines or lines[0].strip() != '---':
        sys.exit("NOFRONTMATTER")
    inserted = False
    for i in range(1, len(lines)):
        if lines[i].strip() == '---':
            lines.insert(i, model_line)
            inserted = True
            break
    if not inserted:
        sys.exit("NOCLOSEFRONTMATTER")

with open(path, "w", encoding="utf-8") as f:
    f.writelines(lines)
PYEOF
    local rc=$?
    if [ $rc -ne 0 ]; then
        err "  error editing $(basename "$file") (code=$rc); backup kept at $file.bak"
        return 1
    fi
    printf '  %-28s updated -> %s\n' "$(basename "$file")" "$value"
    return 0
}

EXIT_CODE=0
for af in "${AGENT_FILES[@]}"; do
    edit_file "$AGENTS_DIR/$af" "$MODEL_VALUE" || EXIT_CODE=1
done

if [ $EXIT_CODE -ne 0 ]; then
    err "Completed with errors. See messages above."
    exit "$EXIT_CODE"
fi

ok "Done."
