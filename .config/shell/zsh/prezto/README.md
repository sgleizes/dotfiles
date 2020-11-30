# Prezto module

This module provides an integration with
[prezto](https://github.com/sorin-ionescu/prezto) for demonstration purposes.
It comes with the default prezto configuration.

The default prezto runcoms were copied or slightly adapted to hook into
xsh's abstract runcoms. Namely:

- [@env.zsh](@env.zsh) is a minor adapation of the original
  [zshenv](https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zshenv).
- [@login.zsh](@login.zsh) is a copy of the original
  [zprofile](https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zprofile).
- [@interactive.zsh](@interactive.zsh) is inspired from the original
  [zshrc](https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zshrc) and
  [zlogin](https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zlogin).

  It sources [preztorc](preztorc), then installs and sources prezto. If the
  shell is a login-shell, it also sources the original zlogin runcom from the
  prezto installation.

- [@logout.zsh](@logout.zsh) is a copy of the original
  [zlogout](https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zlogout).
- [preztorc](preztorc) is a copy of the original
  [zpreztorc](https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zpreztorc).

To migrate your prezto configuration to xsh, you can copy this module and
replace `preztorc` with your own. Any additional customizations made to the
original prezto runcoms should also be reapplied to their equivalent in this
module.

Note that this setup is not ideal for a modular configuration and is only meant
to ease the transition. Feel free to rearrange and customize prezto's default
runcoms in separate modules as you see fit.

If you decide to split your `preztorc` into different xsh modules, make sure that
all modules setting prezto's `zstyle` configuration are registered _before_ the
`prezto` module in your `init.zsh`.
