{
  perSystem = {
    pkgs,
    lib,
    ...
  }: rec {
    apps = {
      "dev" = apps."dev:webapp";
      "dev:webapp" = {
        program = lib.getExe (pkgs.writeShellApplication {
          name = "start-dev";
          runtimeInputs = with pkgs; [
            podman
          ];
          text = ''
            # shellcheck disable=SC1091
            set -e

            ${apps."dev:db-up".program}

            cleanup() {
                ${apps."dev:db-down".program}
            }

            trap cleanup EXIT

            dotnet ef database update --project src/ToworkMVC
            dotnet watch run --project src/ToworkMVC -lp https
          '';
        });
      };

      "dev:db" = apps."dev:db-up";
      "dev:db-up" = {
        program = lib.getExe (pkgs.writeShellApplication {
          name = "start-db";
          runtimeInputs = with pkgs; [
            podman
          ];
          text = builtins.readFile ./start-up-db.bash;
        });
      };

      "dev:db-down" = {
        program = lib.getExe (pkgs.writeShellApplication {
          name = "end-db";
          runtimeInputs = with pkgs; [
            podman
          ];
          text = builtins.readFile ./end-up-db.bash;
        });
      };
    };
  };
}
