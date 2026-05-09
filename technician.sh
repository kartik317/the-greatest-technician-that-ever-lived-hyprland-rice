#!/bin/bash

# Hide cursor
tput civis
clear

# Define the ASCII Art
read -r -d '' ART << 'EOF'
▄▄▄▄▄▄ ▄▄ ▄▄ ▄▄▄▄▄                                       
  ██   ██▄██ ██▄▄                                        
  ██   ██ ██ ██▄▄▄                                       
                                                         
                                                         
                                                         
 ▄▄▄▄ ▄▄▄▄  ▄▄▄▄▄  ▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄▄  ▄▄▄▄ ▄▄▄▄▄▄         
██ ▄▄ ██▄█▄ ██▄▄  ██▀██  ██   ██▄▄  ███▄▄   ██           
▀███▀ ██ ██ ██▄▄▄ ██▀██  ██   ██▄▄▄ ▄▄██▀   ██           
                                                         
                                                         
                                                         
▄▄▄▄▄▄ ▄▄▄▄▄  ▄▄▄▄ ▄▄ ▄▄ ▄▄  ▄▄ ▄▄  ▄▄▄▄ ▄▄  ▄▄▄  ▄▄  ▄▄ 
  ██   ██▄▄  ██▀▀▀ ██▄██ ███▄██ ██ ██▀▀▀ ██ ██▀██ ███▄██ 
  ██   ██▄▄▄ ▀████ ██ ██ ██ ▀██ ██ ▀████ ██ ██▀██ ██ ▀██ 
                                                         
                                                         
                                                         
▄▄▄▄▄▄ ▄▄ ▄▄  ▄▄▄ ▄▄▄▄▄▄   ▄▄▄▄▄ ▄▄ ▄▄ ▄▄▄▄▄ ▄▄▄▄        
  ██   ██▄██ ██▀██  ██     ██▄▄  ██▄██ ██▄▄  ██▄█▄       
  ██   ██ ██ ██▀██  ██     ██▄▄▄  ▀█▀  ██▄▄▄ ██ ██       
                                                         
                                                         
                                                         
▄▄    ▄▄ ▄▄ ▄▄ ▄▄▄▄▄ ▄▄▄▄                                
██    ██ ██▄██ ██▄▄  ██▀██                               
██▄▄▄ ██  ▀█▀  ██▄▄▄ ████▀                               
EOF

# Colors
CYAN='\033[0;36m'
BRIGHT='\033[1;37m'
NC='\033[0m' # No Color

# Get terminal dimensions
TERM_WIDTH=$(tput cols)
TERM_HEIGHT=$(tput lines)

# Calculate centering
ART_WIDTH=57
ART_HEIGHT=27
START_COL=$(( (TERM_WIDTH - ART_WIDTH) / 2 ))
START_ROW=$(( (TERM_HEIGHT - ART_HEIGHT) / 2 ))

# Animation logic
row=$START_ROW
echo -e "$CYAN"
while IFS= read -r line; do
    tput cup $row $START_COL
    # Typewriter effect for each line
    for (( i=0; i<${#line}; i++ )); do
        char="${line:$i:1}"
        # Make the "██" parts flash bright white briefly
        if [[ "$char" == "█" || "$char" == "▄" ]]; then
            echo -ne "${BRIGHT}${char}${CYAN}"
        else
            echo -ne "$char"
        fi
        sleep 0.002
    done
    ((row++))
    sleep 0.02
done <<< "$ART"

# Final flourish: Pulse effect
for i in {1..2}; do
    tput cup $START_ROW $START_COL
    echo -e "$BRIGHT"
    echo "$ART" | sed "s/^/$(tput hpa $START_COL)/"
    sleep 0.1
    tput cup $START_ROW $START_COL
    echo -e "$CYAN"
    echo "$ART" | sed "s/^/$(tput hpa $START_COL)/"
    sleep 0.1
done

# Show cursor and reset color
tput cnorm
echo -e "$NC"
