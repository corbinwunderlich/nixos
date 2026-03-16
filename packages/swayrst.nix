{
  python3,
  fetchFromGitHub,
  ...
}:
python3.pkgs.buildPythonPackage rec {
  pname = "swayrst";
  version = "1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Nama";
    repo = "swayrst";
    rev = version;
    hash = "sha256-+tIsSegkLdqNDbrT47e5RusdWBmzUWNlVYLDwLEQ5v4=";
  };

  build-system = with python3.pkgs; [setuptools];

  dependencies = with python3.pkgs; [i3ipc];

  postInstall = ''
    rm -rf $out/bin/swayrst.py
  '';
}
