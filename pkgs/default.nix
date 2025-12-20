{ pkgs, ... }:
{
	pyzo = pkgs.qt6.callPackage ./pyzo.nix { };
}
