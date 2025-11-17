# Logging System Documentation

## Overview

Claude-Flow Docker now includes a comprehensive logging system that provides detailed visibility into container operations, MCP events, and claude-flow activities.

## Features

### Multi-Level Logging

Seven log levels with different purposes:

| Level | Value | Description | Use Case |
|-------|-------|-------------|----------|
| TRACE | 0 | Extremely detailed | Debugging npm installs, command outputs |
| DEBUG | 1 | Debug information | Development, troubleshooting |
| INFO | 2 | General information | Normal operations (default) |
| SUCCESS | 3 | Success messages | Confirmations, completed tasks |
| WARN | 4 | Warnings | Non-critical issues |
| ERROR | 5 | Errors | Failures that don't stop execution |
| FATAL | 6 | Fatal errors | Critical failures (exits process) |

### Dual Output

- **Console**: Colored, formatted output with ANSI codes
- **File**: Plain text logs at `/workspace/logs/claude-flow.log`

### Automatic Management

- **Log Rotation**: Automatically rotates when file exceeds 10MB
- **Compression**: Old logs compressed with gzip
- **Cleanup**: Removes logs older than 7 days
- **Timestamps**: All log entries timestamped

## Configuration

### Environment Variables

Set these in your `.env` file or docker-compose.yml:

```bash
# Log level (TRACE, DEBUG, INFO, SUCCESS, WARN, ERROR, FATAL)
LOG_LEVEL=INFO

# Enable/disable file logging
LOG_TO_FILE=true

# Log file location
LOG_FILE=/workspace/logs/claude-flow.log

# Timestamp format (strftime format)
LOG_TIMESTAMP_FORMAT=%Y-%m-%d %H:%M:%S
```

### Docker Compose Configuration

```yaml
environment:
  - LOG_LEVEL=DEBUG              # Set log level
  - LOG_TO_FILE=true             # Enable file logging
  - LOG_FILE=/workspace/logs/claude-flow.log

volumes:
  - ./logs:/workspace/logs       # Mount logs to host
```

## Usage

### Viewing Logs

#### Real-time Container Logs (Console Output)

```bash
# Follow container logs
docker logs -f claude-flow-alpha

# Last 100 lines
docker logs --tail 100 claude-flow-alpha

# Since 1 hour ago
docker logs --since 1h claude-flow-alpha
```

#### Application Logs (File)

```bash
# Follow application log file
docker exec claude-flow-alpha tail -f /workspace/logs/claude-flow.log

# Last 50 lines
docker exec claude-flow-alpha tail -n 50 /workspace/logs/claude-flow.log

# From host (if volume mounted)
tail -f ./logs/claude-flow.log
```

#### Search Logs

```bash
# Find errors
docker exec claude-flow-alpha grep ERROR /workspace/logs/claude-flow.log

# Find MCP events
docker exec claude-flow-alpha grep "\[MCP\]" /workspace/logs/claude-flow.log

# Find warnings and errors
docker exec claude-flow-alpha grep -E "\[WARN\]|\[ERROR\]" /workspace/logs/claude-flow.log
```

### Log Management Commands

#### Log Statistics

```bash
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_stats
"
```

Output:
```
▶ Log Statistics
──────────────────────────────────────────────────────────────────────
[METRIC] File Size: 2.3M
[METRIC] Total Lines: 15420 lines
[METRIC] Errors: 3
[METRIC] Warnings: 12
```

#### Manual Log Rotation

```bash
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_rotate 10
"
```

#### Cleanup Old Logs

```bash
# Remove logs older than 7 days (default)
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_cleanup 7
"

# Remove logs older than 30 days
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_cleanup 30
"
```

#### View Last N Lines

```bash
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_tail 100
"
```

## Log Functions Reference

### Basic Logging

```bash
source /workspace/lib/logger.sh

log_trace "Detailed trace info"
log_debug "Debug message"
log_info "Information"
log_success "Operation successful"
log_warn "Warning message"
log_error "Error occurred"
log_fatal "Critical error" "CONTEXT" 1  # Exits with code 1
```

### Specialized Logging

#### Headers and Sections

```bash
log_header "Application Startup"
# ═══════════════════════════════════════
# Application Startup
# ═══════════════════════════════════════

log_section "Database Connection"
# ▶ Database Connection
# ──────────────────────────────────────────────────────────────────────
```

#### MCP Events

```bash
log_mcp_event "CONNECT" "MCP server connected successfully"
log_mcp_event "TOOL_CALL" "swarm_create invoked" '{"agents": 5}'
```

#### Docker Events

```bash
log_docker_event "START" "Container started"
log_docker_event "HEALTH" "Health check passed"
```

#### Metrics

```bash
log_metric "Memory Usage" "256" "MB"
log_metric "Active Agents" "5"
log_metric "Response Time" "123" "ms"
```

#### Commands

```bash
log_command "npm install -g claude-flow" "Installing Claude-Flow"
# Logs command execution for trace level
```

#### Progress Bars

```bash
for i in {1..100}; do
  log_progress $i 100 "Processing items"
  sleep 0.1
done
```

#### JSON Output

```bash
log_json '{"status":"ok","count":42}' true  # Pretty print with jq
```

## Log Format

### Console Output

Colored, formatted for readability:

```
[2025-11-17 10:30:45] [INFO] Container started
[2025-11-17 10:30:46] [SUCCESS] Node.js: v22.11.0
[2025-11-17 10:30:47] [MCP] [CONNECT] Server ready
[2025-11-17 10:30:48] [METRIC] Memory: 256MB
```

### File Output

Plain text with timestamps and contexts:

```
[2025-11-17 10:30:45] [INFO] Container started
[2025-11-17 10:30:46] [INFO] [NODEJS] Node.js version: v22.11.0
[2025-11-17 10:30:47] [MCP] [CONNECT] Server ready
[2025-11-17 10:30:48] [METRIC] Memory: 256MB
```

## Common Use Cases

### Debugging MCP Connection Issues

```bash
# Set DEBUG level
docker-compose down
LOG_LEVEL=DEBUG docker-compose up -d

# Watch MCP events
docker logs -f claude-flow-alpha | grep MCP

# Check application logs
docker exec claude-flow-alpha tail -f /workspace/logs/claude-flow.log | grep MCP
```

### Monitoring Performance

```bash
# View metrics
docker exec claude-flow-alpha grep METRIC /workspace/logs/claude-flow.log

# Real-time metrics
docker logs -f claude-flow-alpha | grep METRIC
```

### Troubleshooting Startup Issues

```bash
# View full startup sequence
docker logs claude-flow-alpha

# Check for errors during startup
docker logs claude-flow-alpha | grep -E "ERROR|FATAL"

# Detailed trace
LOG_LEVEL=TRACE docker-compose up
```

### Analyzing Historical Data

```bash
# Count errors by day
docker exec claude-flow-alpha bash -c "
  cat /workspace/logs/claude-flow.log* | \
  grep ERROR | \
  awk '{print \$1}' | \
  sort | uniq -c
"

# Most common warnings
docker exec claude-flow-alpha bash -c "
  grep WARN /workspace/logs/claude-flow.log | \
  awk '{print substr(\$0, index(\$0,\$4))}' | \
  sort | uniq -c | sort -rn | head -10
"
```

## Integration with Scripts

### Custom Scripts

```bash
#!/bin/bash

# Load logger
source /workspace/lib/logger.sh

# Use logging functions
log_header "My Custom Script"
log_info "Starting processing..."

if process_data; then
  log_success "Data processed successfully"
else
  log_error "Failed to process data"
  exit 1
fi

log_metric "Records Processed" "$count" "records"
```

### In Docker Entrypoint

The entrypoint script (`docker-entrypoint.sh`) automatically loads and uses the logger:

```bash
source /workspace/lib/logger.sh

log_section "Node.js Environment"
NODE_VERSION=$(node --version)
log_success "Node.js: $NODE_VERSION"
```

## Best Practices

### 1. Choose Appropriate Log Levels

- Use **TRACE** for detailed debugging (npm output, command execution)
- Use **DEBUG** for development and troubleshooting
- Use **INFO** for normal operations (default in production)
- Use **SUCCESS** for confirmations
- Use **WARN** for recoverable issues
- Use **ERROR** for failures that don't stop execution
- Use **FATAL** for critical errors that require exit

### 2. Include Context

```bash
log_error "Connection failed" "DATABASE"
log_info "User authenticated" "AUTH"
```

### 3. Use Specialized Functions

Instead of:
```bash
log_info "[MCP] Server connected"
```

Use:
```bash
log_mcp_event "CONNECT" "Server connected"
```

### 4. Monitor Log Size

```bash
# Check log size
docker exec claude-flow-alpha du -h /workspace/logs/claude-flow.log

# Rotate if needed
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_rotate 10
"
```

### 5. Regular Cleanup

Add to cron or run periodically:
```bash
# Cleanup weekly
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_cleanup 7
"
```

## Troubleshooting Logging Issues

### Logs Not Appearing in File

1. Check LOG_TO_FILE is enabled:
```bash
docker exec claude-flow-alpha env | grep LOG_TO_FILE
```

2. Check log directory permissions:
```bash
docker exec claude-flow-alpha ls -la /workspace/logs/
```

3. Check disk space:
```bash
docker exec claude-flow-alpha df -h /workspace/logs
```

### Colors Not Showing

If colors don't appear in console:
- Ensure terminal supports ANSI colors
- Check if output is being piped (colors auto-disable)
- Use `docker logs` directly (not redirected to file)

### Log File Too Large

```bash
# Immediate rotation
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_rotate 1
"

# Aggressive cleanup
docker exec claude-flow-alpha bash -c "
  source /workspace/lib/logger.sh && log_cleanup 1
"
```

### Missing Log Entries

1. Check log level:
```bash
docker exec claude-flow-alpha env | grep LOG_LEVEL
```

2. Lower log level for more detail:
```bash
docker-compose down
LOG_LEVEL=DEBUG docker-compose up -d
```

## Performance Impact

The logging system is designed to be lightweight:

- **Console logging**: Minimal overhead (direct echo)
- **File logging**: Asynchronous append operations
- **Log rotation**: Runs only when needed (>10MB)
- **Cleanup**: Background process, doesn't block

Typical performance impact: <1% CPU, <10MB memory

## Security Considerations

1. **Sensitive Data**: Logger doesn't automatically redact sensitive data
   - Avoid logging passwords, tokens, API keys
   - Use contexts carefully

2. **Log Access**: Log files readable by container user
   - Protect host-mounted log directory
   - Use appropriate file permissions

3. **Log Retention**: Balance between debugging and storage
   - Adjust cleanup period based on compliance requirements
   - Consider log aggregation for production

## Future Enhancements

Planned improvements:

- [ ] Structured logging (JSON format option)
- [ ] Remote log shipping (syslog, fluentd)
- [ ] Log filtering and redaction
- [ ] Web-based log viewer
- [ ] Real-time log streaming API
- [ ] Integration with monitoring tools (Prometheus, Grafana)

---

**Version:** 1.0.0
**Last Updated:** November 17, 2025
**Status:** Production Ready
