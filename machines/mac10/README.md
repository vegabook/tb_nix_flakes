DO THIS TO BOOTSTRAP NIX DARWIN
sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake "/Users/tbrowne/.config/tb_nix_flakes/machines/mac10#mac10"
