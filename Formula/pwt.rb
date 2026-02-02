class Pwt < Formula
  desc "Power Worktrees - Git worktree manager for multiple projects"
  homepage "https://github.com/jonasporto/pwt"
  url "https://github.com/jonasporto/pwt/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "6905ed7459c1e2da2832d78672d1f3b06013bf6d65dc67c01ed4e67918235fe5"
  license "MIT"

  depends_on "jq"

  def install
    bin.install "bin/pwt"
    lib.install Dir["lib/pwt"]
    man1.install "man/pwt.1"
    bash_completion.install "completions/pwt.bash" => "pwt"
    zsh_completion.install "completions/_pwt"
    fish_completion.install "completions/pwt.fish"
    
    # Install bundled plugins
    (share/"pwt/plugins").install Dir["plugins/pwt-*"]
  end

  def post_install
    # Create user plugins directory and symlink bundled plugins
    plugins_dir = Pathname.new(Dir.home)/".pwt/plugins"
    plugins_dir.mkpath unless plugins_dir.exist?
    
    # Symlink bundled plugins to user directory
    (share/"pwt/plugins").children.each do |plugin|
      target = plugins_dir/plugin.basename
      target.unlink if target.symlink? || target.exist?
      target.make_symlink(plugin)
    end
  end

  def caveats
    <<~EOS
      To enable shell integration, add to your shell config:

        # zsh (~/.zshrc)
        eval "$(pwt shell-init zsh)"

        # bash (~/.bashrc)
        eval "$(pwt shell-init bash)"

        # fish (~/.config/fish/config.fish)
        pwt shell-init fish | source

      Bundled plugins installed:
        - aitools: AI integration (topology, context)
        - extras: Utilities (benchmark, marker, conflicts, prompt)

      Run 'pwt doctor' to verify your setup.
    EOS
  end

  test do
    assert_match "pwt version", shell_output("#{bin}/pwt --version")
  end
end
