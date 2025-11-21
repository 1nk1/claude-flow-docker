#!/usr/bin/env bash
# Agent Monitor - Minimal & Beautiful

REFRESH=0.5
CONTAINER="${CONTAINER_NAME:-claude-flow-alpha}"
BLINK=0

# Alternate screen + hide cursor
tput smcup 2>/dev/null
tput civis 2>/dev/null
trap 'tput cnorm 2>/dev/null; tput rmcup 2>/dev/null; exit' INT TERM EXIT

# Colors using tput for compatibility
RST=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim 2>/dev/null || echo "")

get_style() {
    local name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local status="$2"

    if [ "$status" = "done" ]; then
        tput setab 236 2>/dev/null || tput setab 0
    else
        case "$name" in
            *flutter*) tput setab 31 2>/dev/null || tput setab 4 ;;
            *aqa*)     tput setab 99 2>/dev/null || tput setab 5 ;;
            *qa*)      tput setab 34 2>/dev/null || tput setab 2 ;;
            *sdet*)    tput setab 208 2>/dev/null || tput setab 3 ;;
            *research*) tput setab 162 2>/dev/null || tput setab 5 ;;
            *code*)    tput setab 172 2>/dev/null || tput setab 3 ;;
            *data*)    tput setab 37 2>/dev/null || tput setab 6 ;;
            *)         tput setab 240 2>/dev/null || tput setab 0 ;;
        esac
    fi
}

get_icon() {
    local name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$name" in
        *flutter*) echo '📱' ;;
        *aqa*)     echo '🏗 ' ;;
        *qa*)      echo '📋' ;;
        *sdet*)    echo '🔧' ;;
        *research*) echo '🔍' ;;
        *code*)    echo '💻' ;;
        *data*)    echo '📊' ;;
        *)         echo '⚡' ;;
    esac
}

# Color codes
C_GRN=$(tput setaf 2)
C_YEL=$(tput setaf 3)
C_CYN=$(tput setaf 6)
C_WHT=$(tput setaf 7)
C_GRY=$(tput setaf 8 2>/dev/null || tput setaf 0)

while true; do
    BLINK=$((BLINK + 1))
    H=$(tput lines)
    W=$(tput cols)

    # Move to top
    tput cup 0 0

    # Top border
    printf "${C_GRY}"
    printf '━%.0s' $(seq 1 $W)
    printf "${RST}\n\n"

    # Get logs
    LOGS=$(docker exec "$CONTAINER" cat /workspace/logs/agents.log 2>/dev/null)
    IDS=$(echo "$LOGS" | grep -oE 'ID=[0-9]+' | cut -d= -f2 | sort -rn | uniq 2>/dev/null | head -8)

    ROW=3
    ACTIVE=0
    DONE_CNT=0

    for ID in $IDS; do
        [ "$ROW" -gt "$((H - 4))" ] && break

        START=$(echo "$LOGS" | grep "AGENT_START.*ID=$ID" | tail -1)
        [ -z "$START" ] && continue

        NAME=$(echo "$START" | sed 's/.*NAME=\([^|]*\).*/\1/' | tr -d ' ')
        [ "$NAME" = "ReasoningEngine" ] && continue
        [ "$NAME" = "HiveMindCoordinator" ] && continue

        # Check status
        if echo "$LOGS" | grep -q "AGENT_COMPLETE.*ID=$ID"; then
            STATUS="done"
            DONE_CNT=$((DONE_CNT + 1))
            STXT="${C_GRY}✓ done${RST}"
        else
            STATUS="active"
            ACTIVE=$((ACTIVE + 1))
            if [ $((BLINK % 2)) -eq 1 ]; then
                STXT="${C_GRN}${BOLD}● LIVE${RST}"
            else
                STXT="${C_YEL}${BOLD}◉ LIVE${RST}"
            fi
        fi

        BG=$(get_style "$NAME" "$STATUS")
        ICON=$(get_icon "$NAME")
        SHORTNAME=$(echo "$NAME" | cut -c1-16)

        # Agent header
        tput cup $((ROW - 1)) 0
        printf "${BG}${C_WHT}${BOLD} %s  %-16s" "$ICON" "$SHORTNAME"

        # Fill to end and add status
        FILL=$((W - 28))
        [ "$FILL" -gt 0 ] && printf '%*s' "$FILL" ""
        printf " %s ${BG} ${RST}\n" "$STXT"
        ROW=$((ROW + 1))

        # Actions
        ACTIONS=$(echo "$LOGS" | grep "AGENT_ACTION.*ID=$ID" | tail -3)
        LC=0

        while IFS= read -r L; do
            [ -z "$L" ] && continue
            [ "$LC" -ge 3 ] && break

            TS=$(echo "$L" | grep -oE 'T[0-9:]+' | head -1 | tr -d T | cut -c1-8)
            ACT=$(echo "$L" | sed 's/.*ACTION=\([^|]*\).*/\1/' | head -c 22 | xargs 2>/dev/null)
            DET=$(echo "$L" | sed 's/.*DETAILS=\([^|]*\).*/\1/' | head -c 50 | xargs 2>/dev/null)

            tput cup $((ROW - 1)) 0
            printf "  ${C_GRY}%s${RST} ${C_WHT}%-22s${RST} ${C_GRY}%s${RST}" "$TS" "$ACT" "$DET"
            tput el
            printf "\n"

            ROW=$((ROW + 1))
            LC=$((LC + 1))
        done <<< "$ACTIONS"

        # Fill empty lines
        while [ "$LC" -lt 3 ]; do
            tput cup $((ROW - 1)) 0
            printf "  ${C_GRY}·${RST}"
            tput el
            printf "\n"
            ROW=$((ROW + 1))
            LC=$((LC + 1))
        done

        # Spacer
        tput cup $((ROW - 1)) 0
        tput el
        printf "\n"
        ROW=$((ROW + 1))
    done

    # Clear rest
    while [ "$ROW" -lt "$((H - 1))" ]; do
        tput cup $((ROW - 1)) 0
        tput el
        ROW=$((ROW + 1))
    done

    # Bottom border
    tput cup $((H - 2)) 0
    printf "${C_GRY}"
    printf '━%.0s' $(seq 1 $W)
    printf "${RST}"

    # Status bar
    tput cup $((H - 1)) 0
    NOW=$(date +%H:%M:%S)
    if [ "$ACTIVE" -gt 0 ]; then
        printf " ${C_CYN}%s${RST} │ ${C_GRN}${BOLD}▲ %d active${RST} │ ${C_GRY}%d done${RST} │ q to exit" "$NOW" "$ACTIVE" "$DONE_CNT"
    else
        printf " ${C_CYN}%s${RST} │ ${C_GRY}○ 0 active${RST} │ ${C_GRY}%d done${RST} │ q to exit" "$NOW" "$DONE_CNT"
    fi
    tput el

    # Check quit
    read -rsn1 -t "$REFRESH" key 2>/dev/null && [ "$key" = "q" ] && break
done
