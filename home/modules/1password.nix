{ pkgs, ... }:
{
  # home.packages = with pkgs; [
  #   _1password-gui
  # ];

  xdg.desktopEntries = {
    "1password" = {
      name = "1Password";
      genericName = "Password Manager";
      exec = "1password --ozone-platform=x11 %U";
      terminal = false;
      categories = [ "Application" ];
    }; 
  };

}

