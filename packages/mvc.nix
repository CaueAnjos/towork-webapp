{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  ui,
}: let
  inherit (lib.fileset) toSource unions fileFilter;
  inherit (lib.fileset) trace;

  # NOTE: the root dir of the project!
  root = ../src/ToworkMVC;

  src = builtins.path {
    path = toSource {inherit root fileset;};
    name = "mvc-root";
  };

  fileset = unions [
    (fileFilter (file: file.hasExt "cs" || file.hasExt "csproj") root)
    (root + "/Views")
    (root + "/wwwroot")
  ];
in
  trace fileset
  buildDotnetModule rec {
    pname = "ToworkMVC";
    version = "0.1.0";
    inherit src;
    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_10_0-bin;
    nugetDeps = ./deps.json;
    makeWrapperArgs = [
      "--set"
      "DOTNET_CONTENTROOT"
      "${placeholder "out"}/lib/${pname}"
    ];

    postInstall = ''
      mkdir -p $out/lib/${pname}/wwwroot
      cp -r ${ui}/. $out/lib/${pname}/wwwroot/
    '';

    meta.mainProgram = "ToworkMVC";
  }
