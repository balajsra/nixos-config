{ self, ... }:

{
  flake.nixosModules.graphics = {
    imports = [
      self.nixosModules.amd-gpu
      self.nixosModules.nvidia-gpu
    ];
  };

  flake.nixosModules.amd-gpu =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.graphics.amd-gpu.enable) {
        # https://wiki.nixos.org/wiki/AMD_GPU
        hardware = {
          graphics = {
            enable = true;
            enable32Bit = true;
          };
          amdgpu = {
            initrd.enable = true;
            opencl.enable = true;
            overdrive.enable = false;
            zluda.enable = true;
          };
        };
      };
    };

  flake.nixosModules.nvidia-gpu =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.graphics.nvidia-gpu.enable) {
        # https://wiki.nixos.org/wiki/NVIDIA
        services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
        hardware = {
          graphics = {
            enable = true;
            enable32Bit = true;
          };
          nvidia = {
            modesetting.enable = true;
            open = true;
            nvidiaSettings = true;
            videoAcceleration = true;
          };
        };
      };
    };
}
