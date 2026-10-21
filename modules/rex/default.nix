{config, ...}: {
  xdg.configFile = {
    "rex/init.lua".source = ./init.lua;
    "rex/themes/joncarl".source = ./theme;
  };
}
