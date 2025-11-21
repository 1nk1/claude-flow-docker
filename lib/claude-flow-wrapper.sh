#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Claude-Flow Wrapper with REAL-TIME Agent Visualization
# Intercepts claude-flow commands and shows actual agent progress
# ═══════════════════════════════════════════════════════════════════════════

# Load agent logger
if [ -f /workspace/lib/agent-logger.sh ]; then
    source /workspace/lib/agent-logger.sh
fi

# Original claude-flow command (use npx)
CLAUDE_FLOW_BIN="npx"
CLAUDE_FLOW_ARGS="claude-flow@alpha"

# ═══════════════════════════════════════════════════════════════════════════
# REAL-TIME Agent Detection and Progress Tracking
# ═══════════════════════════════════════════════════════════════════════════

parse_agent_output_realtime() {
    local agent_counter=0
    declare -A agent_map
    local current_operation=""

    while IFS= read -r line; do
        # === ReasoningBank Operations ===
        if [[ "$line" =~ "ReasoningBank] Initializing" ]] || [[ "$line" =~ "Using ReasoningBank mode" ]]; then
            agent_counter=$((agent_counter + 1))
            agent_map["reasoningbank"]=$agent_counter
            log_agent_start $agent_counter "ReasoningEngine" "coordinator"
            log_agent_action $agent_counter "Initializing ReasoningBank" "Setting up AI memory system"
            current_operation="reasoningbank"

        elif [[ "$line" =~ "Database migrations completed" ]]; then
            if [ -n "${agent_map[reasoningbank]}" ]; then
                log_agent_action ${agent_map[reasoningbank]} "Database ready" "Migration completed successfully"
            fi

        elif [[ "$line" =~ "ReasoningBank] Database OK: ([0-9]+) tables" ]]; then
            tables="${BASH_REMATCH[1]}"
            if [ -n "${agent_map[reasoningbank]}" ]; then
                log_agent_action ${agent_map[reasoningbank]} "Database verified" "$tables tables found"
            fi

        # === Embeddings Model ===
        elif [[ "$line" =~ "Embeddings] Initializing" ]] || [[ "$line" =~ "Initializing local embedding model" ]]; then
            agent_counter=$((agent_counter + 1))
            agent_map["embeddings"]=$agent_counter
            log_agent_start $agent_counter "EmbeddingsEngine" "researcher"
            log_agent_action $agent_counter "Loading AI model" "Xenova/all-MiniLM-L6-v2"

        elif [[ "$line" =~ "download.*MB model" ]]; then
            if [ -n "${agent_map[embeddings]}" ]; then
                log_agent_action ${agent_map[embeddings]} "Downloading model" "First-time setup"
            fi

        elif [[ "$line" =~ "Local model ready.*([0-9]+) dimensions" ]]; then
            dims="${BASH_REMATCH[1]}"
            if [ -n "${agent_map[embeddings]}" ]; then
                log_agent_action ${agent_map[embeddings]} "Model loaded" "$dims-dimensional vectors"
                log_agent_complete ${agent_map[embeddings]} "Embeddings engine ready"
            fi

        # === Memory Storage Operations ===
        elif [[ "$line" =~ "Upserted reasoning memory" ]] || [[ "$line" =~ "Stored successfully" ]]; then
            agent_counter=$((agent_counter + 1))
            agent_map["storage"]=$agent_counter
            log_agent_start $agent_counter "MemoryStorage" "coder"
            log_agent_action $agent_counter "Writing to database" "Storing semantic memory"

        elif [[ "$line" =~ "Memory ID: ([a-f0-9-]+)" ]]; then
            memory_id="${BASH_REMATCH[1]}"
            if [ -n "${agent_map[storage]}" ]; then
                log_agent_action ${agent_map[storage]} "Memory stored" "ID: ${memory_id:0:8}..."
                log_agent_complete ${agent_map[storage]} "Memory saved successfully"
            elif [ -n "${agent_map[reasoningbank]}" ]; then
                log_agent_complete ${agent_map[reasoningbank]} "Operation complete"
            fi

        # === Memory Retrieval Operations ===
        elif [[ "$line" =~ "Retrieving memories for query" ]]; then
            agent_counter=$((agent_counter + 1))
            agent_map["retrieval"]=$agent_counter
            log_agent_start $agent_counter "MemoryRetrieval" "researcher"
            log_agent_action $agent_counter "Searching memories" "Semantic search active"

        elif [[ "$line" =~ "Semantic search returned ([0-9]+) results" ]]; then
            results="${BASH_REMATCH[1]}"
            if [ -n "${agent_map[retrieval]}" ]; then
                log_agent_action ${agent_map[retrieval]} "Search completed" "Found $results matches"
                log_agent_complete ${agent_map[retrieval]} "Retrieved $results memories"
            fi

        elif [[ "$line" =~ "No results found" ]] || [[ "$line" =~ "No memory candidates" ]]; then
            if [ -n "${agent_map[retrieval]}" ]; then
                log_agent_action ${agent_map[retrieval]} "Search completed" "No matches found"
                log_agent_complete ${agent_map[retrieval]} "Query complete (0 results)"
            fi

        # === Hive-Mind Operations ===
        elif [[ "$line" =~ "Initializing Hive Mind" ]]; then
            agent_counter=$((agent_counter + 1))
            agent_map["hive"]=$agent_counter
            log_agent_start $agent_counter "HiveMindCoordinator" "coordinator"
            log_agent_action $agent_counter "Initializing system" "Setting up hive-mind"

        elif [[ "$line" =~ "Hive Mind system initialized successfully" ]]; then
            if [ -n "${agent_map[hive]}" ]; then
                log_agent_action ${agent_map[hive]} "System ready" "Configuration complete"
                log_agent_complete ${agent_map[hive]} "Hive-mind operational"
            fi

        # === Swarm Operations ===
        elif [[ "$line" =~ "Creating swarm"|"Spawning swarm" ]]; then
            agent_counter=$((agent_counter + 1))
            agent_map["swarm"]=$agent_counter
            log_agent_start $agent_counter "SwarmCoordinator" "coordinator"
            log_agent_action $agent_counter "Creating swarm" "Initializing agents"

        # === Error Detection ===
        elif [[ "$line" =~ "ERROR"|"Error"|"Failed" ]]; then
            # Find which agent to attribute error to
            for key in "${!agent_map[@]}"; do
                if [ -n "${agent_map[$key]}" ]; then
                    error_msg=$(echo "$line" | sed -E 's/.*[Ee]rror:?\s*(.+)/\1/' | head -c 80)
                    log_agent_error ${agent_map[$key]} "$error_msg"
                    break
                fi
            done

        # === Connection Close ===
        elif [[ "$line" =~ "Closed.*database connection" ]]; then
            # Complete any remaining agents
            if [ -n "${agent_map[reasoningbank]}" ]; then
                log_agent_complete ${agent_map[reasoningbank]} "Connection closed"
            fi
        fi

        # Pass through original output
        echo "$line"
    done

    # === Complete all remaining agents at EOF ===
    echo ""
    for key in "${!agent_map[@]}"; do
        if [ -n "${agent_map[$key]}" ]; then
            log_agent_complete ${agent_map[$key]} "Operation completed successfully"
        fi
    done
}

# ═══════════════════════════════════════════════════════════════════════════
# Command Execution with Smart Detection
# ═══════════════════════════════════════════════════════════════════════════

# Check if command should have agent visualization
if [[ "$@" =~ "hive-mind"|"swarm"|"spawn"|"memory"|"agent"|"neural" ]]; then
    # Run with real-time agent logging
    $CLAUDE_FLOW_BIN $CLAUDE_FLOW_ARGS "$@" 2>&1 | parse_agent_output_realtime
else
    # Run normally without interception
    $CLAUDE_FLOW_BIN $CLAUDE_FLOW_ARGS "$@"
fi
