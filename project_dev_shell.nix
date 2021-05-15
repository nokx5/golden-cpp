{ pkgs, project_clang, project_gcc }:

with pkgs;

let
  clangSupport = true;
  cudaSupport = false;
  stdenv = if clangSupport then clangStdenv else gccStdenv;
  project = if clangSupport then project_clang else project_gcc;

  vscodeExt = vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions;
      [ bbenoist.Nix eamodio.gitlens ms-vscode.cpptools ]
      ++ vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "cmake-tools";
          publisher = "ms-vscode";
          version = "1.7.3";
          sha256 = "6UJSJETKHTx1YOvDugQO194m60Rv3UWDS8UXW6aXOko=";
        }
        {
          name = "emacs-mcx";
          publisher = "tuttieee";
          version = "0.31.0";
          sha256 = "McSWrOSYM3sMtZt48iStiUvfAXURGk16CHKfBHKj5Zk=";
        }
        {
          name = "cmake";
          publisher = "twxs";
          version = "0.0.17";
          sha256 = "CFiva1AO/oHpszbpd7lLtDzbv1Yi55yQOQPP/kCTH4Y=";
        }
      ];
  };
in (mkShell.override { inherit stdenv; }) rec {
  nativeBuildInputs = [
    # stdenv.cc.cc
    # libcxxabi	      
    bashCompletion
    cacert
    clang-tools
    cmake-format
    cmakeCurses
    gdb
    git
    gnumake
    nixfmt
    pkg-config
    emacs-nox
    vscodeExt
  ] ++ [ pandoc hugo typora ] ++ project.nativeBuildInputs;
  buildInputs = [
    zlib # stdenv.cc.cc.lib
  ] ++ project.buildInputs;

  shellHook = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
  '';

}
