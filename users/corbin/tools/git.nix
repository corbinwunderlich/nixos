{...}: {
  programs.git = {
    enable = true;

    settings = {
      pull.rebase = true;

      user = {
        name = "Corbin Wunderlich";
      };
    };
  };
}
