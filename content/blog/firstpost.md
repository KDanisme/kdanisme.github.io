---
title: Running nix in a container
description: Building a container with nix for running nix
date: 2018-08-28
tags:
  - nix
---

## TLDR

Here's a working minimal-uish nix container package thats pre-configured with flakes:

```
{
  dockerTools,
  lib,
  coreutils,
  fakeNss,
  gitMinimal,
  gnutar,
  gzip,
  nix,
  openssh,
  writeShellScriptBin,
  xz,
  writeTextFile,
}: dockerTools.buildImageWithNixDb {
  name = "nix";
  copyToRoot =
    [
      coreutils
      nix
      gitMinimal
      gnutar
      gzip
      openssh
      xz
      (fakeNss.override {
        extraPasswdLines = with lib; forEach (range 1 32) (i: "nixbld${builtins.toString i}:x:${builtins.toString (30000 + i)}:30000:Nix build user ${builtins.toString i}:/var/empty:/run/current-system/sw/bin/nologin");
        extraGroupLines = [
          "nixbld:x:30000:${lib.concatStringsSep "," (with lib; forEach (range 1 32) (i: "nixbld${builtins.toString i}"))}"
        ];
      })
      (writeTextFile {
        name = "nix.conf";
        destination = "/etc/nix/nix.conf";
        text = ''
          experimental-features = nix-command flakes
        '';
      })
    ]
    ++ (
      with dockerTools; [
        usrBinEnv
        binSh
        caCertificates
      ]
    );

  extraCommands = ''
    # Make sure /tmp and /var/tmp exists for programs that require them
    chmod 1777 var
    mkdir -p -m 1777 tmp var/tmp
  '';

  config = {
    Cmd = ["/bin/sh"];
    Env = [
      "ENV=${nix}/etc/profile.d/nix.sh"
      "BASH_ENV=${nix}/etc/profile.d/nix.sh"
      "USER=root"
    ];
  };
}
```

## Exposition

I'm tired if making, updating, and breaking my Dockerfiles.

In my dream world, I don't need "CI-CD" for deploying my apps, I want to `nix run <my-awesome-api>` straight in production.

Sadly, this isn't the case, stuff like [nixops](https://github.com/NixOS/nixops) is dead (althoguh new stuff is cooking [nixops4](https://github.com/nixops4/nixops4)).
I still havn't tried nomad yet.
And the kuberentes craze isn't stopping soon. I do admit, helm charts and operators are huge timesavers sometimes.

So it seems like I must still rely on ~~good~~ old containers for deploying everything.

Now, to build containers, I need nix. And where are my CI jobs running on? containers ofcours. Therefore the obvious conclusion, is that I need, nay, WANT a minimal nix container.

<!-- ```diff-js -->
<!--  // this is a command -->
<!--  function myCommand() { -->
<!-- +  let counter = 0; -->
<!-- -  let counter = 1; -->
<!--    counter++; -->
<!--  } -->
<!---->
<!--  // Test with a line break above this line. -->
<!--  console.log('Test'); -->
<!-- ``` -->
