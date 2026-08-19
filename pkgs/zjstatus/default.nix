{ stdenvNoCC, fetchurl, lib }:

# zjstatus —— zellij 的状态栏插件（https://github.com/dj95/zjstatus），
# 上游只发 wasm，不进 nixpkgs，所以直接拉发布产物。
# wasm 是平台无关的，三台主机（含 Linux 的 Goldenage）共用同一份。
#
# 升级：改 version，再对新 URL 跑 `nix-prefetch-url` 换掉 sha256。
# 注意 zjstatus 是按 zellij 的插件 API 编译的，换 zellij 大版本时要一起验。
let
  version = "0.24.0";
in
stdenvNoCC.mkDerivation {
  pname = "zjstatus";
  inherit version;

  src = fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v${version}/zjstatus.wasm";
    sha256 = "16v6ascpyl7na6lp3v98haggp9lwsg6r1rlv40zcyqpd3p7dxkhw";
  };

  dontUnpack = true;

  # 不是可执行文件，但放 bin/ 引用路径好写。
  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/bin/zjstatus.wasm
    runHook postInstall
  '';

  meta = with lib; {
    description = "zellij 状态栏插件（预编译 wasm）";
    homepage = "https://github.com/dj95/zjstatus";
    license = licenses.mit;
    platforms = platforms.all;
    sourceProvenance = [ sourceTypes.binaryBytecode ];
  };
}
