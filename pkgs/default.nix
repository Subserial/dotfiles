{ pkgs, ... }:
{
  pyzo = pkgs.qt6.callPackage ./pyzo.nix { };

  vimPlugins = {
    vimini = import ./vim-vimini.nix { pkgs = pkgs; };
  };
}
