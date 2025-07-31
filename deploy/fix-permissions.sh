#!/bin/bash

# 权限修复辅助脚本
# 用于手动修复部署过程中的权限问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "=========================================="
echo "🔧 权限修复工具"
echo "=========================================="

# 获取项目目录
PROJECT_DIR="$(dirname "$0")/.."
DEPLOY_DIR="$(dirname "$0")"

log_info "项目目录: $PROJECT_DIR"
log_info "部署目录: $DEPLOY_DIR"

# 1. 修复项目目录权限
log_info "1. 修复项目目录权限..."
sudo chown -R $USER:$USER "$PROJECT_DIR"
find "$PROJECT_DIR" -type d -exec chmod 755 {} \;
find "$PROJECT_DIR" -type f -exec chmod 644 {} \;
find "$PROJECT_DIR" -name "*.sh" -exec chmod +x {} \;

# 2. 修复deploy目录权限
log_info "2. 修复deploy目录权限..."
sudo chown -R $USER:$USER "$DEPLOY_DIR"
chmod -R 755 "$DEPLOY_DIR"

# 3. 修复node_modules权限
if [ -d "$PROJECT_DIR/node_modules" ]; then
    log_info "3. 修复node_modules权限..."
    chmod -R 755 "$PROJECT_DIR/node_modules"
fi

# 4. 修复npm缓存权限
log_info "4. 修复npm缓存权限..."
NPM_CACHE_DIR=$(npm config get cache 2>/dev/null || echo "$HOME/.npm")
if [ -d "$NPM_CACHE_DIR" ]; then
    sudo chown -R $USER:$USER "$NPM_CACHE_DIR"
fi

# 5. 修复PM2目录权限
log_info "5. 修复PM2目录权限..."
PM2_HOME="$HOME/.pm2"
if [ -d "$PM2_HOME" ]; then
    chmod -R 755 "$PM2_HOME"
fi

# 6. 修复全局npm目录权限
log_info "6. 修复全局npm目录权限..."
NPM_GLOBAL_DIR=$(npm config get prefix 2>/dev/null || echo "/usr/local")
if [ -d "$NPM_GLOBAL_DIR/lib/node_modules" ]; then
    sudo chown -R $USER:$USER "$NPM_GLOBAL_DIR/lib/node_modules"
fi

# 7. 确保脚本有执行权限
log_info "7. 确保脚本有执行权限..."
chmod +x "$0"
chmod +x "$DEPLOY_DIR/deploy.sh"

log_success "权限修复完成！"
echo ""
echo "📋 修复内容："
echo "  ✅ 项目目录权限"
echo "  ✅ deploy目录权限"
echo "  ✅ node_modules权限"
echo "  ✅ npm缓存权限"
echo "  ✅ PM2目录权限"
echo "  ✅ 全局npm目录权限"
echo "  ✅ 脚本执行权限"
echo ""
echo "🚀 现在可以重新运行部署脚本："
echo "  ./deploy.sh" 