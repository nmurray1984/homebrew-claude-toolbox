class ClaudeSandbox < Formula
  desc "Run Claude Code in an isolated OrbStack Docker container"
  homepage "https://github.com/nmurray1984/homebrew-claude-toolbox"
  url "https://raw.githubusercontent.com/nmurray1984/homebrew-claude-toolbox/main/bin/claude-sandbox"
  sha256 "5728f4ab5645f01952ef110f6eafd7f5bce8b54c076210eb5d0bb627fc749fa0"
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
