{ pkgs, ... }:
{
  pyzo = pkgs.qt6.callPackage ./pyzo.nix { };
  beskope = pkgs.callPackage ./beskope.nix { };

  vimPlugins = {
    zsh-nix-shell = import ./vim-zsh-nix-shell.nix pkgs;
  };
}
