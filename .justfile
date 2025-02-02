import '.justfile.incl'

set dotenv-load := true
set dotenv-required := true
set shell := ['fish', '-c']

[doc('List all available commands')]
[group('nix')]
[private]
default:
    @just --list

[doc('Update the given flake inputs')]
[group('nix')]
update +inputs:
    for input in {{ inputs }}; nix flake update --flake . $input; end
