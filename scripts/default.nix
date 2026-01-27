{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    mkProgram = name: desc: runtimeInputs: text: rec {
      inherit name desc;
      script = pkgs.writeShellApplication {
        inherit name runtimeInputs text;
      };
    };

    mkApp = {
      desc,
      script,
      ...
    }: {
      program = lib.getExe script;
      meta.description = desc;
    };

    programs = {
      webapp =
        mkProgram "start-webapp"
        "runs the ToworkMVC server with postgresql server" [
          pkgs.podman
          programs.db-up.script
          programs.db-down.script
        ]
        (builtins.readFile ./start-webapp.bash);

      db-up =
        mkProgram "start-db"
        "starts the postgresql server"
        [pkgs.podman]
        (builtins.readFile ./start-up-db.bash);
      db-down =
        mkProgram "end-db"
        "ends postgresql server"
        [pkgs.podman]
        (builtins.readFile ./end-up-db.bash);

      ui =
        mkProgram "start-ui"
        "starts towork-ui server"
        [pkgs.pnpm_9]
        (builtins.readFile ./start-ui.bash);
    };
  in rec {
    apps = {
      "dev" = apps."dev:webapp";
      "dev:webapp" = mkApp programs.webapp;

      "dev:ui" = mkApp programs.ui;

      "dev:db" = apps."dev:db-up";
      "dev:db-up" = mkApp programs.db-up;
      "dev:db-down" = mkApp programs.db-down;
    };
  };
}
