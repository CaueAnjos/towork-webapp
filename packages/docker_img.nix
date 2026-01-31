{
  lib,
  dockerTools,
  drv ? null,
}:
dockerTools.buildLayeredImage {
  name = drv.pname;
  tag = "latest";
  contents = [drv];
  config = {
    Cmd = [(lib.getExe drv)];
    Env = [
      "ASPNETCORE_URLS=http://0.0.0.0:5000"
    ];
    ExposedPorts = {
      "5000/tcp" = {};
    };
  };
}
