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
