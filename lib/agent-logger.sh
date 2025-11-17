#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Agent Logger
# Real-time agent visualization with colors, names, specializations, and actions
# ═══════════════════════════════════════════════════════════════════════════

# Agent colors (8 distinct colors for up to 8 agents)
declare -A AGENT_COLORS=(
    [0]="\033[38;5;51m"   # Cyan
    [1]="\033[38;5;213m"  # Pink
    [2]="\033[38;5;226m"  # Yellow
    [3]="\033[38;5;119m"  # Green
    [4]="\033[38;5;207m"  # Purple
    [5]="\033[38;5;208m"  # Orange
    [6]="\033[38;5;117m"  # Light Blue
    [7]="\033[38;5;219m"  # Light Pink
)

# Agent specialization icons
declare -A AGENT_ICONS=(
    ["coordinator"]="🎯"
    ["researcher"]="🔍"
    ["coder"]="💻"
    ["reviewer"]="👀"
    ["tester"]="🧪"
    ["optimizer"]="⚡"
    ["designer"]="🎨"
    ["planner"]="📋"
    ["default"]="🤖"
)

# Colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
GRAY='\033[38;5;240m'
WHITE='\033[38;5;255m'
SUCCESS='\033[38;5;82m'
ERROR='\033[38;5;196m'
WARNING='\033[38;5;214m'

# Log file for agent activities
AGENT_LOG_FILE="${AGENT_LOG_FILE:-/workspace/logs/agents.log}"
mkdir -p "$(dirname "$AGENT_LOG_FILE")"

# Agent state storage
AGENT_STATE_DIR="/workspace/.swarm/agents"
mkdir -p "$AGENT_STATE_DIR"

# ═══════════════════════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════════════════════

get_agent_color() {
    local agent_id=$1
    local color_index=$((agent_id % 8))
    echo -e "${AGENT_COLORS[$color_index]}"
}

get_agent_icon() {
    local specialization=$1
    local icon="${AGENT_ICONS[$specialization]:-${AGENT_ICONS[default]}}"
    echo "$icon"
}

truncate_text() {
    local text=$1
    local max_length=${2:-50}
    if [ ${#text} -gt $max_length ]; then
        echo "${text:0:$max_length}..."
    else
        echo "$text"
    fi
}

get_timestamp() {
    date '+%H:%M:%S'
}

# ═══════════════════════════════════════════════════════════════════════════
# Agent Logging Functions
# ═══════════════════════════════════════════════════════════════════════════

log_agent_start() {
    local agent_id=$1
    local agent_name=$2
    local specialization=$3

    local color=$(get_agent_color "$agent_id")
    local icon=$(get_agent_icon "$specialization")
    local timestamp=$(get_timestamp)

    # Store agent state
    cat > "$AGENT_STATE_DIR/agent_${agent_id}.json" <<EOF
{
    "id": $agent_id,
    "name": "$agent_name",
    "specialization": "$specialization",
    "status": "active",
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "last_action": "Initializing..."
}
EOF

    # Log to file
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] AGENT_START | ID=$agent_id | NAME=$agent_name | SPEC=$specialization" >> "$AGENT_LOG_FILE"

    # Console output
    echo -e "${color}${BOLD}${icon} Agent #${agent_id}${RESET} ${color}${agent_name}${RESET} ${DIM}[${specialization}]${RESET}"
    echo -e "   ${GRAY}├─ Started at ${timestamp}${RESET}"
    echo -e "   ${GRAY}└─ Status: ${SUCCESS}ACTIVE${RESET}"
}

log_agent_action() {
    local agent_id=$1
    local action=$2
    local details=${3:-""}

    local color=$(get_agent_color "$agent_id")
    local timestamp=$(get_timestamp)

    # Read agent state
    local agent_file="$AGENT_STATE_DIR/agent_${agent_id}.json"
    if [ -f "$agent_file" ]; then
        local agent_name=$(jq -r '.name' "$agent_file" 2>/dev/null || echo "Agent-$agent_id")
        local icon=$(jq -r '.specialization' "$agent_file" 2>/dev/null | xargs -I{} bash -c "echo \$(get_agent_icon '{}')")

        # Update state
        jq --arg action "$action" --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '.last_action = $action | .last_update = $time' "$agent_file" > "${agent_file}.tmp" && \
           mv "${agent_file}.tmp" "$agent_file"
    else
        agent_name="Agent-$agent_id"
        icon="${AGENT_ICONS[default]}"
    fi

    # Truncate action for display
    local display_action=$(truncate_text "$action" 45)

    # Log to file
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] AGENT_ACTION | ID=$agent_id | ACTION=$action | DETAILS=$details" >> "$AGENT_LOG_FILE"

    # Console output (compact format for real-time viewing)
    if [ -n "$details" ]; then
        echo -e "${color}${icon} #${agent_id}${RESET} ${GRAY}${timestamp}${RESET} ${WHITE}${display_action}${RESET} ${DIM}│ ${details}${RESET}"
    else
        echo -e "${color}${icon} #${agent_id}${RESET} ${GRAY}${timestamp}${RESET} ${WHITE}${display_action}${RESET}"
    fi
}

log_agent_complete() {
    local agent_id=$1
    local result=${2:-"completed"}

    local color=$(get_agent_color "$agent_id")
    local timestamp=$(get_timestamp)

    # Read agent state
    local agent_file="$AGENT_STATE_DIR/agent_${agent_id}.json"
    if [ -f "$agent_file" ]; then
        local agent_name=$(jq -r '.name' "$agent_file" 2>/dev/null || echo "Agent-$agent_id")
        local icon=$(jq -r '.specialization' "$agent_file" 2>/dev/null | xargs -I{} bash -c "echo \$(get_agent_icon '{}')")

        # Update state
        jq --arg status "completed" --arg result "$result" --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '.status = $status | .result = $result | .completed_at = $time' "$agent_file" > "${agent_file}.tmp" && \
           mv "${agent_file}.tmp" "$agent_file"
    else
        agent_name="Agent-$agent_id"
        icon="${AGENT_ICONS[default]}"
    fi

    # Log to file
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] AGENT_COMPLETE | ID=$agent_id | RESULT=$result" >> "$AGENT_LOG_FILE"

    # Console output
    echo -e "${color}${BOLD}${icon} Agent #${agent_id}${RESET} ${color}${agent_name}${RESET}"
    echo -e "   ${GRAY}├─ Completed at ${timestamp}${RESET}"
    echo -e "   ${GRAY}└─ Result: ${SUCCESS}${result}${RESET}"
}

log_agent_error() {
    local agent_id=$1
    local error=$2

    local color=$(get_agent_color "$agent_id")
    local timestamp=$(get_timestamp)

    # Read agent state
    local agent_file="$AGENT_STATE_DIR/agent_${agent_id}.json"
    if [ -f "$agent_file" ]; then
        local agent_name=$(jq -r '.name' "$agent_file" 2>/dev/null || echo "Agent-$agent_id")

        # Update state
        jq --arg status "error" --arg error "$error" --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
           '.status = $status | .error = $error | .error_at = $time' "$agent_file" > "${agent_file}.tmp" && \
           mv "${agent_file}.tmp" "$agent_file"
    else
        agent_name="Agent-$agent_id"
    fi

    # Log to file
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] AGENT_ERROR | ID=$agent_id | ERROR=$error" >> "$AGENT_LOG_FILE"

    # Console output
    echo -e "${ERROR}✗${RESET} ${color}Agent #${agent_id}${RESET} ${GRAY}${timestamp}${RESET} ${ERROR}ERROR: ${error}${RESET}"
}

# ═══════════════════════════════════════════════════════════════════════════
# Agent Status Display
# ═══════════════════════════════════════════════════════════════════════════

show_active_agents() {
    echo -e "\n${BOLD}${WHITE}═══════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${WHITE}                  🤖 ACTIVE AGENTS STATUS${RESET}"
    echo -e "${BOLD}${WHITE}═══════════════════════════════════════════════════════════════${RESET}\n"

    local count=0
    for agent_file in "$AGENT_STATE_DIR"/agent_*.json; do
        if [ -f "$agent_file" ]; then
            local agent_id=$(jq -r '.id' "$agent_file")
            local agent_name=$(jq -r '.name' "$agent_file")
            local specialization=$(jq -r '.specialization' "$agent_file")
            local status=$(jq -r '.status' "$agent_file")
            local last_action=$(jq -r '.last_action' "$agent_file")

            local color=$(get_agent_color "$agent_id")
            local icon=$(get_agent_icon "$specialization")

            # Status color
            local status_color=""
            case $status in
                "active") status_color="$SUCCESS" ;;
                "error") status_color="$ERROR" ;;
                "completed") status_color="$GRAY" ;;
                *) status_color="$WHITE" ;;
            esac

            # Truncate action
            last_action=$(truncate_text "$last_action" 40)

            # Display agent
            echo -e "${color}${BOLD}${icon} Agent #${agent_id}${RESET} ${color}${agent_name}${RESET} ${DIM}[${specialization}]${RESET}"
            echo -e "   ${GRAY}├─ Status: ${status_color}${status^^}${RESET}"
            echo -e "   ${GRAY}└─ ${last_action}${RESET}"
            echo ""

            count=$((count + 1))
            if [ $count -ge 8 ]; then
                break
            fi
        fi
    done

    if [ $count -eq 0 ]; then
        echo -e "${DIM}No active agents${RESET}\n"
    fi

    echo -e "${BOLD}${WHITE}═══════════════════════════════════════════════════════════════${RESET}\n"
}

# ═══════════════════════════════════════════════════════════════════════════
# Export functions
# ═══════════════════════════════════════════════════════════════════════════

export -f log_agent_start
export -f log_agent_action
export -f log_agent_complete
export -f log_agent_error
export -f show_active_agents
export -f get_agent_color
export -f get_agent_icon
