{
  buildDotnetModule,
  dotnetCorePackages,
}:
buildDotnetModule rec {
  pname = "ToworkMVC";
  version = "0.1.0";
  src = ../src/ToworkMVC;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  nugetDeps = ./deps.json;
  makeWrapperArgs = [
    "--set"
    "DOTNET_CONTENTROOT"
    "${placeholder "out"}/lib/${pname}"
  ];
}
