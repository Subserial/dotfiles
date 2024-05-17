{ config, ... }:
{
	hardware.i2c.enable = true;
	boot.initrd.kernelModules = [ "i2c-dev" ];
}
