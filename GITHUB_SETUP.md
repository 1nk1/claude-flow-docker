# 📦 GitHub Setup & Deployment Guide

Complete guide to push Claude-Flow Docker to GitHub and test with GitHub Actions.

## 🎯 Prerequisites

- GitHub account
- Git installed locally
- SSH keys configured (or use HTTPS)

## 🚀 Setup Steps

### 1. Create GitHub Repository

```bash
# Go to https://github.com/new
# Repository name: claude-flow-docker
# Description: Isolated Docker environment for Claude-Flow with local Claude Code integration
# Public or Private: Your choice
# Do NOT initialize with README (we have one)
```

### 2. Extract and Prepare Files

```bash
# Extract the archive
cd ~/Downloads
tar -xzf claude-flow-docker-github-ready.tar.gz -C ~/claude-flow-docker-github

# Enter directory
cd ~/claude-flow-docker-github

# Verify structure
ls -la
```

### 3. Initialize Git Repository

```bash
# Initialize git
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: Claude-Flow Docker v1.0.0

- Docker container with Node.js 22 and Claude-Flow
- Complete MCP integration for Claude Code
- GitHub Actions CI/CD pipeline
- Comprehensive documentation and tests"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin git@github.com:YOUR_USERNAME/claude-flow-docker.git

# Or using HTTPS:
# git remote add origin https://github.com/YOUR_USERNAME/claude-flow-docker.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 4. Verify GitHub Actions

After pushing, GitHub Actions will automatically run:

1. Go to your repository on GitHub
2. Click "Actions" tab
3. You should see workflows running:
   - ✅ Docker Build and Test
   - ✅ MCP Integration Tests
   - ✅ Documentation

Wait for all checks to pass (takes 5-10 minutes).

### 5. Update README Badges

Edit `README.md` and replace `YOUR_USERNAME` with your actual GitHub username:

```bash
# Find and replace
sed -i 's/YOUR_USERNAME/your-actual-username/g' README.md

# Commit the change
git add README.md
git commit -m "docs: Update badges with correct username"
git push
```

## 🧪 Testing GitHub Actions Locally

### Option 1: Act (GitHub Actions Local Runner)

```bash
# Install act
brew install act  # macOS
# or
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash  # Linux

# Run workflows
act -l  # List workflows
act push  # Run push workflows
act pull_request  # Run PR workflows
```

### Option 2: Manual Testing

```bash
# Run the same tests that GitHub Actions runs
./tests/test-docker-build.sh
./tests/test-mcp-connection.sh
./tests/test-claude-flow.sh
```

## 📋 Checklist Before First Push

- [ ] Updated `YOUR_USERNAME` in README.md
- [ ] Updated `YOUR_USERNAME` in workflows
- [ ] Reviewed .gitignore
- [ ] Tested locally with `make test`
- [ ] All scripts are executable
- [ ] No sensitive data (API keys, passwords)
- [ ] LICENSE file present
- [ ] Documentation complete

## 🔧 Configuration

### GitHub Secrets (Optional)

If you want to publish Docker images:

1. Go to Settings → Secrets and variables → Actions
2. Add secrets:
   - `DOCKER_USERNAME` - Your Docker Hub username
   - `DOCKER_TOKEN` - Docker Hub access token
   - `GITHUB_TOKEN` - Auto-generated, already available

### Branch Protection

Set up branch protection for `main`:

1. Go to Settings → Branches
2. Add rule for `main`:
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - Select: Docker Build and Test, MCP Integration Tests

## 📊 Post-Push Tasks

### 1. Create Release

```bash
# Tag the release
git tag -a v1.0.0 -m "Release v1.0.0: Initial release"
git push origin v1.0.0

# On GitHub:
# Go to Releases → Draft a new release
# Choose tag v1.0.0
# Title: v1.0.0 - Initial Release
# Description: Copy from CHANGELOG.md
```

### 2. Enable GitHub Pages (Optional)

```bash
# For documentation site
# Settings → Pages
# Source: GitHub Actions or main branch /docs folder
```

### 3. Setup Topics

Add repository topics on GitHub:
- `docker`
- `claude-ai`
- `ai-orchestration`
- `mcp`
- `claude-code`
- `hive-mind`
- `nodejs`
- `containerization`

### 4. Add Description

```
Isolated Docker environment for Claude-Flow with local Claude Code integration. AI orchestration with hive-mind intelligence, 87 MCP tools, and persistent storage.
```

### 5. Enable Discussions (Optional)

Settings → General → Features → ✅ Discussions

## 🔄 Development Workflow

### Creating a Feature

```bash
# Create feature branch
git checkout -b feature/awesome-feature

# Make changes
# ... edit files ...

# Commit
git add .
git commit -m "feat: Add awesome feature"

# Push
git push origin feature/awesome-feature

# Create Pull Request on GitHub
```

### Workflow Testing

```bash
# Before creating PR, run tests
make test

# Check GitHub Actions would pass
./tests/test-docker-build.sh
./tests/test-mcp-connection.sh
./tests/test-claude-flow.sh
```

## 🐛 Troubleshooting

### GitHub Actions Failing

**Docker Build Failure:**
```bash
# Test locally
docker build -t test-image .

# Check logs
docker build --no-cache --progress=plain -t test-image .
```

**Test Failures:**
```bash
# Run individual tests
./tests/test-docker-build.sh
./tests/test-mcp-connection.sh

# Check container logs
docker-compose logs
```

### Push Rejected

```bash
# Pull latest changes
git pull origin main --rebase

# Resolve conflicts if any
git add .
git rebase --continue

# Push again
git push
```

### Large Files

```bash
# If you accidentally committed large files
git rm --cached large-file
echo "large-file" >> .gitignore
git add .gitignore
git commit --amend
git push --force
```

## 📈 Monitoring

### GitHub Actions Status

Watch workflows at:
```
https://github.com/YOUR_USERNAME/claude-flow-docker/actions
```

### Security Alerts

Check for vulnerabilities:
```
https://github.com/YOUR_USERNAME/claude-flow-docker/security
```

### Insights

View repository analytics:
```
https://github.com/YOUR_USERNAME/claude-flow-docker/pulse
```

## 🎉 Success Criteria

After setup, you should have:
- ✅ Repository on GitHub
- ✅ All GitHub Actions passing
- ✅ README with correct badges
- ✅ First release (v1.0.0)
- ✅ Branch protection enabled
- ✅ Topics configured
- ✅ No security alerts

## 📚 Next Steps

1. **Share your repository**
   - Tweet about it
   - Post in relevant communities
   - Add to awesome lists

2. **Documentation**
   - Create Wiki pages
   - Add video tutorials
   - Write blog posts

3. **Community**
   - Respond to issues
   - Review pull requests
   - Engage with users

4. **Features**
   - Plan v1.1.0
   - Gather feedback
   - Implement improvements

## 🆘 Get Help

If you encounter issues:
1. Check GitHub Actions logs
2. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Create an issue
4. Ask in Discussions

---

**Good luck with your repository! 🚀**

**Made with ❤️ for the Claude-Flow community**
