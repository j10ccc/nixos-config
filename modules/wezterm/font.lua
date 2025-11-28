local wezterm = require "wezterm";
local module = {};

function module.apply_to_config(config)
  config.font = wezterm.font_with_fallback {
    "MonaspiceNe Nerd Font Mono",
    "Noto Sans CJK SC"
  };
  config.font_size = 16;
end;

return module;
