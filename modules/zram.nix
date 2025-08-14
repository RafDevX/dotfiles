{ ... }:

{
  zramSwap = {
    enable = true;
    memoryPercent = 50; # ZRAM swap with half total physical RAM size
  };
}
