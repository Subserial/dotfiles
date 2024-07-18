{ pkgs, ... }:
{
	boot.initrd.availableKernelModules = [ "amdgpu" ];
	boot.initrd.kernelModules = [ "amdgpu" ];
	hardware.graphics = {
		extraPackages = [ pkgs.amdvlk ];
		extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
	};
}
