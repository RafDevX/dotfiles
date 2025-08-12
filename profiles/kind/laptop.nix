{ profiles, ... }:

{
  imports = with profiles; [
    kind.pc # a laptop is a PC
    misc.auto-timezone
  ];

}
