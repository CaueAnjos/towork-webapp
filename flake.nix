{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;
      imports = [
        ./scripts
        ./packages
      ];

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShellNoCC {
          name = "dev";
          packages = with pkgs; [
            # NOTE: C#
            csharpier
            dotnetCorePackages.sdk_10_0

            # NOTE: js/ts
            nodejs_20
            pnpm_9

            # NOTE: for containers
            podman
            podman-compose
            runc
            conmon
            skopeo
            slirp4netns
            fuse-overlayfs

            # NOTE: Azure
            azure-cli
          ];

          env = {
            DOCKER_COMMAND = "podman";
            ASPNETCORE_ENVIRONMENT = "Development";
          };

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
