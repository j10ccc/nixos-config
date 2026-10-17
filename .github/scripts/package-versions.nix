# Applied (via `nix eval --apply`) to `darwinConfigurations` or
# `homeConfigurations`; returns { <Host> = { <pname> = <version>; }; }.
# Only evaluates package names, so Darwin hosts work on a Linux runner.
configs:
let
  inherit (builtins)
    attrValues
    concatLists
    filter
    foldl'
    head
    isString
    listToAttrs
    mapAttrs
    match
    parseDrvName
    pathExists
    readFile
    split
    substring
    ;

  hostPackages =
    cfg:
    let
      c = cfg.config;
    in
    if c ? home-manager then
      c.environment.systemPackages
      ++ concatLists (map (u: u.home.packages) (attrValues c.home-manager.users))
    else
      c.home.packages;

  pkgVersion =
    p:
    let
      parsed = parseDrvName (p.name or "");
    in
    {
      name = p.pname or parsed.name;
      version = p.version or parsed.version;
    };

  # Homebrew formulae/casks are pinned by the tap inputs, so read the version
  # out of the tap's Ruby file (best effort: `version "x"`, `tag: "vx"`, or a
  # versioned tarball url).
  brewVersion =
    tap: dir: name:
    let
      shard = if dir == "Formula" && substring 0 3 name == "lib" then "lib" else substring 0 1 name;
      file = "${tap}/${dir}/${shard}/${name}.rb";
      lines = filter isString (split "\n" (readFile file));
      patterns = [
        "[[:space:]]*version \"([^\"]+)\".*"
        "[[:space:]]*tag:[[:space:]]*\"v?([^\"]+)\".*"
        "[[:space:]]*url \".*/v?([0-9]+(\\.[0-9]+)+)\\.(tar\\.gz|tgz|tar\\.xz|zip)\".*"
      ];
      found = foldl' (
        acc: pat:
        if acc != null then
          acc
        else
          let
            hits = filter (m: m != null) (map (match pat) lines);
          in
          if hits == [ ] then null else head (head hits)
      ) null patterns;
    in
    if !pathExists file then
      "?"
    else if found == null then
      "?"
    else
      found;

  brewPackages =
    c:
    let
      taps = c.nix-homebrew.taps or { };
      entries =
        tapName: dir: kind: names:
        if taps ? ${tapName} then
          map (n: {
            name = "${n} (${kind})";
            value = brewVersion taps.${tapName} dir n;
          }) names
        else
          [ ];
      # brews/casks may be strings or { name = ...; } submodules.
      names = map (x: if isString x then x else x.name);
    in
    if !(c.homebrew.enable or false) then
      { }
    else
      listToAttrs (
        entries "homebrew/homebrew-core" "Formula" "brew" (names c.homebrew.brews)
        ++ entries "homebrew/homebrew-cask" "Casks" "cask" (names c.homebrew.casks)
      );

  # pname -> version; duplicates with differing versions are joined.
  toAttrs = foldl' (
    acc: p:
    let
      v = pkgVersion p;
      prev = acc.${v.name} or null;
    in
    if v.version == "" || prev == v.version then
      acc
    else
      acc // { ${v.name} = if prev == null then v.version else "${prev}, ${v.version}"; }
  ) { };
in
mapAttrs (_: cfg: toAttrs (hostPackages cfg) // brewPackages cfg.config) configs
