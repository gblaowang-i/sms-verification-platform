#!/bin/bash

# 设置错误时退出
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
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

# 分隔线
print_separator() {
    echo "=========================================="
}

# 检测并安装环境
setup_environment() {
    log_info "检测并安装运行环境..."
    
    # 检测并安装curl
    if ! command -v curl &> /dev/null; then
        log_info "安装curl..."
        sudo apt-get update
        sudo apt-get install -y curl
    fi
    
    # 检测并安装git
    if ! command -v git &> /dev/null; then
        log_info "安装git..."
        sudo apt-get install -y git
    fi
    
    # 检测并安装Node.js
    if ! command -v node &> /dev/null; then
        log_info "安装Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        log_success "Node.js安装完成: $(node --version)"
    else
        log_success "Node.js已安装: $(node --version)"
    fi
    
    # 检测并安装npm
    if ! command -v npm &> /dev/null; then
        log_error "npm未安装，请检查Node.js安装"
        exit 1
    else
        log_success "npm已安装: $(npm --version)"
    fi
    
    # 检测并安装PM2
    if ! command -v pm2 &> /dev/null; then
        log_info "安装PM2..."
        sudo npm install -g pm2
        log_success "PM2安装完成: $(pm2 --version)"
    else
        log_success "PM2已安装: $(pm2 --version)"
    fi
}

# 修复权限
fix_permissions() {
    log_info "修复文件权限..."
    
    PROJECT_DIR="$(dirname "$0")/.."
    DEPLOY_DIR="$(dirname "$0")"
    
    # 修复项目目录权限
    sudo chown -R $USER:$USER "$PROJECT_DIR"
    find "$PROJECT_DIR" -type d -exec chmod 755 {} \;
    find "$PROJECT_DIR" -type f -exec chmod 644 {} \;
    find "$PROJECT_DIR" -name "*.sh" -exec chmod +x {} \;
    
    # 修复deploy目录权限
    sudo chown -R $USER:$USER "$DEPLOY_DIR"
    chmod -R 755 "$DEPLOY_DIR"
    
    # 修复node_modules权限（如果存在）
    if [ -d "$PROJECT_DIR/node_modules" ]; then
        chmod -R 755 "$PROJECT_DIR/node_modules"
    fi
    
    # 修复PM2目录权限
    PM2_HOME="$HOME/.pm2"
    if [ -d "$PM2_HOME" ]; then
        chmod -R 755 "$PM2_HOME"
    fi
    
    log_success "权限修复完成"
}

# 获取项目根目录
get_project_dir() {
    echo "$(dirname "$0")/.."
}

# 安装依赖
install_dependencies() {
    log_info "安装项目依赖..."
    
    PROJECT_DIR=$(get_project_dir)
    cd "$PROJECT_DIR"
    
    log_info "当前工作目录: $(pwd)"
    
    # 检查package.json是否存在
    if [ ! -f "package.json" ]; then
        log_error "package.json不存在，当前目录: $(pwd)"
        log_error "请确保在正确的项目目录中运行脚本"
        exit 1
    fi
    
    # 清理旧的依赖
    if [ -d "node_modules" ]; then
        log_info "清理旧的依赖..."
        rm -rf node_modules
    fi
    
    npm install
    log_success "依赖安装完成"
}

# 构建项目
build_project() {
    log_info "构建Vue应用..."
    
    PROJECT_DIR=$(get_project_dir)
    cd "$PROJECT_DIR"
    
    log_info "当前工作目录: $(pwd)"
    
    # 检查package.json是否存在
    if [ ! -f "package.json" ]; then
        log_error "package.json不存在，当前目录: $(pwd)"
        log_error "请确保在正确的项目目录中运行脚本"
        exit 1
    fi
    
    # 清理旧的构建文件
    if [ -d "dist" ]; then
        log_info "清理旧的构建文件..."
        rm -rf dist
    fi
    
    npm run build
    
    if [ ! -d "dist" ]; then
        log_error "构建失败，dist目录不存在"
        exit 1
    fi
    
    log_success "构建完成"
}

# 启动应用
start_application() {
    log_info "启动应用..."
    
    PROJECT_DIR=$(get_project_dir)
    cd "$PROJECT_DIR"
    
    log_info "当前工作目录: $(pwd)"
    
    # 检查server.js是否存在
    if [ ! -f "server.js" ]; then
        log_error "server.js不存在，当前目录: $(pwd)"
        log_error "请确保在正确的项目目录中运行脚本"
        exit 1
    fi
    
    # 停止已存在的应用
    if pm2 list | grep -q "sms-verification"; then
        log_info "停止已存在的应用..."
        pm2 stop sms-verification 2>/dev/null || true
        pm2 delete sms-verification 2>/dev/null || true
    fi
    
    # 启动应用
    pm2 start server.js --name "sms-verification"
    pm2 save
    pm2 startup | tail -n 1 | bash
    
    log_success "应用启动完成"
}

# 验证部署
verify_deployment() {
    log_info "验证部署..."
    
    if pm2 list | grep -q "sms-verification"; then
        log_success "PM2进程运行正常"
    else
        log_error "PM2进程未运行"
        exit 1
    fi
    
    sleep 3
    if netstat -tulpn 2>/dev/null | grep -q ":3000"; then
        log_success "应用端口3000正常监听"
    else
        log_warning "端口3000可能未正常监听，请检查日志"
    fi
}

# 显示部署信息
show_deployment_info() {
    print_separator
    log_success "🎉 部署完成！"
    print_separator
    echo "📱 应用名称: sms-verification"
    echo "🌐 访问地址: http://$(hostname -I | awk '{print $1}'):3000"
    echo "📁 项目目录: $(dirname "$0")/.."
    echo ""
    echo "📋 常用命令："
    echo "  pm2 status                    # 查看应用状态"
    echo "  pm2 logs sms-verification    # 查看日志"
    echo "  pm2 restart sms-verification # 重启应用"
    echo "  pm2 stop sms-verification    # 停止应用"
    echo "  pm2 delete sms-verification  # 删除应用"
    echo "  pm2 monit                    # 监控面板"
    print_separator
}

# 主函数
main() {
    print_separator
    log_info "🚀 开始部署短信验证码接收平台到Linux服务器..."
    print_separator
    
    setup_environment
    fix_permissions
    install_dependencies
    build_project
    start_application
    verify_deployment
    show_deployment_info
}

# 错误处理
trap 'log_error "部署过程中发生错误，请检查日志"; exit 1' ERR

# 执行主函数
main "$@" 