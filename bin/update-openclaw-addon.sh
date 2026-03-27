#!/bin/bash
#
# OpenClaw HA Addon Update Script
#
# This script automates the process of syncing the openclaw fork to upstream
# and updating the hassio-addons configuration.
#
# Usage: ./bin/update-openclaw-addon.sh
#
set -euo pipefail

# Configuration
FORK_DIR="${FORK_DIR:-/home/node/Projects/openclaw}"
ADDON_DIR="${ADDON_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prereqs() {
    log_info "Checking prerequisites..."

    if [ ! -d "$FORK_DIR/.git" ]; then
        log_error "Fork directory not found or not a git repo: $FORK_DIR"
        exit 1
    fi

    if [ ! -d "$ADDON_DIR/openclaw" ]; then
        log_error "Addon directory not found: $ADDON_DIR/openclaw"
        exit 1
    fi

    log_success "Prerequisites OK"
}

# Get current state
get_current_state() {
    log_info "Getting current state..."

    cd "$FORK_DIR"

    # Get current fork HEAD
    FORK_HEAD=$(git rev-parse HEAD)
    FORK_HEAD_SHORT=$(git rev-parse --short HEAD)
    log_info "Fork HEAD: $FORK_HEAD_SHORT"

    # Check if upstream remote exists
    if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
        log_warn "Upstream remote '$UPSTREAM_REMOTE' not found"
        log_info "Adding upstream remote..."
        git remote add "$UPSTREAM_REMOTE" "https://github.com/openclaw/openclaw.git"
    fi

    # Fetch upstream
    log_info "Fetching upstream..."
    git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" --quiet

    UPSTREAM_HEAD=$(git rev-parse "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH")
    UPSTREAM_HEAD_SHORT=$(git rev-parse --short "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH")
    log_info "Upstream HEAD: $UPSTREAM_HEAD_SHORT"

    # Count commits ahead/behind
    AHEAD=$(git rev-list --count "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH..HEAD" 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count "HEAD..$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" 2>/dev/null || echo "0")

    log_info "Fork is $AHEAD commits ahead, $BEHIND commits behind upstream"

    # Get addon version
    cd "$ADDON_DIR"
    ADDON_VERSION=$(grep -oP 'version: "\K[^"]+' openclaw/config.yaml)
    log_info "Current addon version: $ADDON_VERSION"

    # Check OPENCLAW_REF mode
    BUILD_REF=$(grep -oP 'OPENCLAW_REF: "\K[^"]+' openclaw/build.yaml)
    log_info "Build OPENCLAW_REF: $BUILD_REF"
}

# Create stable tag before sync
create_stable_tag() {
    log_info "Creating stable tag before sync..."

    cd "$FORK_DIR"

    TAG_NAME="stable-$(date +%Y-%m-%d)"

    if git tag -l | grep -q "^${TAG_NAME}$"; then
        log_warn "Tag $TAG_NAME already exists, skipping"
    else
        git tag "$TAG_NAME" HEAD
        log_success "Created tag: $TAG_NAME"
    fi
}

# Sync fork to upstream
sync_fork() {
    log_info "Syncing fork to upstream..."

    cd "$FORK_DIR"

    # Make sure we're on main
    CURRENT_BRANCH=$(git branch --show-current)
    if [ "$CURRENT_BRANCH" != "main" ]; then
        log_warn "Not on main branch (on $CURRENT_BRANCH)"
        read -p "Switch to main? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git checkout main
        else
            log_error "Aborting - not on main branch"
            exit 1
        fi
    fi

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        log_error "Uncommitted changes in fork. Please commit or stash first."
        exit 1
    fi

    # Rebase onto upstream
    log_info "Rebasing onto upstream..."
    if ! git rebase "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"; then
        log_error "Rebase conflict detected!"
        log_error "Please resolve conflicts manually, then run:"
        log_error "  git rebase --continue"
        log_error "  git push origin main --force-with-lease"
        log_error ""
        log_error "To abort this rebase:"
        log_error "  git rebase --abort"
        exit 1
    fi

    log_success "Rebase completed successfully"

    # Get new HEAD
    NEW_HEAD=$(git rev-parse HEAD)
    NEW_HEAD_SHORT=$(git rev-parse --short HEAD)
    log_info "New fork HEAD: $NEW_HEAD_SHORT"
}

# Update addon config
update_addon_config() {
    log_info "Updating addon configuration..."

    cd "$ADDON_DIR"

    # Get current and new version
    CURRENT_VERSION=$(grep -oP 'version: "\K[^"]+' openclaw/config.yaml)

    # Parse version: MAJOR.MINOR.PATCH
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
    NEW_PATCH=$((PATCH + 1))
    NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"

    log_info "Bumping version: $CURRENT_VERSION -> $NEW_VERSION"

    # Update config.yaml
    sed -i "s/version: \"$CURRENT_VERSION\"/version: \"$NEW_VERSION\"/" openclaw/config.yaml

    # Check if build.yaml uses SHA ref (need to update if so)
    BUILD_REF=$(grep -oP 'OPENCLAW_REF: "\K[^"]+' openclaw/build.yaml)
    if [[ "$BUILD_REF" =~ ^[0-9a-f]{7,40}$ ]]; then
        log_info "build.yaml uses SHA ref, updating to new HEAD..."
        NEW_HEAD_SHORT=$(cd "$FORK_DIR" && git rev-parse --short HEAD)
        sed -i "s/OPENCLAW_REF: \"$BUILD_REF\"/OPENCLAW_REF: \"$NEW_HEAD_SHORT\"/" openclaw/build.yaml
        log_info "Updated OPENCLAW_REF: $BUILD_REF -> $NEW_HEAD_SHORT"
    else
        log_info "build.yaml uses branch ref ($BUILD_REF), no update needed"
    fi

    # Update CHANGELOG.md
    log_info "Updating CHANGELOG.md..."
    UPSTREAM_SHA=$(cd "$FORK_DIR" && git rev-parse --short "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH")
    FORK_SHA=$(cd "$FORK_DIR" && git rev-parse --short HEAD)
    BEHIND=$(cd "$FORK_DIR" && git rev-list --count "HEAD..$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" 2>/dev/null || echo "0")

    CHANGELOG_ENTRY="## [$NEW_VERSION] - $(date +%Y-%m-%d)

### Changed
- Upstream sync to \`$UPSTREAM_SHA\` ($BEHIND new commits)
- Fork ref: \`$FORK_SHA\`

"

    # Prepend to changelog (after first line if it starts with ##)
    if head -1 openclaw/CHANGELOG.md | grep -q "^##"; then
        # Insert before first ## heading
        sed -i "1i\\$CHANGELOG_ENTRY" openclaw/CHANGELOG.md
    else
        # Find first ## and insert before it
        FIRST_ENTRY_LINE=$(grep -n "^##" openclaw/CHANGELOG.md | head -1 | cut -d: -f1)
        if [ -n "$FIRST_ENTRY_LINE" ]; then
            head -n $((FIRST_ENTRY_LINE - 1)) openclaw/CHANGELOG.md > /tmp/changelog_new
            echo "$CHANGELOG_ENTRY" >> /tmp/changelog_new
            tail -n +$FIRST_ENTRY_LINE openclaw/CHANGELOG.md >> /tmp/changelog_new
            mv /tmp/changelog_new openclaw/CHANGELOG.md
        fi
    fi

    log_success "Addon configuration updated"
}

# Show summary and confirm
confirm_changes() {
    echo ""
    echo "========================================="
    echo "         SUMMARY OF CHANGES"
    echo "========================================="
    echo ""

    cd "$FORK_DIR"
    FORK_SHA=$(git rev-parse --short HEAD)

    cd "$ADDON_DIR"
    NEW_VERSION=$(grep -oP 'version: "\K[^"]+' openclaw/config.yaml)

    echo "Fork:"
    echo "  - Rebased to upstream"
    echo "  - New HEAD: $FORK_SHA"
    echo ""
    echo "Addon:"
    echo "  - New version: $NEW_VERSION"
    echo ""
    echo "Files changed:"
    git status --short
    echo ""

    read -p "Push these changes? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Aborted. Changes are staged but not pushed."
        log_info "To push manually:"
        log_info "  cd $FORK_DIR && git push origin main --force-with-lease"
        log_info "  cd $ADDON_DIR && git add -A && git commit -m 'openclaw $NEW_VERSION: upstream sync' && git push"
        exit 0
    fi
}

# Push changes
push_changes() {
    log_info "Pushing changes..."

    # Push fork
    cd "$FORK_DIR"
    git push origin main --force-with-lease
    log_success "Fork pushed"

    # Commit and push addon
    cd "$ADDON_DIR"
    NEW_VERSION=$(grep -oP 'version: "\K[^"]+' openclaw/config.yaml)
    git add openclaw/config.yaml openclaw/build.yaml openclaw/CHANGELOG.md
    git commit -m "openclaw $NEW_VERSION: upstream sync"
    git push origin main
    log_success "Addon pushed"

    echo ""
    log_success "Update complete!"
    log_info "New addon version: $NEW_VERSION"
}

# Main
main() {
    echo ""
    echo "========================================="
    echo "  OpenClaw HA Addon Update Script"
    echo "========================================="
    echo ""

    check_prereqs
    get_current_state

    if [ "$BEHIND" -eq 0 ]; then
        log_success "Fork is already up to date with upstream"
        exit 0
    fi

    echo ""
    read -p "Proceed with sync? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Aborted"
        exit 0
    fi

    create_stable_tag
    sync_fork
    update_addon_config
    confirm_changes
    push_changes
}

main "$@"
