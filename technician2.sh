#!/usr/bin/env bash

ESC=$'\033'
R="${ESC}[0m"

cleanup() {
    printf "${ESC}[?25h${ESC}[?1049l${R}\n"
    stty echo 2>/dev/null
    exit 0
}
trap cleanup INT TERM EXIT

printf "${ESC}[?1049h${ESC}[?25l"
stty -echo 2>/dev/null

# ── Art lines ─────────────────────────────────────
LINES=(
"                                                         "
"                                                         "
"▄▄▄▄▄▄ ▄▄ ▄▄ ▄▄▄▄▄                                      "
"  ██   ██▄██ ██▄▄                                        "
"  ██   ██ ██ ██▄▄▄                                       "
"                                                         "
"                                                         "
"                                                         "
" ▄▄▄▄ ▄▄▄▄  ▄▄▄▄▄  ▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄▄  ▄▄▄▄ ▄▄▄▄▄▄        "
"██ ▄▄ ██▄█▄ ██▄▄  ██▀██  ██   ██▄▄  ███▄▄   ██          "
"▀███▀ ██ ██ ██▄▄▄ ██▀██  ██   ██▄▄▄ ▄▄██▀   ██          "
"                                                         "
"                                                         "
"                                                         "
"▄▄▄▄▄▄ ▄▄▄▄▄  ▄▄▄▄ ▄▄ ▄▄ ▄▄  ▄▄ ▄▄  ▄▄▄▄ ▄▄  ▄▄▄  ▄▄  ▄▄"
"  ██   ██▄▄  ██▀▀▀ ██▄██ ███▄██ ██ ██▀▀▀ ██ ██▀██ ███▄██"
"  ██   ██▄▄▄ ▀████ ██ ██ ██ ▀██ ██ ▀████ ██ ██▀██ ██ ▀██"
"                                                         "
"                                                         "
"                                                         "
"▄▄▄▄▄▄ ▄▄ ▄▄  ▄▄▄ ▄▄▄▄▄▄   ▄▄▄▄▄ ▄▄ ▄▄ ▄▄▄▄▄ ▄▄▄▄       "
"  ██   ██▄██ ██▀██  ██     ██▄▄  ██▄██ ██▄▄  ██▄█▄      "
"  ██   ██ ██ ██▀██  ██     ██▄▄▄  ▀█▀  ██▄▄▄ ██ ██      "
"                                                         "
"                                                         "
"                                                         "
"▄▄    ▄▄ ▄▄ ▄▄ ▄▄▄▄▄ ▄▄▄▄                               "
"██    ██ ██▄██ ██▄▄  ██▀██                               "
"██▄▄▄ ██  ▀█▀  ██▄▄▄ ████▀                               "
"                                                         "
)

NL=${#LINES[@]}
ROWS=$(tput lines)
COLS=$(tput cols)
SR=$(( (ROWS - NL) / 2 ))
(( SR < 1 )) && SR=1


# Convert hue (0-359) → ANSI true-color escape
hue_esc() {
    local h=$1
    local reg=$(( h / 60 ))
    local rem=$(( (h % 60) * 255 / 60 ))
    local q=$(( 255 - rem ))
    local r g b
    case $reg in
        0) r=255;  g=$rem;  b=0    ;;
        1) r=$q;   g=255;   b=0    ;;
        2) r=0;    g=255;   b=$rem ;;
        3) r=0;    g=$q;    b=255  ;;
        4) r=$rem; g=0;     b=255  ;;
        5) r=255;  g=0;     b=$q   ;;
        *) r=255;  g=255;   b=255  ;;
    esac
    printf "${ESC}[38;2;%d;%d;%dm" "$r" "$g" "$b"
}

# Render all lines with per-line hue (offset + i*step), brightness 0-255
render_rainbow() {
    local hoffset=$1 hstep=$2 bright=$3
    local buf=""
    for (( i=0; i<NL; i++ )); do
        local h=$(( (hoffset + i * hstep) % 360 ))
        local reg=$(( h / 60 ))
        local rem=$(( (h % 60) * 255 / 60 ))
        local q=$(( 255 - rem ))
        local r g b
        case $reg in
            0) r=255;  g=$rem;  b=0    ;;
            1) r=$q;   g=255;   b=0    ;;
            2) r=0;    g=255;   b=$rem ;;
            3) r=0;    g=$q;    b=255  ;;
            4) r=$rem; g=0;     b=255  ;;
            5) r=255;  g=0;     b=$q   ;;
            *) r=255;  g=255;   b=255  ;;
        esac
        r=$(( r * bright / 255 ))
        g=$(( g * bright / 255 ))
        b=$(( b * bright / 255 ))
        buf+="${ESC}[$((SR+i));1H${ESC}[38;2;${r};${g};${b}m${LINES[$i]}${R}"
    done
    printf "%s" "$buf"
}

# Render all lines with a solid RGB color
render_solid() {
    local cr=$1 cg=$2 cb=$3
    local buf=""
    for (( i=0; i<NL; i++ )); do
        buf+="${ESC}[$((SR+i));1H${ESC}[38;2;${cr};${cg};${cb}m${LINES[$i]}${R}"
    done
    printf "%s" "$buf"
}

# ── Phase 0: Black canvas ─────────────────────────
printf "${ESC}[2J"
for (( i=1; i<=ROWS; i++ )); do
    printf "${ESC}[%d;1H${ESC}[48;2;0;0;0m%*s${R}" "$i" "$COLS" ""
done
sleep 0.15

# ── Phase 1: Glitch noise in the art zone ─────────
GCHARS=('░' '▒' '▓' '█' '▄' '▀' '▌' '▐' '■')
for (( t=0; t<20; t++ )); do
    buf=""
    for (( n=0; n<40; n++ )); do
        rr=$(( SR + RANDOM % NL ))
        cc=$(( 2 + RANDOM % 55 ))
        ch=${GCHARS[$(( RANDOM % ${#GCHARS[@]} ))]}
        rv=$(( RANDOM % 60 ))
        gv=$(( 80 + RANDOM % 120 ))
        bv=$(( 150 + RANDOM % 105 ))
        buf+="${ESC}[${rr};${cc}H${ESC}[38;2;${rv};${gv};${bv}m${ch}${R}"
    done
    printf "%s" "$buf"
    sleep 0.04
done

# Clear art zone before reveal
for (( i=0; i<NL; i++ )); do
    printf "${ESC}[$((SR+i));1H%*s" "$COLS" ""
done
sleep 0.1

# ── Phase 2: Scanline reveal ──────────────────────
for (( i=0; i<NL; i++ )); do
    row=$(( SR + i ))
    # Hot-white scan line
    printf "${ESC}[${row};1H${ESC}[38;2;255;255;255m${LINES[$i]}${R}"
    sleep 0.005
    # Settle to electric cyan-blue
    printf "${ESC}[${row};1H${ESC}[38;2;0;180;255m${LINES[$i]}${R}"
    sleep 0.018
done
sleep 0.25

# ── Phase 3: Glitch flash ─────────────────────────
FLASH_COLORS=(
    "255;0;80"
    "255;255;255"
    "0;255;200"
    "255;80;0"
    "255;255;255"
    "150;0;255"
    "0;220;255"
    "255;255;255"
)
for (( gf=0; gf<8; gf++ )); do
    IFS=';' read -r fr fg fb <<< "${FLASH_COLORS[$gf]}"
    buf=""
    for (( i=0; i<NL; i++ )); do
        if (( RANDOM % 3 != 0 )); then
            buf+="${ESC}[$((SR+i));1H${ESC}[38;2;${fr};${fg};${fb}m${LINES[$i]}${R}"
        fi
    done
    printf "%s" "$buf"
    sleep 0.055
done
sleep 0.1

# ── Phase 4: Rainbow wave ─────────────────────────
HO=0
for (( frame=0; frame<140; frame++ )); do
    render_rainbow "$HO" 14 255
    HO=$(( (HO + 9) % 360 ))
    sleep 0.038
done

# ── Phase 5: Fade rainbow → gold ─────────────────
FADE_STEPS=35
for (( step=0; step<=FADE_STEPS; step++ )); do
    frac=$(( step * 255 / FADE_STEPS ))
    buf=""
    for (( i=0; i<NL; i++ )); do
        # Rainbow component
        local_h=$(( (HO + i * 14) % 360 ))
        reg=$(( local_h / 60 ))
        rem=$(( (local_h % 60) * 255 / 60 ))
        qv=$(( 255 - rem ))
        case $reg in
            0) rr=255;  rg=$rem;  rb=0   ;;
            1) rr=$qv;  rg=255;   rb=0   ;;
            2) rr=0;    rg=255;   rb=$rem;;
            3) rr=0;    rg=$qv;   rb=255 ;;
            4) rr=$rem; rg=0;     rb=255 ;;
            5) rr=255;  rg=0;     rb=$qv ;;
            *) rr=255;  rg=255;   rb=255 ;;
        esac
        # Gold target: 255, 185, 0 with slight row variation
        gr=255
        gg=$(( 185 - i * 2 ))
        (( gg < 80 )) && gg=80
        gb=0
        # Lerp rainbow → gold
        fr=$(( (gr * frac + rr * (255 - frac)) / 255 ))
        fg=$(( (gg * frac + rg * (255 - frac)) / 255 ))
        fb=$(( (gb * frac + rb * (255 - frac)) / 255 ))
        buf+="${ESC}[$((SR+i));1H${ESC}[38;2;${fr};${fg};${fb}m${LINES[$i]}${R}"
    done
    printf "%s" "$buf"
    HO=$(( (HO + 6) % 360 ))
    sleep 0.03
done

# ── Phase 6: Gold breathing pulse ────────────────
for (( pulse=0; pulse<4; pulse++ )); do
    # Brighten
    for (( lv=80; lv<=255; lv+=7 )); do
        cr=$lv
        cg=$(( lv * 180 / 255 ))
        cb=0
        render_solid "$cr" "$cg" "$cb"
        sleep 0.007
    done
    # Dim
    for (( lv=255; lv>=80; lv-=7 )); do
        cr=$lv
        cg=$(( lv * 180 / 255 ))
        cb=0
        render_solid "$cr" "$cg" "$cb"
        sleep 0.007
    done
done

# ── Phase 7: Slow rainbow shimmer finale ──────────
HO=0
for (( frame=0; frame<80; frame++ )); do
    render_rainbow "$HO" 18 220
    HO=$(( (HO + 5) % 360 ))
    sleep 0.05
done

# ── Phase 8: Hold bright gold, wait for key ───────
render_solid 255 210 0

EXIT_MSG="  ── press any key ──  "
em_row=$(( SR + NL + 1 ))
em_col=$(( (COLS - ${#EXIT_MSG}) / 2 ))
(( em_col < 1 )) && em_col=1
printf "${ESC}[${em_row};${em_col}H${ESC}[38;2;80;80;80m%s${R}" "$EXIT_MSG"

read -rsn1
cleanup
