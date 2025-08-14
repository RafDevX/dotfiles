# Raf's NixOS Configuration

This repository contains my personal configuration files. Structure will improve
(slowly) over time.

## Deploying

### Current Host

```sh
sudo nixos-rebuild switch --flake .
```

### Remote Host

```sh
nixos-rebuild switch --flake .#avior --target-host avior.rso.pt --use-remote-sudo
```

## Updating

Run

```sh
nix flake update
git add flake.lock
git commit -m "update flake.lock to latest upstream"
sudo nixos-rebuild switch --flake .
```

## Profiles vs Modules

First of all: a profile _is_ a module. However, here NixOS modules are
semantically split into 3 families:

- **Host configuration:** the main parent, living at `hosts/<name>/default.nix`
  that decides which components are necessary for each particular host and sets
  whichever options are relevant;
- **Profiles:** small units of configurations, living in `profiles/`, that can
  be selectively applied for each host (or not) by directly mentioning them in
  the main host configuration's `imports` declaration (or in another, more
  encompassing profile); and
- **Modules:** more complex blocks of configuration, living in `modules/`, that
  shine in flexibility and often wrap service definitions with a new, simpler
  interface. They take in their own options, and are always included
  indiscriminately for all hosts (though usually guarded behind an enable
  option).

In general, use a module if it needs to be flexible and thus relies on taking in
multiple options; otherwise, use a profile if the only option it would have is
an enable one (because the profiles mechanism is precisely intended to replace
singular enable options).

On the other hand, if it would take _no_ options whatsoever (i.e., always
enabled), then it should also be a module, since profiles are designed for
conditional inclusion, and in this case there is no condition.
