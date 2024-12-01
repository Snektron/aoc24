{
  description = "AOC 24 flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nix-chapel.url = "github:twesterhout/nix-chapel";
    nix-chapel.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-chapel }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        pkg-config
        gmp
        nix-chapel.packages.${system}.chapel
      ];
    };
  };
}
