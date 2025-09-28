{
  pkgs,
  input,
  ...
}: {
  isNormalUser = true;
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFzov5sHEwNSSuEvPwuYoA4cHpn2ua2hi/5YMT6N6tL"
  ];
  extraGroups = ["networkmanager" "wheel" "render" "docker" "dialout" "credentials" "pulse-access"];
}
