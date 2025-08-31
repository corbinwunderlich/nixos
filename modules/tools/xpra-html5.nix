{
  fetchFromGitHub,
  python3,
}: let
  inherit (python3.pkgs) buildPythonApplication;
in
  buildPythonApplication rec {
    pname = "xpra-html5";
    #version = "16.2";
    ##version = "17.x";
    #version = "v17";
    #version = "c858d46";
    version = "f3e71b4";
    format = "other";

    src = fetchFromGitHub {
      owner = "Xpra-org";
      repo = "xpra-html5";
      #rev = "v${version}";
      rev = version;
      #hash = "sha256-ioA3ltY0J9a3jLOXkFwBI6HUDMqYUPyxRO5unOil8xY=";
      #hash = "sha256-LRYyKZEu3amCRjEQ60PWGiDhZnDlQbxH+dae2MZV+wI=";
      #hash = "sha256-SwP7NazsiUyDD4LUziCwN0X9GTQVq0lYM2jXqNaXLEA=";
      #hash = "sha256-cFPMZZwn4ymHGT7LXsDp69Mp9aGuPNJjuh7J4LuisoQ=";
      hash = "sha256-bhok+yLklvpg8j8FBzWrUbXK4yYRd845xQ2vRKto2TI=";
    };

    #patches = [./xor.patch];

    buildPhase = ''
      runHook preBuild

      python3 $src/setup.py install / $out $out/config

      runHook postBuild
    '';

    postInstall = ''
      rm $out/config/default-settings.txt $out/default-settings.txt
      cp ${./default-settings.txt} $out/config/default-settings.txt
      ln -s $out/config/default-settings.txt $out/default-settings.txt

      cp ${./overrides.css} $out/css/overrides.css

      sed -i '/<\/head>/i \    <link rel="stylesheet" href="css/overrides.css" />' $out/*.html
    '';
  }
