# This file defines two Nix shells, one with a RISC-V 32-bit toolchain, the
# other is 64-bit. The approach is outlined at
# https://nixos.wiki/wiki/Cross_Compiling.
#
# Usage:
#
#   nix-shell --attr riscv32
#
# then use `riscv32-none-elf-gcc` as compiler, or
#
#   nix-shell --attr riscv64
#
# then use `riscv64-unknown-linux-gnu-gcc` as compiler.

{ pkgs ? import <nixpkgs> {} }:

let
  riscv32-pkgs = import <nixpkgs> {
    crossSystem = (import <nixpkgs/lib>).systems.examples.riscv32-embedded;
  };

  riscv64-pkgs = import <nixpkgs> {
    crossSystem = (import <nixpkgs/lib>).systems.examples.riscv64;
  };

in
{
  riscv32 = riscv32-pkgs.mkShell {
    buildInputs = [
    ];
  };

  riscv64 = riscv64-pkgs.mkShell {
    buildInputs = [
    ];
    nativeBuildInputs = [
      # Uncomment to also bring QEMU, if you don't have it system-wide.
      # riscv64-pkgs.buildPackages.buildPackages.qemu
      riscv64-pkgs.buildPackages.gdb
    ];
  };
}
