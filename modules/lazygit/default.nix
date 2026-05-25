{ ... }:

{
  programs.lazygit = {
    enable = true;
    settings.gui = {
      showCommandLog = false;
      showBottomLine = false;
      showRandomTip = false;
      expandFocusedSidePanel = true;
      sidePanelWidth = 0.25;
    };
  };
}
