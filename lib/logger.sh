#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Docker - Advanced Logging System
# ═══════════════════════════════════════════════════════════════════════════

# ANSI Colors
declare -A COLORS=(
    [RESET]='\033[0m'
    [BOLD]='\033[1m'
    [DIM]='\033[2m'
    [ITALIC]='\033[3m'
    [UNDERLINE]='\033[4m'

    # Foreground
    [BLACK]='\033[0;30m'
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[0;33m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [CYAN]='\033[0;36m'
    [WHITE]='\033[0;37m'

    # Bright foreground
    [BRIGHT_BLACK]='\033[0;90m'
    [BRIGHT_RED]='\033[0;91m'
    [BRIGHT_GREEN]='\033[0;92m'
    [BRIGHT_YELLOW]='\033[0;93m'
    [BRIGHT_BLUE]='\033[0;94m'
    [BRIGHT_PURPLE]='\033[0;95m'
    [BRIGHT_CYAN]='\033[0;96m'
    [BRIGHT_WHITE]='\033[0;97m'

    # Background
    [BG_BLACK]='\033[40m'
    [BG_RED]='\033[41m'
    [BG_GREEN]='\033[42m'
    [BG_YELLOW]='\033[43m'
    [BG_BLUE]='\033[44m'
    [BG_PURPLE]='\033[45m'
    [BG_CYAN]='\033[46m'
    [BG_WHITE]='\033[47m'
)

# Log levels
declare -A LOG_LEVELS=(
    [TRACE]=0
    [DEBUG]=1
    [INFO]=2
    [SUCCESS]=3
    [WARN]=4
    [ERROR]=5
    [FATAL]=6
)

# Default log level
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-/workspace/logs/claude-flow.log}"
LOG_DIR="$(dirname "$LOG_FILE")"
LOG_TO_FILE="${LOG_TO_FILE:-true}"
LOG_TIMESTAMP_FORMAT="${LOG_TIMESTAMP_FORMAT:-%Y-%m-%d %H:%M:%S}"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR" 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════════════════════

# Get timestamp
timestamp() {
    date +"$LOG_TIMESTAMP_FORMAT"
}

# Check if message should be logged based on level
should_log() {
    local level="$1"
    local current_level_value="${LOG_LEVELS[$LOG_LEVEL]:-2}"
    local message_level_value="${LOG_LEVELS[$level]:-2}"

    [[ $message_level_value -ge $current_level_value ]]
}

# Write to log file
log_to_file() {
    local level="$1"
    local message="$2"
    local context="$3"

    if [[ "$LOG_TO_FILE" == "true" ]]; then
        local timestamp=$(timestamp)
        local log_entry="[$timestamp] [$level]"

        if [[ -n "$context" ]]; then
            log_entry="$log_entry [$context]"
        fi

        log_entry="$log_entry $message"

        echo "$log_entry" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# Core Logging Functions
# ═══════════════════════════════════════════════════════════════════════════

log_trace() {
    local message="$1"
    local context="${2:-}"

    if should_log "TRACE"; then
        local prefix="${COLORS[DIM]}${COLORS[WHITE]}[TRACE]${COLORS[RESET]}"
        echo -e "$prefix ${COLORS[DIM]}$message${COLORS[RESET]}" >&2
        log_to_file "TRACE" "$message" "$context"
    fi
}

log_debug() {
    local message="$1"
    local context="${2:-}"

    if should_log "DEBUG"; then
        local prefix="${COLORS[BRIGHT_BLACK]}[DEBUG]${COLORS[RESET]}"
        echo -e "$prefix ${COLORS[BRIGHT_BLACK]}$message${COLORS[RESET]}" >&2
        log_to_file "DEBUG" "$message" "$context"
    fi
}

log_info() {
    local message="$1"
    local context="${2:-}"

    if should_log "INFO"; then
        local prefix="${COLORS[BLUE]} [INFO]${COLORS[RESET]}"
        echo -e "$prefix $message"
        log_to_file "INFO" "$message" "$context"
    fi
}

log_success() {
    local message="$1"
    local context="${2:-}"

    if should_log "SUCCESS"; then
        local prefix="${COLORS[GREEN]}[SUCCESS]${COLORS[RESET]}"
        echo -e "$prefix $message"
        log_to_file "SUCCESS" "$message" "$context"
    fi
}

log_warn() {
    local message="$1"
    local context="${2:-}"

    if should_log "WARN"; then
        local prefix="${COLORS[YELLOW]} [WARN]${COLORS[RESET]}"
        echo -e "$prefix $message" >&2
        log_to_file "WARN" "$message" "$context"
    fi
}

log_error() {
    local message="$1"
    local context="${2:-}"

    if should_log "ERROR"; then
        local prefix="${COLORS[RED]} [ERROR]${COLORS[RESET]}"
        echo -e "$prefix $message" >&2
        log_to_file "ERROR" "$message" "$context"
    fi
}

log_fatal() {
    local message="$1"
    local context="${2:-}"
    local exit_code="${3:-1}"

    if should_log "FATAL"; then
        local prefix="${COLORS[BOLD]}${COLORS[BG_RED]}${COLORS[WHITE]} [FATAL] ${COLORS[RESET]}"
        echo -e "$prefix ${COLORS[RED]}$message${COLORS[RESET]}" >&2
        log_to_file "FATAL" "$message" "$context"
    fi

    exit "$exit_code"
}

# ═══════════════════════════════════════════════════════════════════════════
# Specialized Logging Functions
# ═══════════════════════════════════════════════════════════════════════════

log_header() {
    local title="$1"
    local char="${2:-═}"
    local width=70

    echo -e "${COLORS[PURPLE]}${char}${COLORS[RESET]}" | head -c $width
    echo ""
    echo -e "${COLORS[PURPLE]}${COLORS[BOLD]}$title${COLORS[RESET]}"
    echo -e "${COLORS[PURPLE]}${char}${COLORS[RESET]}" | head -c $width
    echo ""
}

log_section() {
    local title="$1"
    echo ""
    echo -e "${COLORS[CYAN]}${COLORS[BOLD]}▶ $title${COLORS[RESET]}"
    echo -e "${COLORS[CYAN]}$( printf '─%.0s' {1..70} )${COLORS[RESET]}"
}

log_command() {
    local command="$1"
    local description="${2:-}"

    if [[ -n "$description" ]]; then
        log_debug "Executing: $description" "COMMAND"
    fi

    log_trace "$ $command" "COMMAND"
}

log_mcp_event() {
    local event_type="$1"
    local message="$2"
    local data="${3:-}"

    local prefix="${COLORS[BRIGHT_PURPLE]}[MCP]${COLORS[RESET]}"
    echo -e "$prefix ${COLORS[PURPLE]}[$event_type]${COLORS[RESET]} $message"

    if [[ -n "$data" ]]; then
        log_trace "$data" "MCP"
    fi

    log_to_file "MCP" "[$event_type] $message" "MCP"
}

log_docker_event() {
    local event_type="$1"
    local message="$2"

    local prefix="${COLORS[BRIGHT_BLUE]}[DOCKER]${COLORS[RESET]}"
    echo -e "$prefix ${COLORS[BLUE]}[$event_type]${COLORS[RESET]} $message"
    log_to_file "DOCKER" "[$event_type] $message" "DOCKER"
}

log_metric() {
    local metric_name="$1"
    local metric_value="$2"
    local unit="${3:-}"

    local display_value="$metric_value"
    if [[ -n "$unit" ]]; then
        display_value="$metric_value $unit"
    fi

    local prefix="${COLORS[CYAN]}[METRIC]${COLORS[RESET]}"
    echo -e "$prefix $metric_name: ${COLORS[BOLD]}$display_value${COLORS[RESET]}"
    log_to_file "METRIC" "$metric_name: $display_value" "METRICS"
}

log_json() {
    local json_data="$1"
    local pretty="${2:-false}"

    if command -v jq &>/dev/null && [[ "$pretty" == "true" ]]; then
        echo "$json_data" | jq '.' 2>/dev/null || echo "$json_data"
    else
        echo "$json_data"
    fi
}

log_progress() {
    local current="$1"
    local total="$2"
    local description="${3:-}"

    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))

    local bar="["
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    bar+="]"

    echo -ne "\r${COLORS[CYAN]}$bar${COLORS[RESET]} $percent% ($current/$total)"

    if [[ -n "$description" ]]; then
        echo -ne " - $description"
    fi

    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

log_table_header() {
    local -a headers=("$@")
    local separator=""

    echo -e "${COLORS[BOLD]}${headers[*]}${COLORS[RESET]}"

    for header in "${headers[@]}"; do
        separator+="$(printf '─%.0s' $(seq 1 ${#header}))"
        separator+="  "
    done

    echo -e "${COLORS[DIM]}$separator${COLORS[RESET]}"
}

log_table_row() {
    local -a cells=("$@")
    echo "${cells[*]}"
}

# ═══════════════════════════════════════════════════════════════════════════
# Utility Functions
# ═══════════════════════════════════════════════════════════════════════════

log_separator() {
    local char="${1:--}"
    local width=70
    printf "${COLORS[DIM]}%${width}s${COLORS[RESET]}\n" | tr ' ' "$char"
}

log_blank() {
    echo ""
}

log_spinner() {
    local pid="$1"
    local message="${2:-Processing...}"
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${COLORS[CYAN]}%c${COLORS[RESET]} %s" "$spinstr" "$message"
        spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done

    printf "\r%*s\r" $((${#message} + 4)) ""
}

# ═══════════════════════════════════════════════════════════════════════════
# Log Management Functions
# ═══════════════════════════════════════════════════════════════════════════

log_rotate() {
    local max_size_mb="${1:-10}"
    local max_size_bytes=$((max_size_mb * 1024 * 1024))

    if [[ -f "$LOG_FILE" ]]; then
        local file_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)

        if [[ $file_size -gt $max_size_bytes ]]; then
            local timestamp=$(date +%Y%m%d_%H%M%S)
            local archive="${LOG_FILE}.${timestamp}"

            mv "$LOG_FILE" "$archive"
            gzip "$archive" 2>/dev/null || true

            log_info "Log rotated: ${archive}.gz"
        fi
    fi
}

log_cleanup() {
    local days="${1:-7}"

    find "$LOG_DIR" -name "*.log.*" -mtime +"$days" -delete 2>/dev/null || true
    log_info "Cleaned up logs older than $days days"
}

log_tail() {
    local lines="${1:-50}"

    if [[ -f "$LOG_FILE" ]]; then
        tail -n "$lines" "$LOG_FILE"
    else
        log_warn "Log file not found: $LOG_FILE"
    fi
}

log_stats() {
    if [[ ! -f "$LOG_FILE" ]]; then
        log_warn "Log file not found: $LOG_FILE"
        return 1
    fi

    log_section "Log Statistics"

    local file_size=$(du -h "$LOG_FILE" | cut -f1)
    local line_count=$(wc -l < "$LOG_FILE")
    local error_count=$(grep -c "\[ERROR\]" "$LOG_FILE" 2>/dev/null || echo 0)
    local warn_count=$(grep -c "\[WARN\]" "$LOG_FILE" 2>/dev/null || echo 0)

    log_metric "File Size" "$file_size"
    log_metric "Total Lines" "$line_count" "lines"
    log_metric "Errors" "$error_count"
    log_metric "Warnings" "$warn_count"

    log_blank
}

# ═══════════════════════════════════════════════════════════════════════════
# Initialization
# ═══════════════════════════════════════════════════════════════════════════

# Auto-rotate on load
log_rotate 10 2>/dev/null || true

# Export functions for use in other scripts
export -f log_trace log_debug log_info log_success log_warn log_error log_fatal
export -f log_header log_section log_command log_separator log_blank
export -f log_mcp_event log_docker_event log_metric log_json log_progress
export -f log_table_header log_table_row log_spinner
export -f log_rotate log_cleanup log_tail log_stats
export -f timestamp should_log log_to_file
