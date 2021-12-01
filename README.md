# Dotfiles

These are my personal, opinionated dotfiles.

The main goal is to be able to reproduce the bulk of my terminal and desktop
environments, by versioning the things that I spent time configuring so that
I do not have to spend that time ever again.

I try to keep things configurable, structured and documented, hoping that some
bits might be understandable and usable by other people. But it's also more
maintainable this way.

I try to adhere to the [XDG basedir specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
and [file system hierarchy standard](https://www.freedesktop.org/software/systemd/man/file-hierarchy.html#Home%20Directory),
or more exactly I try to hack these reluctant programs that are still doing it
dirty roughly 20 years after the spec was first published, whenever I find it
reasonable to do so. Because a \$HOME should be clean.

I try to use modern yet mature programs which are being maintained, but
sometimes changing long-lived habits is not worth it.

I try to integrate these programs together into a stable and coherent
environment, but there is always a surprise waiting for me somewhere.

I try to have fun doing it, but sometimes it gets rough.

I do not try to support Mac OS. I don't use that.

## What's in there

- Extensive [`zsh` configuration](.config/shell) using
  [xsh](https://github.com/sgleizes/xsh).
- Extensive [`tmux` configuration](.config/tmux).
- Literate [`emacs` configuration](.config/doom) using
  [doom-emacs](https://github.com/hlissner/doom-emacs).
- Configuration for various terminal programs.
- On the `desktop` branch, configuration for my KDE desktop and various desktop
  applications.

## Requirements

- [zsh](http://zsh.sourceforge.net/) - The most powerful shell for interactive and scripting use.
- [git](https://git-scm.com/) - To not be stuck with your own code.
- [yadm](https://yadm.io/) - A `git` wrapper for dotfiles management.

You can also optionally install [svn](https://subversion.apache.org/),
it is used by the zsh configuration to checkout specific parts of GitHub repositories.

## Integrated terminal programs

These programs are all optional and can be selectively picked.
The `zsh` configuration is organized into modules and will integrate the installed programs automatically.
For some programs, a configuration file is provided in [.config](.config).

- [atool](https://www.nongnu.org/atool/) - A script for managing file archives of various types.
- [advcpmv](https://github.com/jarun/advcpmv) - A patch for GNU Core Utilities cp, mv to add progress bars.
- [bat](https://github.com/sharkdp/bat) - A `cat` clone with wings.
- [bpytop](https://github.com/aristocratos/bpytop) - Linux/OSX/FreeBSD resource monitor.
- [delta](https://github.com/dandavison/delta) - A syntax-highlighter for `git` and `diff` output.
- [direnv](https://github.com/direnv/direnv) - Update the environment based on the current directory.
- [docker](https://github.com/docker/cli) / [docker-compose](https://github.com/docker/compose) - Container management.
- [elinks](http://elinks.or.cz/) - Text-mode web browser.
- [emacs](https://www.gnu.org/software/emacs/) / [doom-emacs](https://github.com/hlissner/doom-emacs) - An extensible, customizable, free/libre text editor.
- [expac](https://github.com/falconindy/expac) - Data extraction tool for alpm databases (`pacman`).
- [exa](https://github.com/ogham/exa) - A modern version of `ls`.
- [fasd](https://github.com/clvv/fasd) - Quick access to frecent files and directories.
- [fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to `find`.
- [fortune](https://github.com/shlomif/fortune-mod) / [ponysay](https://github.com/erkin/ponysay) - A courtesy of the terminal.
- [fpp](https://github.com/facebook/pathpicker/) - Selecting files from command output.
- [fzf](https://github.com/junegunn/fzf) - A command line fuzzy finder.
- [git-extras](https://github.com/tj/git-extras) - Extra `git` commands from the community.
- [gpg](https://gnupg.org/) - Hybrid encryption software suite.
- [hex](https://github.com/sitkevij/hex) - Futuristic take on hexdump, made in Rust.
- [htop](https://github.com/hishamhm/htop) - Interactive process viewer and system monitor.
- [hub](https://hub.github.com/) - GitHub from the command line.
- [jq](https://github.com/stedolan/jq) - Command line JSON processor.
- [kmon](https://github.com/orhun/kmon) - Linux kernel manager and activity monitor.
- [lazygit](https://github.com/jesseduffield/lazygit) - Simple terminal UI for `git` commands.
- [nnn](https://github.com/jarun/nnn/) - n³ The unorthodox terminal file manager.
- [nordvpn](https://nordvpn.com/) - Private and secure internet access.
- [pistol](https://github.com/doronbehar/pistol) - General purpose file previewer.
- [rclone](https://github.com/rclone/rclone) - Rsync for cloud storage.
- [restic](https://github.com/restic/restic) - Fast, secure, efficient backup program.
- [ripgrep](https://github.com/BurntSushi/ripgrep) - A modern version of `grep`.
- [rsync](https://github.com/WayneD/rsync) - Versatile file copying tool for remote and local files.
- [ssh](https://www.openssh.com/) - OpenSSH remote login client.
- [tldr](https://github.com/tldr-pages/tldr) / [tealdeer](https://github.com/dbrgn/tealdeer/) - Simplified and community-driven man pages.
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer.
- [tmux-xpanes](https://github.com/greymd/tmux-xpanes) - Awesome tmux-based terminal divider.
- [trash-cli](https://github.com/sindresorhus/trash-cli) - Move files and folders to the trash.
- [unison](https://www.cis.upenn.edu/~bcpierce/unison/) - Bidirectional file synchronization.
- [wget](https://www.gnu.org/software/wget/) - Downloading remote files.
- [youtube-dl](https://github.com/ytdl-org/youtube-dl) - Download videos from various platforms.

## Zsh plugins

The `zsh` configuration is defined via [xsh](.xsh/zsh/init.zsh) and uses
[zinit](https://github.com/zdharma/zinit) as plugin manager, allowing for
asynchronous loading and lightning fast startup times. Some of the modules are
inspired from [prezto](https://github.com/sorin-ionescu/prezto), and some prezto
modules are also directly installed via `zinit`.

Here is a non exhaustive list of integrated external plugins:

- [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-completions](https://github.com/zsh-users/zsh-completions)
- [zsh-fast-syntax-highlighting](https://github.com/zdharma/fast-syntax-highlighting)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
- [zsh-git-escape-magic](https://github.com/knu/zsh-git-escape-magic)
- [zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use)
- [LS_COLORS](https://github.com/trapd00r/LS_COLORS)

## Installation

```sh
yadm clone --bootstrap 'git@github.com:sgleizes/dotfiles.git'
```

Or, to install the desktop environment as well:

```sh
yadm clone --bootstrap 'git@github.com:sgleizes/dotfiles.git' -b desktop
```
