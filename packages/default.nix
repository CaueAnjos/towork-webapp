{
  perSystem = {pkgs, ...}: rec {
    packages.ui = pkgs.callPackage ./ui.nix {};
    packages.mvc = pkgs.callPackage ./mvc.nix {};
    packages.docker = pkgs.callPackage ./docker_img.nix {
      drv = packages.mvc;
    };
  };
}
