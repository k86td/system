{ pkgs, ... }:
{
  home.packages = with pkgs; [
    _1password-gui
  ];

  xdg.desktopEntries = {
    "1passsword" = {
      name = "1Password";
      genericName = "Password Manager";
      exec = "1password --ozone-platform-hint=x11 %U";
      terminal = false;
      mimeType = [
        "x-scheme-handler/onepassword"
      ];
      type = "Application";
    }; 
  };
}
