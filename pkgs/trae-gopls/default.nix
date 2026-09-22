{
  stdenvNoCC,
  fetchurl,
  lib,
}:

# Trae 内网 gopls，预编译二进制，等价于内网 Homebrew tap
# flow/trae-gopls 分发的产物（brew 本质也只是下载同一个 TOS 二进制）。
# 升级：改 version，再对新 URL 跑 `nix-prefetch-url` 换掉对应 sha256。
let
  version = "v0.22.0+bd2";
  base = "https://tosv-myabc.byted.org/obj/trae-common-2-asiasebd/trae-gopls";

  # 按平台选二进制；以后要加 x86_64-darwin / linux 在这里补即可。
  binaries = {
    aarch64-darwin = {
      suffix = "gopls-darwin-arm64";
      sha256 = "0iangnn122ic3dn8n46bmsfv4kb8xhz35b5yyrx69sr0vffy9sqr";
    };
  };

  bin =
    binaries.${stdenvNoCC.hostPlatform.system}
      or (throw "trae-gopls: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "trae-gopls";
  inherit version;

  src = fetchurl {
    url = "${base}/${version}/${bin.suffix}";
    inherit (bin) sha256;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/trae-gopls
    runHook postInstall
  '';

  meta = with lib; {
    description = "Trae 内网 gopls 预编译版";
    platforms = builtins.attrNames binaries;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
