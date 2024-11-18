{
  system ? builtins.currentSystem,
  lib,
  fetchurl,
  installShellFiles,
  stdenvNoCC,
}:
let
  sources = import ./sources.nix;
  version = sources.version;
  arch = sources.archMap.${system};
  fetchurlAttr = sources.fetchurlAttrSet.${system};
in
stdenvNoCC.mkDerivation {
  pname = "upbound";
  inherit version;
  srcs = [
    (fetchurl {
      url = fetchurlAttr.docker-credential-up.url;
      sha256 = fetchurlAttr.docker-credential-up.hash;
    })

    (fetchurl {
      url = fetchurlAttr.up.url;
      sha256 = fetchurlAttr.up.hash;
    })
  ];

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp ./${arch}/up $out/bin/up
    chmod +x $out/bin/up

    cp ./${arch}/docker-credential-up $out/bin/docker-credential-up
    chmod +x $out/bin/docker-credential-up

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --bash --name up <(echo complete -C up up)
  '';

  system = system;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "CLI for interacting with Upbound Cloud, Upbound Enterprise, and Universal Crossplane (UXP)";
    homepage = "https://upbound.io";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ lucperkins ];
    mainProgram = "up";
    platforms = sources.platformList;
  };
}
