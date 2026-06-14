{ pkgs, ... }:
pkgs.vimUtils.buildVimPlugin {
  pname = "vimini";
  version = "2026-05-17";
  src = pkgs.fetchFromGitHub {
    owner = "simo5";
    repo = "vimini";
    rev = "5dff49b70318d16159bc29afee027863182b0a99";
    hash = "sha256-NboZJg1WOw1eFIMSKCzbvmEcYL2laOjPth9hq+B7T3o=";
  };
  passthru.python3Dependencies =
    ps: with ps; [
      google-api-python-client
      google-genai
    ];
}
