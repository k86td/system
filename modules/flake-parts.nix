{ inputs, ... }: {
  imports = [ inputs.home-manager.flakeModules.default ];

  systems = [ "x86_64-linux" ];
}
