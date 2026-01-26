{
  perSystem = {pkgs, ...}: {
    packages.ui = pkgs.callPackage ./ui.nix {};
    packages.mvc = pkgs.callPackage ./mvc.nix {};
  };
}
