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
    packages.${system}.chapel = ((nix-chapel.packages.${system}.chapel.override {
      llvmPackages = pkgs.llvmPackages_19;
    }).overrideAttrs (old: {
      version = "2.3.0-git";
      src = pkgs.fetchFromGitHub {
        owner = "chapel-lang";
        repo = "chapel";
        rev = "180a2738f51843c0add14857ddc8789abb3fdeeb";
        hash = "sha256-MKfJYz/gYtTHnikgiUc5uyyFPNQ8psaLTNbWI/0PbfA=";
      };
    }));

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        pkg-config
        gmp
        hyperfine
        stdenv
        self.packages.${system}.chapel
        rocmPackages.clr
        # llvmPackages_18.clang
      ];

      # DEVICE_LIB_PATH = "${pkgs.rocmPackages_6.rocm-device-libs}";
      # HIP_CLANG_PATH = "${pkgs.llvmPackages_19.clang}/bin";
      # CHPL_ROCM_PATH = "${pkgs.rocmPackages_6.clr}";
      CHPL_LLVM = "system";
      CHPL_MEM = "jemalloc";
      CHPL_RE2 = "bundled";
      CHPL_TASKS = "qthreads";
      CHPL_GMP = "system";
      # CHPL_LOCALE_MODEL = "gpu";
      # CHPL_GPU = "amd";
      # CHPL_GPU_ARCH = "gfx1101";
      CHPL_RT_NUM_THREADS_PER_LOCALE = 16;
    };
  };
}
