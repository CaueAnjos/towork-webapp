{
  stdenv,
  pnpm_9,
  nodejs_20,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "towork-client";
  version = "0.1.0";

  src = ../src/client;

  nativeBuildInputs = [pnpm_9 nodejs_20];

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 1;
    hash = "sha256-VDYXESaWA92f8KWvrMmVFWMn3BLkp+njErq8Pq/MUlM=";
  };

  configurePhase = ''
    export HOME=$(mktemp -d)
    pnpm config set store-dir ${finalAttrs.pnpmDeps}
    pnpm install --offline --frozen-lockfile --ignore-scripts
  '';

  buildPhase = ''
    pnpm run build
  '';

  installPhase = ''
    cp -r dist/. $out/
  '';
})
