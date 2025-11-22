#!/bin/bash
# Agent Monitor - htop-style non-blocking refresh

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
        *flutter*) printf '\033[48;5;31m' ;;
        *aqa*) printf '\033[48;5;99m' ;;
        *qa*) printf '\033[48;5;34m' ;;
        *sdet*) printf '\033[48;5;208m' ;;
        *research*) printf '\033[48;5;162m' ;;
        *code*) printf '\033[48;5;172m' ;;
        *) printf '\033[48;5;240m' ;;
    esac
}

get_icon() {
    case "$(echo "$1" | tr A-Z a-z)" in
        *flutter*) printf '📱' ;;
        *aqa*) printf '🏗' ;;
        *qa*) printf '📋' ;;
        *sdet*) printf '🔧' ;;
        *research*) printf '🔍' ;;
        *code*) printf '💻' ;;
        *) printf '⚡' ;;
    esac
}

get_status() {
    local a=$(echo "$1" | tr A-Z a-z)
    local d='●'
    [ $(($2 % 2)) -eq 0 ] && d='○'
    case "$a" in
        *analyz*|*review*|*check*) printf "${CYN}${d} ANALYZING${RST}" ;;
        *think*|*reason*) printf "${MAG}${d} THINKING${RST}" ;;
        *plan*|*design*) printf "${BLU}${d} PLANNING${RST}" ;;
        *cod*|*writ*|*implement*) printf "${GRN}${d} CODING${RST}" ;;
        *refactor*) printf "${YEL}${d} REFACTORING${RST}" ;;
        *test*) printf "${CYN}${d} TESTING${RST}" ;;
        *) printf "${GRN}${d} RUNNING${RST}" ;;
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

# Setup terminal - KEY: use timeout in stty, not in read
trap cleanup INT TERM EXIT
printf '\033[?1049h\033[?25l'

# Set terminal to raw mode with 100ms timeout (time=1 = 0.1 sec)
stty -echo -icanon min 0 time 1 2>/dev/null

# Main loop - runs continuously, read returns immediately if no input
while true; do
    # Non-blocking read - returns immediately due to stty time=1
    c1=""
    IFS= read -r -n1 c1

    if [[ "$c1" == $'\033' ]]; then
        IFS= read -r -n1 c2
        IFS= read -r -n1 c3
        c1="$c1$c2$c3"
    fi

    # Handle input
    case "$c1" in
        q|Q) break ;;
        $'\033[A'|k) [ $SEL -gt 0 ] && SEL=$((SEL - 1)) ;;
        $'\033[B'|j) SEL=$((SEL + 1)) ;;
        p|P) [ -n "${AIDS[$SEL]}" ] && docker exec "$CONTAINER" sh -c "echo 'AGENT_PAUSED | ID=${AIDS[$SEL]} | T$(date +%H:%M:%S)' >> /workspace/logs/agents.log" 2>/dev/null & ;;
        s|S) [ -n "${AIDS[$SEL]}" ] && docker exec "$CONTAINER" sh -c "echo 'AGENT_COMPLETE | ID=${AIDS[$SEL]} | T$(date +%H:%M:%S)' >> /workspace/logs/agents.log" 2>/dev/null & ;;
        r|R) [ -n "${AIDS[$SEL]}" ] && docker exec "$CONTAINER" sh -c "echo 'AGENT_RESUME | ID=${AIDS[$SEL]} | T$(date +%H:%M:%S)' >> /workspace/logs/agents.log" 2>/dev/null & ;;
    esac

    TICK=$((TICK + 1))

    # Update terminal size every 20 ticks
    if [ $((TICK % 20)) -eq 1 ]; then
        H=$(tput lines 2>/dev/null || echo 40)
        W=$(tput cols 2>/dev/null || echo 120)
    fi

    fetch

    IDS=$(echo "$LOGS" | grep -oE 'ID=[0-9]+' | cut -d= -f2 | sort -rn | uniq | head -6)

    # Build frame
    printf '\033[H'

    # Top border
    printf '\033[1;1H%s' "$GRY"
    for ((i=0; i<W; i++)); do printf '━'; done
    printf '%s' "$RST"

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

        # Status detection by line number
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
        printf '\033[%d;1H%s%s%s%s  %s' "$ROW" "$bg" "$fg" "$mark" "$icon" "$short"
        pad=$((W - 34))
        [ $pad -gt 0 ] && printf '%*s' "$pad" ''
        printf ' %s%s  %s' "$stxt" "$bg" "$RST"
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
            printf '\033[%d;1H' "$ROW"
            if [ $is_sel -eq 1 ]; then
                printf '%s  %s%s%s%s %s%s%s%s %s%s%s\033[K' "$SELBG" "$GRY" "$ts" "$RST" "$SELBG" "$SELFG" "$act" "$RST" "$SELBG" "$GRY" "$det" "$RST"
            else
                printf '  %s%s%s %s%s%s %s%s%s\033[K' "$GRY" "$ts" "$RST" "$WHT" "$act" "$RST" "$GRY" "$det" "$RST"
            fi
            ROW=$((ROW + 1))
            shown=$((shown + 1))
        done

        while [ $shown -lt 3 ]; do
            printf '\033[%d;1H' "$ROW"
            if [ $is_sel -eq 1 ]; then
                printf '%s  %s·%s\033[K' "$SELBG" "$GRY" "$RST"
            else
                printf '  %s·%s\033[K' "$GRY" "$RST"
            fi
            ROW=$((ROW + 1))
            shown=$((shown + 1))
        done

        printf '\033[%d;1H\033[K' "$ROW"
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
        printf '\033[%d;1H\033[K' "$ROW"
        ROW=$((ROW + 1))
    done

    # Help
    printf '\033[%d;1H%s  ↑↓/jk select │ p pause │ s stop │ r resume │ q quit%s\033[K' "$((H-2))" "$GRY" "$RST"

    # Bottom border
    printf '\033[%d;1H%s' "$((H-1))" "$GRY"
    for ((i=0; i<W; i++)); do printf '━'; done
    printf '%s' "$RST"

    # Status bar
    now=$(date +%H:%M:%S)
    if [ $ACT -gt 0 ]; then
        astat="${GRN}${BLD}▲ ${ACT} active${RST}"
    else
        astat="${GRY}○ 0 active${RST}"
    fi
    sel_info=""
    [ -n "${AIDS[$SEL]}" ] && sel_info=" │ ${CYN}#${AIDS[$SEL]}${RST}"
    printf '\033[%d;1H %s%s%s │ %s │ %s%d done%s%s\033[K' "$H" "$CYN" "$now" "$RST" "$astat" "$GRY" "$DNE" "$RST" "$sel_info"
done
