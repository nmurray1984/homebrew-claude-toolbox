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
