# SearXNG shell with autocomplete

## Requirements

- SearXNG instance
- `curl`, `jq`
- `xdg-open` (Linux) or `open` (macOS)
- [`carapace-spec`](https://github.com/carapace-sh/carapace-spec) (optional, for completions)

## Installation

```bash
source searxng.sh && searxng_install
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SEARXNG_URL` | `http://localhost:8855` | SearXNG instance URL |
| `SEARXNG_CONFIG` | `/etc/searxng/settings.yml` | fallback for engine completions |

## Usage

```bash
xng paris                       # opens browser
xng -o json paris               # returns JSON
xng -o url paris                # prints URL without fetching
```

### Engines and shortcuts

```bash
xng -e google paris             # engine by name
xng -s g paris                  # engine by shortcut
xng -s g -s images paris        # multiple
```

`-e` completes engine names, `-s` completes shortcuts.

### Categories and language

```bash
xng -c images paris             # category
xng -l fr paris                 # language
xng -s g -c images -l fr paris  # combined
```

### Pagination

```bash
xng -p 2 paris                  # page 2
```

## Custom engines

See `../searxng/engines/` for custom SearXNG engines like `reddit_subreddit.py` which searches within a subreddit:

```bash
xng -s rsub 'linux/neovim'      # search r/linux for "neovim"
```
