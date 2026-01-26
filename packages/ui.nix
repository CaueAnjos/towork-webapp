{
  stdenv,
  pnpm_9,
}:
stdenv.mkDerivation {
  pname = "towork-ui";
  src = ../src/towork-ui;

  nativeBuildInputs = [
    pnpm_9
  ];

  buildPhase = ''
    cd $src
    pnpm run build
    cp -r dist $out
  '';
}
