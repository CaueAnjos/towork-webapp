{inputs, ...}: {
  imports = [
    inputs.flake-parts.flakeModules.bundlers
  ];

  perSystem = {
    self',
    pkgs,
    lib,
    config,
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

    bundlers = let
      inherit (lib) elem concatLines forEach;

      bundlers = inputs.bundlers.bundlers.${pkgs.system};
      formats = ["deb" "rpm" "appimage" "nupkg"];
      outPath = "$out/${pkgs.system}";

      mkBundle = drv: format: let
        bundlePath = self'.bundlers.${format} drv;
        copyCommand = "cp -r ${bundlePath} ${outPath}/${format}";
        mkdirCommand = "mkdir -p ${outPath}/${format}";
      in
        if !elem format ["appimage"]
        then copyCommand
        else concatLines [mkdirCommand copyCommand];
      mkDeployBundle = drv: concatLines (forEach formats (format: mkBundle drv format));
    in {
      deb = bundlers.toDEB;
      rpm = bundlers.toRPM;
      appimage = bundlers.toAppImage;
      nupkg = drv: let
        nupkg = "${drv.pname}.${drv.version}.nupkg";
      in
        pkgs .runCommandLocal "nupkg" {} ''
          mkdir -p $out
          cp ${drv}/share/nuget/source/${drv.pname}/0.1.0/${nupkg} $out/${nupkg}
        '';

      default = self'.bundlers.deploy;
      deploy = drv:
        pkgs.runCommandLocal "deploy" {} ''
          mkdir -p "${outPath}"
          ${mkDeployBundle drv}
        '';
    };
  };
}
