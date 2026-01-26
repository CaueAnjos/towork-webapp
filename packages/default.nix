{
  perSystem = {pkgs, ...}: {
    packages.ui = pkgs.callPackage ./ui.nix;
  };
}
