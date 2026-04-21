{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  client,
}: let
  inherit (lib.fileset) toSource unions fileFilter;

  # NOTE: the root dir of the project!
  root = ../src/towork;

  src = builtins.path {
    path = toSource {inherit root fileset;};
    name = "towork-root";
  };

  fileset = unions [
    (fileFilter (file: file.hasExt "cs" || file.hasExt "csproj") root)
    (root + "/Views")
    (root + "/wwwroot")
  ];
in
  buildDotnetModule rec {
    pname = "towork";
    version = "0.1.0";
    inherit src;
    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_10_0-bin;
    packNupkg = true;
    nugetDeps = ./deps.json;
    makeWrapperArgs = [
      "--set"
      "DOTNET_CONTENTROOT"
      "${placeholder "out"}/lib/${pname}"
    ];

    preBuild = ''
      cp ${./../README.md} "README.md"
      cp ${./../LICENSE} "LICENSE"

      rm -rf "wwwroot"
      mkdir -p "wwwroot"
      cp -r ${client}/. "wwwroot"
    '';

    meta.mainProgram = "towork";
  }
