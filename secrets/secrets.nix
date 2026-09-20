# agenix recipients for this project's secrets.
#
# House convention (see ~/src/etc-nixos-configuration): a project's secrets
# live in the project repo and the host config reaches them through
# ${inputs.refl}/secrets/*.age. Only the login hash lives in the system repo.
#
# Rotate with:  nix run github:ryantm/agenix -- -e refl-dashboard-password.age
let
  admin  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAolzCtF1t8rPKSRzvREQPBUjxRAi5medog8Ebi0n/G hhefesto@rdataa.com";
  olimpo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5EUe2fiscGEdLFXkTfxPLRmHuRBwqCbHcFSabqVWN1 root@olimpo";
  xty    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5cWilmgGZa24PrEFftyajabwxHvR4jxvkIvqkyCtmG root@xty";

  users   = [ admin ];
  systems = [ olimpo xty ];
in
{
  # Password for /dashboard/ (user: refl). Read by systemd LoadCredential,
  # so it never reaches ExecStart or the process table.
  "refl-dashboard-password.age".publicKeys = users ++ systems;
}
