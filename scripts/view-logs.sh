#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Docker - Log Viewer
# Interactive log viewing and analysis tool
# ═══════════════════════════════════════════════════════════════════════════

CONTAINER_NAME="claude-flow-alpha"
LOG_FILE="/workspace/logs/claude-flow.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

show_banner() {
    echo -e "${PURPLE}${BOLD}"
    echo "═══════════════════════════════════════════════════════════════════"
    echo "  📊 Claude-Flow Docker - Log Viewer"
    echo "═══════════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${CYAN}${BOLD}Available Options:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}  - Follow container logs (real-time)"
    echo -e "  ${GREEN}2${NC}  - Follow application logs (real-time)"
    echo -e "  ${GREEN}3${NC}  - View last 50 lines"
    echo -e "  ${GREEN}4${NC}  - View last 100 lines"
    echo -e "  ${GREEN}5${NC}  - Search for errors"
    echo -e "  ${GREEN}6${NC}  - Search for warnings"
    echo -e "  ${GREEN}7${NC}  - View MCP events only"
    echo -e "  ${GREEN}8${NC}  - View Docker events only"
    echo -e "  ${GREEN}9${NC}  - Log statistics"
    echo -e "  ${GREEN}10${NC} - Search by custom pattern"
    echo -e "  ${GREEN}11${NC} - View logs by date/time"
    echo -e "  ${GREEN}12${NC} - Export logs to file"
    echo ""
    echo -e "  ${YELLOW}r${NC}  - Refresh menu"
    echo -e "  ${RED}q${NC}  - Quit"
    echo ""
}

check_container() {
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${RED}Error: Container '${CONTAINER_NAME}' is not running${NC}"
        echo ""
        echo "Start the container with:"
        echo "  docker-compose up -d"
        echo "  or: make start"
        exit 1
    fi
}

follow_container_logs() {
    echo -e "${CYAN}Following container logs (Ctrl+C to stop)...${NC}"
    echo ""
    docker logs -f "$CONTAINER_NAME"
}

follow_app_logs() {
    echo -e "${CYAN}Following application logs (Ctrl+C to stop)...${NC}"
    echo ""
    docker exec "$CONTAINER_NAME" tail -f "$LOG_FILE" 2>/dev/null || {
        echo -e "${RED}Error: Log file not found${NC}"
        return 1
    }
}

view_last_lines() {
    local lines=$1
    echo -e "${CYAN}Last ${lines} lines of application log:${NC}"
    echo ""
    docker exec "$CONTAINER_NAME" tail -n "$lines" "$LOG_FILE" 2>/dev/null || {
        echo -e "${RED}Error: Log file not found${NC}"
        return 1
    }
}

search_errors() {
    echo -e "${CYAN}Searching for errors...${NC}"
    echo ""
    docker exec "$CONTAINER_NAME" grep -E "\[ERROR\]|\[FATAL\]" "$LOG_FILE" 2>/dev/null || {
        echo -e "${GREEN}No errors found!${NC}"
    }
}

search_warnings() {
    echo -e "${CYAN}Searching for warnings...${NC}"
    echo ""
    docker exec "$CONTAINER_NAME" grep "\[WARN\]" "$LOG_FILE" 2>/dev/null || {
        echo -e "${GREEN}No warnings found!${NC}"
    }
}

view_mcp_events() {
    echo -e "${CYAN}MCP events:${NC}"
    echo ""
    docker exec "$CONTAINER_NAME" grep "\[MCP\]" "$LOG_FILE" 2>/dev/null || {
        echo -e "${YELLOW}No MCP events found${NC}"
    }
}

view_docker_events() {
    echo -e "${CYAN}Docker events:${NC}"
    echo ""
    docker exec "$CONTAINER_NAME" grep "\[DOCKER\]" "$LOG_FILE" 2>/dev/null || {
        echo -e "${YELLOW}No Docker events found${NC}"
    }
}

show_statistics() {
    echo -e "${CYAN}Log Statistics:${NC}"
    echo ""
    docker exec "$CONTAINER_NAME" bash -c "source /workspace/lib/logger.sh && log_stats" 2>/dev/null || {
        # Fallback if logger not available
        echo -e "${YELLOW}Logger library not available, showing basic stats:${NC}"
        echo ""

        local file_size=$(docker exec "$CONTAINER_NAME" du -h "$LOG_FILE" 2>/dev/null | cut -f1)
        local line_count=$(docker exec "$CONTAINER_NAME" wc -l < "$LOG_FILE" 2>/dev/null)
        local error_count=$(docker exec "$CONTAINER_NAME" grep -c "\[ERROR\]" "$LOG_FILE" 2>/dev/null || echo 0)
        local warn_count=$(docker exec "$CONTAINER_NAME" grep -c "\[WARN\]" "$LOG_FILE" 2>/dev/null || echo 0)

        echo "File Size: $file_size"
        echo "Total Lines: $line_count"
        echo "Errors: $error_count"
        echo "Warnings: $warn_count"
    }
}

custom_search() {
    echo -e "${CYAN}Enter search pattern:${NC} "
    read -r pattern

    if [[ -z "$pattern" ]]; then
        echo -e "${RED}No pattern provided${NC}"
        return 1
    fi

    echo ""
    echo -e "${CYAN}Searching for: ${BOLD}$pattern${NC}"
    echo ""

    docker exec "$CONTAINER_NAME" grep -i "$pattern" "$LOG_FILE" 2>/dev/null || {
        echo -e "${YELLOW}No matches found${NC}"
    }
}

view_by_date() {
    echo -e "${CYAN}Enter date/time to search (e.g., '2025-11-17', '10:30'):${NC} "
    read -r datetime

    if [[ -z "$datetime" ]]; then
        echo -e "${RED}No date/time provided${NC}"
        return 1
    fi

    echo ""
    echo -e "${CYAN}Logs containing: ${BOLD}$datetime${NC}"
    echo ""

    docker exec "$CONTAINER_NAME" grep "$datetime" "$LOG_FILE" 2>/dev/null || {
        echo -e "${YELLOW}No logs found for that date/time${NC}"
    }
}

export_logs() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local export_file="claude-flow-logs-${timestamp}.txt"

    echo -e "${CYAN}Exporting logs to: ${BOLD}$export_file${NC}"

    docker exec "$CONTAINER_NAME" cat "$LOG_FILE" > "$export_file" 2>/dev/null && {
        echo -e "${GREEN}Logs exported successfully!${NC}"
        echo "File: $export_file"
        echo "Size: $(du -h "$export_file" | cut -f1)"
    } || {
        echo -e "${RED}Error: Failed to export logs${NC}"
        return 1
    }
}

# Main loop
show_banner
check_container

while true; do
    show_menu
    echo -ne "${BOLD}Select option:${NC} "
    read -r choice

    echo ""

    case $choice in
        1)
            follow_container_logs
            ;;
        2)
            follow_app_logs
            ;;
        3)
            view_last_lines 50
            ;;
        4)
            view_last_lines 100
            ;;
        5)
            search_errors
            ;;
        6)
            search_warnings
            ;;
        7)
            view_mcp_events
            ;;
        8)
            view_docker_events
            ;;
        9)
            show_statistics
            ;;
        10)
            custom_search
            ;;
        11)
            view_by_date
            ;;
        12)
            export_logs
            ;;
        r|R)
            clear
            show_banner
            ;;
        q|Q)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac

    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
    clear
    show_banner
done
