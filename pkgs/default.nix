{ pkgs, ... }:
{
  pyzo = pkgs.qt6.callPackage ./pyzo.nix { };

  vimPlugins = {
    zsh-nix-shell = import ./vim-zsh-nix-shell.nix pkgs;
  };
}
