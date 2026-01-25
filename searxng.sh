#!/bin/bash
# SearXNG helper functions and completions

SEARXNG_CONFIG="${SEARXNG_CONFIG:-/etc/searxng/settings.yml}"
SEARXNG_URL="${SEARXNG_URL:-http://localhost:8855}"

# Register carapace completion for xng (if in zsh and carapace available)
if [[ -n "$ZSH_VERSION" ]] && command -v carapace &>/dev/null; then
  compdef _carapace xng 2>/dev/null
fi

# Install xng wrapper and carapace completions
searxng_install() {
  # Create wrapper script
  mkdir -p ~/.local/bin
  cat >~/.local/bin/xng <<'WRAPPER'
#!/bin/bash
source ~/proj/searxng.sh/searxng.sh
_xng "$@"
WRAPPER
  chmod +x ~/.local/bin/xng
  echo "Installed xng to ~/.local/bin/xng"

  # Link carapace spec
  mkdir -p ~/.config/carapace/specs
  ln -sf ~/proj/searxng.sh/searxng.yaml ~/.config/carapace/specs/xng.yaml
  echo "Linked carapace spec to ~/.config/carapace/specs/xng.yaml"

  echo "Restart your shell or run: source <(carapace _carapace)"
}

# Extract enabled engines from settings.yml
searxng_engines() {
  awk '
        /^  - name:/ {
            if (name && disabled==0) print name
            name = substr($0, index($0, $3))
            disabled = 0
        }
        /disabled: true/ { disabled = 1 }
        END { if (name && disabled==0) print name }
    ' "$SEARXNG_CONFIG" | sort -u
}

# Get enabled engines from API (requires running instance)
searxng_engines_api() {
  curl -s "${SEARXNG_URL}/config" | jq -r '.engines[] | select(.enabled==true) | .name' | sort -u
}

# For carapace completions (uses YAML config)
searxng_complete_engines() {
  searxng_engines
}

# Query function (called by ~/.local/bin/xng wrapper)
_xng() {
  local format="" engines=() categories=() page="" lang=""
  local query=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -f | --format)
      format="$2"
      shift 2
      ;;
    -e | --engine)
      engines+=("!$2")
      shift 2
      ;;
    -c | --category)
      categories+=("!$2")
      shift 2
      ;;
    -p | --page)
      page="$2"
      shift 2
      ;;
    -l | --lang)
      lang=":$2"
      shift 2
      ;;
    *)
      query="$query $1"
      shift
      ;;
    esac
  done

  query="${query## }" # trim leading space

  # Build query with !engine !category :lang prefixes
  local prefixes="${engines[*]} ${categories[*]} ${lang}"
  prefixes="${prefixes## }"
  prefixes="${prefixes%% }"
  [[ -n "$prefixes" ]] && query="$prefixes $query"

  local url="${SEARXNG_URL}/search?q=$(echo "$query" | sed 's/ /+/g')"
  [[ -n "$format" ]] && url="${url}&format=${format}"
  [[ -n "$page" ]] && url="${url}&pageno=${page}"

  if [[ -n "$format" ]]; then
    curl -s "$url"
  else
    xdg-open "$url"
  fi
}
