{ pkgs, lib, config, ... }:

{
  home.file.".config/ghostty/shaders/cursor.glsl".source = ./cursor.glsl;
}
