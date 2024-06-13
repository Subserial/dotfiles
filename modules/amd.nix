{ pkgs, ... }:
{
	boot.initrd.availableKernelModules = [ "amdgpu" ];
	boot.initrd.kernelModules = [ "amdgpu" ];
	hardware.opengl = {
		extraPackages = [ pkgs.amdvlk ];
		extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
	};
}
