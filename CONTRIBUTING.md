# Contributing to Claude-Flow Docker

First off, thank you for considering contributing to Claude-Flow Docker! It's people like you that make this project better.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples**
* **Describe the behavior you observed** and explain which behavior you expected to see instead
* **Include logs and error messages**
* **Specify your environment**:
  - OS and version
  - Docker version
  - Docker Compose version
  - Claude Code version (if applicable)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description** of the suggested enhancement
* **Provide specific examples** to demonstrate the steps
* **Describe the current behavior** and explain which behavior you expected to see instead
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Follow the coding style (see below)
* Include tests when adding new features
* Update documentation as needed
* End all files with a newline

## Development Setup

### Prerequisites

```bash
git clone https://github.com/1nk1kas/claude-flow-docker.git
cd claude-flow-docker
```

### Local Development

```bash
# Install dependencies
make setup

# Start development environment
make start

# Run tests
make test

# Check logs
make logs
```

### Running Tests

```bash
# All tests
./tests/test-docker-build.sh
./tests/test-mcp-connection.sh
./tests/test-claude-flow.sh

# Or via Make
make test
```

## Coding Standards

### Shell Scripts

* Use `#!/bin/bash` shebang
* Include descriptive comments
* Use meaningful variable names
* Follow the existing code style
* Add error handling with `set -e`
* Use colors for output (GREEN, RED, BLUE, NC)

### Docker

* Keep images as small as possible
* Use multi-stage builds when appropriate
* Add health checks
* Document all ENV variables
* Use `.dockerignore` to exclude unnecessary files

### Documentation

* Use clear, concise language
* Include code examples
* Add screenshots when helpful
* Keep README.md up to date
* Update CHANGELOG.md

### Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

Examples:
```
Add MCP connection tests

- Add test-mcp-connection.sh script
- Update GitHub Actions workflow
- Add documentation for MCP testing

Fixes #123
```

## Testing Checklist

Before submitting a pull request, ensure:

- [ ] All tests pass locally
- [ ] Documentation is updated
- [ ] Code follows project style
- [ ] Commit messages are clear
- [ ] No unnecessary files are included
- [ ] `.gitignore` is updated if needed

## GitHub Actions

All PRs automatically run:
- Docker build tests
- MCP integration tests
- Documentation validation
- Security scans

Ensure these pass before requesting review.

## Project Structure

```
claude-flow-docker/
├── .github/          # GitHub Actions and templates
├── config/           # Configuration files
├── tests/            # Test scripts
├── docs/             # Additional documentation
├── Dockerfile        # Main Docker image
├── docker-compose.yml
├── Makefile          # Make commands
└── *.sh              # Shell scripts
```

## Release Process

1. Update version in relevant files
2. Update CHANGELOG.md
3. Create a pull request
4. After merge, tag the release
5. GitHub Actions will build and publish

## Questions?

Feel free to:
- Open an issue
- Start a discussion
- Contact maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for your contribution! 🎉**
