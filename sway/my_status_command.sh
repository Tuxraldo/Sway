#!/bin/sh

# This i3status wrapper allows to add custom information in any position of the statusline
# It was developed for i3bar (JSON format)

# The idea is to define "holder" modules in i3status config and then replace them

# In order to make this example work you need to add
# order += "tztime holder__hey_man"
# and
# tztime holder__hey_man {
#        format = "holder__hey_man"
# }
# in i3staus config

# Don't forget that i3status config should contain:
# general {
#   output_format = i3bar
# }
#
# and i3 config should contain:
# bar {
#   status_command exec /path/to/this/script.sh
# }

# Make sure jq is installed
# That's it

# You can easily add multiple custom modules using additional "holders"

function update_holder {

  local instance="$1"
  local replacement="$2"
  echo "$json_array" | jq --argjson arg_j "$replacement" "(.[] | (select(.instance==\"$instance\"))) |= \$arg_j"
}

function remove_holder {

  local instance="$1"
  echo "$json_array" | jq "del(.[] | (select(.instance==\"$instance\")))"
}

function keys {

  local keys=$(cat /sys/class/leds/input15\:\:capslock/brightness)

  if [ "$keys" == 1 ]; then
   local json='{ "full_text": " 󰌎 CAPS LOCK ", "color": "#E68183", "background": "#E68183" }'
    json_array=$(update_holder holder__keys "$json")
  else
    json_array=$(remove_holder holder__keys)
  fi
}
function sway_layout {

  local layout=$(swaymsg -t get_tree | jq --raw-output 'recurse(.nodes[]; .nodes !=null) | select(.nodes[].focused).layout')
  if [ "$layout" == splith ]; then
    local json='{ "full_text": "[horizontal]", "color": "#D699B6" }'
    json_array=$(update_holder holder__sway_layout "$json")
  elif [ "$layout" == splitv ]; then
    local json='{ "full_text": "[vertical]", "color": "#E68183" }'
    json_array=$(update_holder holder__sway_layout "$json")
  elif [ "$layout" == tabbed ]; then
    local json='{ "full_text": "[tabbed]", "color": "#7FBBB3" }'
    json_array=$(update_holder holder__sway_layout "$json")
  elif [ "$layout" == stacked ]; then
    local json='{ "full_text": "[stacked]", "color": "#DBBC7F" }'
    json_array=$(update_holder holder__sway_layout "$json")
  else
    json_array=$(remove_holder holder__sway_layout)
  fi
}

function scratchpad {
  local count=$(swaymsg -r -t get_tree |
    jq -r 'recurse(.nodes[]) | 
      first(select(.name=="__i3_scratch")) | 
      .floating_nodes | length')
  
  if [[ "$count" -ge 1 ]]; then
    local json='{ "full_text": "   '$count' ", "color": "#DBBC7F" }'
    json_array=$(update_holder holder__scratchpad "$json")
  else
    json_array=$(remove_holder holder__scratchpad)
  fi
}

function cmus {
  local artist=$(cmus-remote -C status | grep "tag artist" | cut -c 12-)
    song=$(cmus-remote -C status | grep title | cut -c 11-)
  if [[ "$artist" ]]; then
    local json='{ "full_text": "'$artist'   '$song'", "color": "#A7C080" }'
    json_array=$(update_holder holder__cmus "$json")
    else
    json_array=$(remove_holder holder__cmus)
fi
}

i3status | (read line; echo "$line"; read line ; echo "$line" ; read line ; echo "$line" ; while true
do
  read line
  json_array="$(echo $line | sed -e 's/^,//')"
  cmus
  scratchpad
  sway_layout
  keys
  echo ",$json_array"
done)
