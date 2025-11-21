#!/usr/bin/env bash
# LIVE AGENT DASHBOARD - Smooth in-place updates

REFRESH=0.5
CONTAINER="claude-flow-alpha"

# Alternate screen buffer + hide cursor
printf '\e[?1049h\e[?25l'
trap 'printf "\e[?1049l\e[?25h"; exit' INT TERM

# Colors
RST='\e[0m' BOLD='\e[1m'
FW='\e[97m' FG='\e[37m' FD='\e[90m' FC='\e[96m'

BG_FLUTTER='\e[48;5;24m'
BG_AQA='\e[48;5;54m'
BG_QA='\e[48;5;22m'
BG_SDET='\e[48;5;130m'
BG_RESEARCH='\e[48;5;125m'
BG_CODE='\e[48;5;136m'
BG_DATA='\e[48;5;30m'
BG_DONE='\e[48;5;238m'
BG_DEFAULT='\e[48;5;236m'

get_style() {
    local name="$1" status="$2"
    [[ $status == DONE ]] && { printf '%s' "${BG_DONE}${FD}"; return; }
    case $name in
        *flutter*) printf '%s' "${BG_FLUTTER}${FW}${BOLD}";;
        *aqa-*) printf '%s' "${BG_AQA}${FW}${BOLD}";;
        *qa-*) printf '%s' "${BG_QA}${FW}${BOLD}";;
        *sdet*) printf '%s' "${BG_SDET}${FW}${BOLD}";;
        *Research*) printf '%s' "${BG_RESEARCH}${FW}${BOLD}";;
        *Code*) printf '%s' "${BG_CODE}${FW}${BOLD}";;
        *Data*) printf '%s' "${BG_DATA}${FW}${BOLD}";;
        *) printf '%s' "${BG_DEFAULT}${FW}";;
    esac
}

get_icon() {
    case $1 in
        *flutter*) printf '📱';; *aqa-*) printf '🏗';; *qa-*) printf '📋';;
        *sdet*) printf '🔧';; *Research*) printf '🔍';; *Code*) printf '💻';;
        *Data*) printf '📊';; *) printf '⚡';;
    esac
}

while true; do
    H=$(tput lines) W=$(tput cols)
    OUT=""

    # Header
    LINE=$(printf '═%.0s' $(seq 1 $W))
    OUT+="\e[1;1H${FC}${BOLD}${LINE}${RST}"
    OUT+="\e[2;1H${FC}${BOLD}$(printf '%*s' $(((W+22)/2)) '🤖 LIVE AGENT DASHBOARD')${RST}"
    OUT+="\e[3;1H${FC}${BOLD}${LINE}${RST}"

    LOGS=$(docker exec $CONTAINER cat /workspace/logs/agents.log 2>/dev/null)
    IDS=$(echo "$LOGS" | grep -oE 'ID=[0-9]+' | cut -d= -f2 | sort -rn | uniq | head -6)

    ROW=5 ACTIVE=0 DONE_CNT=0

    for ID in $IDS; do
        ((ROW > H-4)) && break
        START=$(echo "$LOGS" | grep "AGENT_START.*ID=$ID" | tail -1)
        [[ -z $START ]] && continue
        NAME=$(echo "$START" | sed 's/.*NAME=\([^|]*\).*/\1/' | tr -d ' ')
        [[ $NAME == ReasoningEngine || $NAME == HiveMindCoordinator ]] && continue

        if echo "$LOGS" | grep -q "AGENT_COMPLETE.*ID=$ID"; then
            STATUS=DONE; ((DONE_CNT++)); STXT="✓ DONE   "
        else
            STATUS=ACTIVE; ((ACTIVE++)); STXT="● RUNNING"
        fi

        S=$(get_style "$NAME" "$STATUS")
        I=$(get_icon "$NAME")
        HDR=$(printf ' %s #%-3s %-18s %s' "$I" "$ID" "${NAME:0:18}" "$STXT")
        OUT+="\e[${ROW};1H${S}${HDR}$(printf '%*s' $((W-${#HDR}-1)) '')${RST}"
        ((ROW++))

        ACTIONS=$(echo "$LOGS" | grep "AGENT_ACTION.*ID=$ID" | tail -4)
        LC=0
        while IFS= read -r L && ((LC<4)); do
            [[ -z $L ]] && continue
            TS=$(echo "$L" | grep -oE 'T[0-9:]+' | head -1 | tr -d T | cut -c1-8)
            ACT=$(echo "$L" | sed 's/.*ACTION=\([^|]*\).*/\1/' | xargs | cut -c1-26)
            DET=$(echo "$L" | sed 's/.*DETAILS=\([^|]*\).*/\1/' | xargs | cut -c1-$((W-45)))
            OUT+="\e[${ROW};1H  ${FD}${TS}${RST} ${FW}$(printf '%-26s' "$ACT")${RST} ${FG}${DET}$(printf '%*s' $((W-45-${#DET})) '')${RST}"
            ((ROW++)); ((LC++))
        done <<< "$ACTIONS"
        while ((LC<4)); do OUT+="\e[${ROW};1H  ${FD}...$(printf '%*s' $((W-5)) '')${RST}"; ((ROW++)); ((LC++)); done
        OUT+="\e[${ROW};1H$(printf '%*s' $W '')"; ((ROW++))
    done

    while ((ROW < H-2)); do OUT+="\e[${ROW};1H$(printf '%*s' $W '')"; ((ROW++)); done

    FLINE=$(printf '─%.0s' $(seq 1 $W))
    OUT+="\e[$((H-1));1H${FD}${FLINE}${RST}"
    OUT+="\e[${H};1H${FC}${BOLD}⚡ $(date +%H:%M:%S)${RST} │ ${FW}Active: $ACTIVE${RST} │ ${FG}Done: $DONE_CNT${RST} │ ${FD}Ctrl+C$(printf '%*s' $((W-50)) '')${RST}"

    printf '%b' "$OUT"
    sleep $REFRESH
done
