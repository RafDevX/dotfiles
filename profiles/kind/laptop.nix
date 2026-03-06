{ profiles, ... }:

{
  imports = with profiles; [
    kind.pc # a laptop is a PC
    misc.auto-timezone
    misc.oomd
  ];

  rso.me.hashedPassword = "$y$j9T$AgJhH28Mik/VmKWy979af0$3Z9vLnJR.D/fp/g2ym.ZbxaAqDZay4fORkkBcGGlTi9";
}
