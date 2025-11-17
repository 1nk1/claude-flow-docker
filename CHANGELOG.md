# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-11-17

### Added
- 📊 **Advanced Logging System** - Multi-level logging with file persistence
  - lib/logger.sh (420 lines) - 7 log levels with ANSI colors
  - scripts/view-logs.sh (257 lines) - Interactive log viewer with 12 modes
  - Automatic log rotation (10MB threshold)
  - Log cleanup (7 days retention)
  - Log statistics and metrics
  - MCP event tracking
- 📚 **Structured Documentation** - Organized docs/ directory
  - docs/getting-started/ - Quick start, installation, troubleshooting
  - docs/guides/ - Deployment, integration, logging guides
  - docs/mcp/ - MCP setup and connection guides
  - docs/development/ - Contributing guidelines
- 🎯 **Enhanced Project Structure**
  - config/.claude/ - Single source of truth for MCP configuration (75+ agents, 150+ commands)
  - project/.claude symlink - Clean workspace without duplication
  - scripts/ directory - All utility scripts organized
  - lib/ directory - Shared libraries

### Changed
- ♻️ **Major Cleanup** - Removed 16+ obsolete files
  - Consolidated 6 duplicate quickstart guides into one
  - Removed outdated meta-documentation from October
  - Eliminated temporary session files
  - Removed 8 obsolete files from project/docs/
- 🏗️ **Restructured Directories**
  - Moved all documentation to docs/ subdirectories
  - Organized scripts into scripts/ directory
  - Created lib/ for shared libraries
  - Consolidated .claude configurations (eliminated 1.5MB duplication)
- 📝 **Updated Documentation**
  - README.md updated with new structure
  - All internal links fixed
  - Makefile updated for new script paths
  - Clear documentation hierarchy

### Removed
- QUICKSTART.md (duplicated START_HERE.md)
- QUICK_START.md (duplicated MCP_README.md)
- SESSION_SUMMARY_2025-11-17.md (temporary session notes)
- CLEANUP_GUIDE.md (merged into CHANGELOG.md)
- CHANGES_SUMMARY.md (merged into CHANGELOG.md)
- QUICK_REFERENCE.md (redundant)
- docs/QUICKSTART_MCP.md (consolidated)
- docs/MCP_SETUP_SUMMARY.md (consolidated)
- project/docs/* (8 obsolete files from October)
- project/.claude/ directory (replaced with symlink to config/.claude/)
- Root .claude/ directory (migrated to config/.claude/)

### Performance
- 🚀 **Space Savings** - 1.5MB saved from .claude duplication elimination
- 📉 **Reduced Redundancy** - 99% duplicate files removed
- 🎯 **Improved Maintainability** - Single source of truth for all configurations

## [1.0.0] - 2025-01-04

### Added
- Initial release of Claude-Flow Docker
- Docker container with Node.js 22 and Claude-Flow alpha
- Complete MCP server integration for Claude Code
- Persistent SQLite storage for hive-mind and memory
- 27+ neural models with WASM SIMD acceleration
- 87 MCP tools for AI orchestration
- Hooks system for workflow automation
- GitHub Actions for CI/CD
  - Docker build and test workflow
  - MCP integration tests
  - Documentation validation
  - Security scanning with Trivy
- Comprehensive test suite
  - Docker build tests
  - MCP connection tests
  - Claude-Flow functionality tests
- Complete documentation
  - README with quick start
  - QUICKSTART guide
  - INSTALLATION guide
  - TROUBLESHOOTING guide
  - INTEGRATION examples
  - CONTRIBUTING guidelines
- Makefile with 20+ management commands
- Shell scripts for container management
- Issue and PR templates
- MIT License

### Features
- 🐝 Hive-Mind Intelligence - AI agent coordination
- 🧠 Neural Networks - 27+ cognitive models
- 🔧 MCP Tools - 87 tools for orchestration
- 💾 Persistent Storage - SQLite database
- 🪝 Hooks System - Pre/post operation automation
- 🔗 Local Integration - Claude Code without global install
- 📦 Node.js 22 - Latest LTS version
- 🛡️ Isolated Environment - Container isolation

### Security
- Trivy security scanning in CI/CD
- No sensitive data in repository
- Isolated Docker environment
- Proper .gitignore and .dockerignore

### Documentation
- Complete English documentation
- Code examples and usage patterns
- Troubleshooting guides
- Integration examples
- Contribution guidelines

## [Unreleased]

### Planned
- Flow Nexus Cloud integration examples
- Advanced agent coordination patterns
- Performance optimization guides
- Video tutorials
- Docker Hub automated builds
- Multi-platform builds (AMD64, ARM64)

---

## Version History

- **2.0.0** - Major Cleanup & Restructuring (2025-11-17)
  - Advanced logging system
  - Structured documentation
  - Eliminated 1.5MB duplication
  - Enhanced project organization
  - 16+ obsolete files removed

- **1.0.0** - Initial Release (2025-01-04)
  - Full Docker environment
  - MCP integration
  - CI/CD pipeline
  - Complete documentation

---

For more information, see:
- [GitHub Releases](https://github.com/1nk1/claude-flow-docker/releases)
- [Documentation](https://github.com/1nk1/claude-flow-docker/wiki)
