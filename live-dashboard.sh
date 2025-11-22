#!/bin/bash
# Agent Monitor

CONTAINER="${CONTAINER_NAME:-claude-flow-alpha}"
SEL=0
TICK=0
H=40
W=120

# Colors
RST=$'\033[0m'
BLD=$'\033[1m'
SELBG=$'\033[48;5;23m'
SELFG=$'\033[38;5;87m'
WHT=$'\033[97m'
GRY=$'\033[90m'
CYN=$'\033[96m'
GRN=$'\033[92m'
YEL=$'\033[93m'
BLU=$'\033[94m'
MAG=$'\033[95m'

get_bg() {
    case "$(echo "$1" | tr A-Z a-z)" in
        *flutter*) echo $'\033[48;5;31m' ;;
        *aqa*) echo $'\033[48;5;99m' ;;
        *qa*) echo $'\033[48;5;34m' ;;
        *sdet*) echo $'\033[48;5;208m' ;;
        *research*) echo $'\033[48;5;162m' ;;
        *code*) echo $'\033[48;5;172m' ;;
        *) echo $'\033[48;5;240m' ;;
    esac
}

get_icon() {
    case "$(echo "$1" | tr A-Z a-z)" in
        *flutter*) echo '📱' ;;
        *aqa*) echo '🏗' ;;
        *qa*) echo '📋' ;;
        *sdet*) echo '🔧' ;;
        *research*) echo '🔍' ;;
        *code*) echo '💻' ;;
        *) echo '⚡' ;;
    esac
}

get_status() {
    local a=$(echo "$1" | tr A-Z a-z)
    local d='●'
    [ $(($2 % 2)) -eq 0 ] && d='○'
    case "$a" in
        *analyz*|*review*|*check*) echo "${CYN}${d} ANALYZING${RST}" ;;
        *think*|*reason*) echo "${MAG}${d} THINKING${RST}" ;;
        *plan*|*design*) echo "${BLU}${d} PLANNING${RST}" ;;
        *cod*|*writ*|*implement*) echo "${GRN}${d} CODING${RST}" ;;
        *refactor*) echo "${YEL}${d} REFACTORING${RST}" ;;
        *test*) echo "${CYN}${d} TESTING${RST}" ;;
        *) echo "${GRN}${d} RUNNING${RST}" ;;
    esac
}

LOGS=""
FETCH_T=0

fetch() {
    local now=$(date +%s)
    if [ $((now - FETCH_T)) -ge 1 ]; then
        LOGS=$(docker exec "$CONTAINER" cat /workspace/logs/agents.log 2>/dev/null)
        FETCH_T=$now
    fi
}

cleanup() {
    printf '\033[?25h\033[?1049l'
    stty sane 2>/dev/null
    exit 0
}

# Setup
trap cleanup INT TERM EXIT
printf '\033[?1049h\033[?25l'
stty -echo -icanon time 0 min 0 2>/dev/null

# Main loop
while true; do
    # Try to read a key (non-blocking)
    c1=""
    c2=""
    c3=""
    read -rsn1 c1 2>/dev/null

    if [[ "$c1" == $'\033' ]]; then
        read -rsn1 c2 2>/dev/null
        read -rsn1 c3 2>/dev/null
    fi

    # Handle input
    case "$c1$c2$c3" in
        q|Q) break ;;
        $'\033[A'|k) [ $SEL -gt 0 ] && SEL=$((SEL - 1)) ;;
        $'\033[B'|j) SEL=$((SEL + 1)) ;;
        p|P) [ -n "${AIDS[$SEL]}" ] && docker exec "$CONTAINER" sh -c "echo 'AGENT_PAUSED | ID=${AIDS[$SEL]} | T$(date +%H:%M:%S)' >> /workspace/logs/agents.log" 2>/dev/null & ;;
        s|S) [ -n "${AIDS[$SEL]}" ] && docker exec "$CONTAINER" sh -c "echo 'AGENT_COMPLETE | ID=${AIDS[$SEL]} | T$(date +%H:%M:%S)' >> /workspace/logs/agents.log" 2>/dev/null & ;;
        r|R) [ -n "${AIDS[$SEL]}" ] && docker exec "$CONTAINER" sh -c "echo 'AGENT_RESUME | ID=${AIDS[$SEL]} | T$(date +%H:%M:%S)' >> /workspace/logs/agents.log" 2>/dev/null & ;;
    esac

    TICK=$((TICK + 1))

    # Update terminal size periodically
    if [ $((TICK % 20)) -eq 1 ]; then
        H=$(tput lines 2>/dev/null || echo 40)
        W=$(tput cols 2>/dev/null || echo 120)
    fi

    fetch

    IDS=$(echo "$LOGS" | grep -oE 'ID=[0-9]+' | cut -d= -f2 | sort -rn | uniq | head -6)

    # Build output buffer
    OUT="\033[H"

    # Top border
    OUT+="\033[1;1H${GRY}"
    for ((i=0; i<W; i++)); do OUT+="━"; done
    OUT+="${RST}"

    AIDS=()
    ROW=3
    ACT=0
    DNE=0
    IDX=0

    for ID in $IDS; do
        [ $ROW -gt $((H - 5)) ] && break

        start=$(echo "$LOGS" | grep "AGENT_START.*ID=$ID" | tail -1)
        [ -z "$start" ] && continue

        name=$(echo "$start" | sed 's/.*NAME=\([^|]*\).*/\1/' | tr -d ' ')
        [ "$name" = "ReasoningEngine" ] && continue
        [ "$name" = "HiveMindCoordinator" ] && continue

        AIDS+=("$ID")
        icon=$(get_icon "$name")
        short="${name:0:16}"

        is_sel=0
        [ $IDX -eq $SEL ] && is_sel=1

        # Get last status event for this agent
        last_pause=$(echo "$LOGS" | grep -n "AGENT_PAUSED.*ID=$ID" | tail -1 | cut -d: -f1)
        last_resume=$(echo "$LOGS" | grep -n "AGENT_RESUME.*ID=$ID" | tail -1 | cut -d: -f1)
        last_complete=$(echo "$LOGS" | grep -n "AGENT_COMPLETE.*ID=$ID" | tail -1 | cut -d: -f1)

        [ -z "$last_pause" ] && last_pause=0
        [ -z "$last_resume" ] && last_resume=0
        [ -z "$last_complete" ] && last_complete=0

        if [ "$last_complete" -gt "$last_pause" ] && [ "$last_complete" -gt "$last_resume" ]; then
            DNE=$((DNE + 1))
            stxt="${GRY}✓ DONE${RST}"
            bg=$'\033[48;5;236m'
        elif [ "$last_pause" -gt "$last_resume" ] && [ "$last_pause" -gt "$last_complete" ]; then
            ACT=$((ACT + 1))
            stxt="${YEL}⏸ PAUSED${RST}"
            bg=$(get_bg "$name")
        else
            ACT=$((ACT + 1))
            last=$(echo "$LOGS" | grep "AGENT_ACTION.*ID=$ID" | tail -1 | sed 's/.*ACTION=\([^|]*\).*/\1/')
            stxt=$(get_status "$last" "$TICK")
            bg=$(get_bg "$name")
        fi

        mark=' '
        fg="${WHT}${BLD}"
        if [ $is_sel -eq 1 ]; then
            mark='▶'
            bg="$SELBG"
            fg="${SELFG}${BLD}"
        fi

        # Agent row
        OUT+="\033[${ROW};1H${bg}${fg}${mark}${icon}  ${short}"
        pad=$((W - 34))
        [ $pad -gt 0 ] && printf -v sp '%*s' "$pad" '' && OUT+="$sp"
        OUT+=" ${stxt}${bg}  ${RST}"
        ROW=$((ROW + 1))

        # Action lines
        act1=$(echo "$LOGS" | grep "AGENT_ACTION.*ID=$ID" | tail -3 | head -1)
        act2=$(echo "$LOGS" | grep "AGENT_ACTION.*ID=$ID" | tail -2 | head -1)
        act3=$(echo "$LOGS" | grep "AGENT_ACTION.*ID=$ID" | tail -1)
        shown=0

        for L in "$act1" "$act2" "$act3"; do
            [ -z "$L" ] && continue
            ts=$(echo "$L" | grep -oE 'T[0-9:]+' | head -1 | tr -d T | cut -c1-8)
            act=$(echo "$L" | sed 's/.*ACTION=\([^|]*\).*/\1/' | cut -c1-20)
            det=$(echo "$L" | sed 's/.*DETAILS=\([^|]*\).*/\1/' | cut -c1-$((W-38)))
            if [ $is_sel -eq 1 ]; then
                OUT+="\033[${ROW};1H${SELBG}  ${GRY}${ts}${RST}${SELBG} ${SELFG}${act}${RST}${SELBG} ${GRY}${det}${RST}\033[K"
            else
                OUT+="\033[${ROW};1H  ${GRY}${ts}${RST} ${WHT}${act}${RST} ${GRY}${det}${RST}\033[K"
            fi
            ROW=$((ROW + 1))
            shown=$((shown + 1))
        done

        while [ $shown -lt 3 ]; do
            if [ $is_sel -eq 1 ]; then
                OUT+="\033[${ROW};1H${SELBG}  ${GRY}·${RST}\033[K"
            else
                OUT+="\033[${ROW};1H  ${GRY}·${RST}\033[K"
            fi
            ROW=$((ROW + 1))
            shown=$((shown + 1))
        done

        OUT+="\033[${ROW};1H\033[K"
        ROW=$((ROW + 1))
        IDX=$((IDX + 1))
    done

    # Clamp selection
    max=${#AIDS[@]}
    [ $max -gt 0 ] && max=$((max - 1))
    [ $SEL -gt $max ] && SEL=$max
    [ $SEL -lt 0 ] && SEL=0

    # Clear remaining
    while [ $ROW -lt $((H - 2)) ]; do
        OUT+="\033[${ROW};1H\033[K"
        ROW=$((ROW + 1))
    done

    # Help
    OUT+="\033[$((H-2));1H${GRY}  ↑↓/jk select │ p pause │ s stop │ r resume │ q quit${RST}\033[K"

    # Bottom border
    OUT+="\033[$((H-1));1H${GRY}"
    for ((i=0; i<W; i++)); do OUT+="━"; done
    OUT+="${RST}"

    # Status
    now=$(date +%H:%M:%S)
    if [ $ACT -gt 0 ]; then
        astat="${GRN}${BLD}▲ ${ACT} active${RST}"
    else
        astat="${GRY}○ 0 active${RST}"
    fi
    sel_info=""
    [ -n "${AIDS[$SEL]}" ] && sel_info=" │ ${CYN}#${AIDS[$SEL]}${RST}"
    OUT+="\033[${H};1H ${CYN}${now}${RST} │ ${astat} │ ${GRY}${DNE} done${RST}${sel_info} │ ${GRY}sel:${SEL}/${#AIDS[@]}${RST}\033[K"

    printf '%b' "$OUT"

    # Small delay to prevent CPU spin
    sleep 0.05
done
