{
  perSystem = {
    self',
    pkgs,
    ...
  }: {
    packages = {
      default = self'.packages.towork;

      client = pkgs.callPackage ./client.nix {};
      towork = pkgs.callPackage ./towork.nix {
        inherit (self'.packages) client;
      };
      toworkDocker = pkgs.callPackage ./docker_img.nix {
        drv = self'.packages.towork;
      };
    };
  };
}
