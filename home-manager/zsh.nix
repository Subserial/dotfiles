{ ... }:
{
	# This is a home-manager module!

	programs.zsh = {
		enable = true;
		autosuggestion.enable = true;
		oh-my-zsh = {
			enable = true;
			plugins = [ ];
		};
		# TODO: Port my old config (or don't?)
	};

	programs.starship = {
		enable = true;
		enableZshIntegration = true;
	};
}
