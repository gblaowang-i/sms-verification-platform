#!/bin/bash

# 设置错误时退出
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检查是否为root用户
check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "检测到root用户运行，建议使用普通用户"
    fi
}

# 检查sudo权限
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_error "需要sudo权限，请确保当前用户有sudo权限"
        log_info "请运行: sudo usermod -aG sudo \$USER"
        exit 1
    fi
    log_success "sudo权限检查通过"
}

# 检查并修复文件权限
fix_permissions() {
    log_info "检查并修复文件权限..."
    
    # 确保脚本有执行权限
    if [ ! -x "$0" ]; then
        log_warning "脚本缺少执行权限，正在修复..."
        chmod +x "$0"
    fi
    
    # 修复项目目录权限
    PROJECT_DIR="$(dirname "$0")/.."
    if [ -d "$PROJECT_DIR" ]; then
        log_info "修复项目目录权限: $PROJECT_DIR"
        sudo chown -R $USER:$USER "$PROJECT_DIR"
        chmod -R 755 "$PROJECT_DIR"
        
        # 确保node_modules权限正确
        if [ -d "$PROJECT_DIR/node_modules" ]; then
            chmod -R 755 "$PROJECT_DIR/node_modules"
        fi
    fi
    
    log_success "权限修复完成"
}

# 检查系统依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    # 检查curl
    if ! command -v curl &> /dev/null; then
        log_info "安装curl..."
        sudo apt-get update
        sudo apt-get install -y curl
    fi
    
    # 检查git
    if ! command -v git &> /dev/null; then
        log_info "安装git..."
        sudo apt-get install -y git
    fi
    
    log_success "系统依赖检查完成"
}

# 安装Node.js
install_nodejs() {
    if ! command -v node &> /dev/null; then
        log_info "安装Node.js..."
        
        # 添加NodeSource仓库
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        
        # 安装Node.js
        sudo apt-get install -y nodejs
        
        # 验证安装
        if command -v node &> /dev/null; then
            log_success "Node.js安装成功: $(node --version)"
        else
            log_error "Node.js安装失败"
            exit 1
        fi
    else
        log_success "Node.js已安装: $(node --version)"
    fi
    
    # 检查npm
    if ! command -v npm &> /dev/null; then
        log_error "npm未安装，请检查Node.js安装"
        exit 1
    else
        log_success "npm已安装: $(npm --version)"
    fi
}

# 安装PM2
install_pm2() {
    if ! command -v pm2 &> /dev/null; then
        log_info "安装PM2..."
        sudo npm install -g pm2
        
        # 验证安装
        if command -v pm2 &> /dev/null; then
            log_success "PM2安装成功: $(pm2 --version)"
        else
            log_error "PM2安装失败"
            exit 1
        fi
    else
        log_success "PM2已安装: $(pm2 --version)"
    fi
}

# 安装项目依赖
install_dependencies() {
    log_info "安装项目依赖..."
    
    PROJECT_DIR="$(dirname "$0")/.."
    cd "$PROJECT_DIR"
    
    # 清理旧的node_modules（如果存在）
    if [ -d "node_modules" ]; then
        log_info "清理旧的依赖..."
        rm -rf node_modules
    fi
    
    # 安装依赖
    npm install
    
    if [ $? -eq 0 ]; then
        log_success "依赖安装完成"
    else
        log_error "依赖安装失败"
        exit 1
    fi
}

# 构建项目
build_project() {
    log_info "构建Vue应用..."
    
    PROJECT_DIR="$(dirname "$0")/.."
    cd "$PROJECT_DIR"
    
    # 清理旧的构建文件
    if [ -d "dist" ]; then
        log_info "清理旧的构建文件..."
        rm -rf dist
    fi
    
    # 构建项目
    npm run build
    
    # 检查构建是否成功
    if [ ! -d "dist" ]; then
        log_error "构建失败，dist目录不存在"
        log_info "当前目录: $(pwd)"
        log_info "目录内容:"
        ls -la
        exit 1
    fi
    
    log_success "构建完成！"
}

# 启动应用
start_application() {
    log_info "启动应用..."
    
    PROJECT_DIR="$(dirname "$0")/.."
    cd "$PROJECT_DIR"
    
    # 停止已存在的应用
    if pm2 list | grep -q "sms-verification"; then
        log_info "停止已存在的应用..."
        pm2 stop sms-verification 2>/dev/null || true
        pm2 delete sms-verification 2>/dev/null || true
    fi
    
    # 启动应用
    pm2 start server.js --name "sms-verification"
    
    # 保存PM2配置
    pm2 save
    
    # 设置开机自启
    pm2 startup
    
    log_success "应用启动完成"
}

# 验证部署
verify_deployment() {
    log_info "验证部署..."
    
    # 检查PM2进程
    if pm2 list | grep -q "sms-verification"; then
        log_success "PM2进程运行正常"
    else
        log_error "PM2进程未运行"
        exit 1
    fi
    
    # 检查端口
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
    
    # 执行部署步骤
    check_root
    check_sudo
    fix_permissions
    check_dependencies
    install_nodejs
    install_pm2
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