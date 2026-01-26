{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      imports = [
        ./scripts
      ];

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShellNoCC {
          name = "dev";
          packages = with pkgs; [
            dotnetCorePackages.sdk_10_0
            csharpier
            nodejs_20

            # NOTE: for containers
            podman
            podman-compose
            runc
            conmon
            skopeo
            slirp4netns
            fuse-overlayfs
          ];

          shellHook = let
            podmanSetupScript = let
              registriesConf = pkgs.writeText "registries.conf" ''
                [registries.search]
                registries = ['docker.io']

                [registries.block]
                registries = []
              '';
            in
              pkgs.writeScript "podman-setup" ''
                #!${pkgs.runtimeShell}

                # Dont overwrite customised configuration
                if ! test -f ~/.config/containers/policy.json; then
                  install -Dm555 ${pkgs.skopeo.src}/default-policy.json ~/.config/containers/policy.json
                fi

                if ! test -f ~/.config/containers/registries.conf; then
                  install -Dm555 ${registriesConf} ~/.config/containers/registries.conf
                fi
              '';
          in ''
            ${podmanSetupScript};
          '';
        };
      };
    };
}
