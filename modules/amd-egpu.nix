{ pkgs, ... }:
{
	# disable iGPU (intel) (I hate you)
	boot.blacklistedKernelModules = [ "i915" ];

	boot.kernelParams = [
		"module_blacklist=i915"
	
		# "Forcibly tell the amdgpu driver that it should be running at PCIe 3.0 speeds"
		"amdgpu.pcie_gen_cap=0x40000"
	];
}
