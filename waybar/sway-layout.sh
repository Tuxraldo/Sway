#!/usr/bin/env bash

# Show sway layout on waybar

case $(swaymsg -t get_tree | jq --raw-output 'recurse(.nodes[]; .nodes !=null) | select(.nodes[].focused).layout') in
#  splith) echo "[horizontal]" ;;
#  splitv) echo "[vertical]" ;;
#  tabbed) echo "[tabbed]" ;;
#  stacked) echo "[stacking]" ;;
  splith) echo "[H]" ;;
  splitv) echo "[V]" ;;
  tabbed) echo "[T]" ;;
  stacked) echo "[S]" ;;
esac
