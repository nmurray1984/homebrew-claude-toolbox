# Claude Sandbox — Homebrew Tap Setup Instructions

These instructions are for an agent to create all files needed to publish `claude-sandbox` as a personal Homebrew tap on GitHub.

---

## Overview

The goal is a GitHub repo named `homebrew-claude-toolbox` containing:
- The `claude-sandbox` shell script in a `bin/` directory
- A Homebrew formula in a `Formula/` directory
- A README

Once published, the tool can be installed on any Mac with:
```bash
brew tap nmurray1984/claude-toolbox
brew install claude-sandbox
```

---

## Step 1 — Create the GitHub Repo

Create a new **public** GitHub repository named exactly:
```
homebrew-claude-toolbox
```

The `homebrew-` prefix is required by Homebrew's tap convention. The part after the hyphen (`claude-toolbox`) becomes the tap name used in `brew tap nmurray1984/claude-toolbox`.

Initialize it with no files (no auto-generated README — we'll create our own).

---

## Step 2 — Repo Structure

The final repo should have this structure:
```
homebrew-claude-toolbox/
├── Formula/
│   └── claude-sandbox.rb
├── bin/
│   └── claude-sandbox
└── README.md
```

---

## Step 3 — Create `bin/claude-sandbox`

Create the file `bin/claude-sandbox` with the following content exactly:

```bash
#!/usr/bin/env bash
# claude-sandbox - Run Claude Code inside an isolated OrbStack Docker container
# Only the current working directory is mounted; no other Mac files are accessible.

set -euo pipefail

WORK_DIR="$(pwd)"
IMAGE_NAME="claude-sandbox"
CONTAINER_NAME="claude-sandbox-$(date +%s)"

# ── Build the image if it doesn't exist ──────────────────────────────────────
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
  echo "🔨 Building Claude sandbox image (one-time setup)..."
  docker build --quiet -t "$IMAGE_NAME" - <<'DOCKERFILE'
FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspace
ENTRYPOINT ["claude"]
DOCKERFILE
  echo "✅ Image built."
fi

# ── Validate ANTHROPIC_API_KEY is set ────────────────────────────────────────
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "❌ ANTHROPIC_API_KEY is not set. Export it in your shell or ~/.zshrc and try again."
  exit 1
fi

echo "🚀 Launching Claude in sandbox..."
echo "   Working directory: $WORK_DIR"
echo "   (No other Mac files are accessible inside the container)"
echo ""

# ── Run the container ─────────────────────────────────────────────────────────
# --rm           → auto-remove container on exit
# -it            → interactive TTY for Claude's UI
# -v             → bind-mount only the current directory to /workspace
# --network=host → allows Claude to reach the Anthropic API
# -e             → pass in the API key
docker run --rm -it \
  --name "$CONTAINER_NAME" \
  -v "${WORK_DIR}:/workspace" \
  --network=host \
  -e ANTHROPIC_API_KEY \
  "$IMAGE_NAME" \
  "$@"
```

---

## Step 4 — Compute the SHA256 of the Script

After creating `bin/claude-sandbox`, compute its SHA256 hash by running:
```bash
shasum -a 256 bin/claude-sandbox
```

Save this hash — it is needed in the formula in Step 5.

---

## Step 5 — Create `Formula/claude-sandbox.rb`

Create the file `Formula/claude-sandbox.rb` with the content below, substituting:
- `nmurray1984` with the actual GitHub nmurray1984
- `SHA256_HASH` with the hash computed in Step 4

```ruby
class ClaudeSandbox < Formula
  desc "Run Claude Code in an isolated OrbStack Docker container"
  homepage "https://github.com/nmurray1984/homebrew-claude-toolbox"
  url "https://raw.githubusercontent.com/nmurray1984/homebrew-claude-toolbox/main/bin/claude-sandbox"
  sha256 "SHA256_HASH"
  version "1.0.0"

  def install
    bin.install "claude-sandbox"
  end

  def caveats
    <<~EOS
      Prerequisites:
        - OrbStack must be installed and running (https://orbstack.dev)
        - Your Anthropic API key must be exported in your shell:

            export ANTHROPIC_API_KEY="sk-ant-..."

          Add that line to ~/.zshrc to make it permanent.

      Usage:
        cd /path/to/your/project
        claude-sandbox

      Claude will launch inside a Docker container with access only to
      your current directory. No other files on your Mac are accessible.

      To pass flags to Claude Code directly:
        claude-sandbox --dangerously-skip-permissions
    EOS
  end

  test do
    assert_match "ANTHROPIC_API_KEY", File.read(bin/"claude-sandbox")
  end
end
```

---

## Step 6 — Create `README.md`

Create the file `README.md` with the following content, substituting `nmurray1984` with the actual GitHub nmurray1984:

```markdown
# homebrew-claude-toolbox

Personal Homebrew tap for command-line tools.

## Install

```bash
brew tap nmurray1984/claude-toolbox
brew install claude-sandbox
```

## Tools

### claude-sandbox

Launches [Claude Code](https://docs.anthropic.com/en/docs/claude-code) inside an isolated OrbStack Docker container. Only your current working directory is mounted — no other files on your Mac are accessible inside the container.

**Prerequisites**
- [OrbStack](https://orbstack.dev) installed and running
- `ANTHROPIC_API_KEY` exported in your shell

**Usage**
```bash
cd ~/projects/my-app
claude-sandbox
```

## Updating

When the script changes, recompute the SHA256 and update the formula:
```bash
shasum -a 256 bin/claude-sandbox
# paste the new hash into Formula/claude-sandbox.rb under sha256
# bump the version field too
```

Then commit and push. Users can update with `brew upgrade claude-sandbox`.
```

---

## Step 7 — Commit and Push

Commit all three files and push to the `main` branch:
```bash
git add bin/claude-sandbox Formula/claude-sandbox.rb README.md
git commit -m "Initial release of claude-sandbox v1.0.0"
git push origin main
```

---

## Step 8 — Verify It Works

Test the tap locally by running:
```bash
brew tap nmurray1984/claude-toolbox
brew install claude-sandbox
which claude-sandbox   # should print /usr/local/bin/claude-sandbox or /opt/homebrew/bin/claude-sandbox
```

---

## Future Updates

When you change the script, the update process is:
1. Edit `bin/claude-sandbox`
2. Run `shasum -a 256 bin/claude-sandbox` to get the new hash
3. Update `sha256` and bump `version` in `Formula/claude-sandbox.rb`
4. Commit and push
5. Users (including yourself) run `brew upgrade claude-sandbox`
