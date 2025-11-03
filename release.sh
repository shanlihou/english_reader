#!/bin/bash

# 🚀 快速发布脚本
# 用于创建版本标签并触发GitHub Actions自动构建APK

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查Git状态
check_git_status() {
    print_info "检查Git状态..."
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "工作目录有未提交的更改"
        git status
        read -p "是否继续？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "已取消发布"
            exit 1
        fi
    fi
    print_success "Git状态检查通过"
}

# 获取版本号
get_version() {
    echo
    print_info "当前pubspec.yaml中的版本号："
    grep "version:" pubspec.yaml || echo "未找到版本信息"

    echo
    read -p "请输入新版本号 (格式: x.y.z 例如: 1.0.0): " version

    # 验证版本号格式
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "版本号格式不正确！请使用 x.y.z 格式"
        exit 1
    fi

    print_success "版本号: $version"
}

# 更新版本号
update_version() {
    print_info "更新pubspec.yaml中的版本号..."
    sed -i.bak "s/version: .*/version: $version+1/" pubspec.yaml
    rm pubspec.yaml.bak
    print_success "版本号已更新为 $version+1"
}

# 提交更改
commit_changes() {
    print_info "提交更改..."
    git add pubspec.yaml
    git commit -m "chore: 版本升级到 $version"
    print_success "更改已提交"
}

# 创建标签
create_tag() {
    print_info "创建标签 v$version..."
    git tag "v$version"
    print_success "标签 v$version 已创建"
}

# 推送到远程
push_changes() {
    print_info "推送到远程仓库..."
    git push origin main
    print_success "已推送到 main 分支"
}

# 推送标签
push_tag() {
    print_info "推送标签..."
    git push origin "v$version"
    print_success "标签 v$version 已推送"
}

# 显示后续步骤
show_next_steps() {
    echo
    echo "════════════════════════════════════════════════════════════"
    print_success "发布流程完成！"
    echo "════════════════════════════════════════════════════════════"
    echo
    print_info "后续步骤："
    echo "1. GitHub Actions 将自动开始构建（约5-10分钟）"
    echo "2. 构建完成后，APK将上传到GitHub Releases"
    echo "3. 你可以在以下链接查看构建进度："
    echo "   https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\([^.]*\)\.\([^/]*\)\/.*/\1\/\2/')/actions"
    echo
    print_info "APK下载链接（构建完成后）："
    echo "https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\([^.]*\)\.\([^/]*\)\/.*/\1\/\2/')/releases/tag/v$version"
    echo
}

# 主流程
main() {
    echo
    echo "════════════════════════════════════════════════════════════"
    echo "🚀           欢迎使用快速发布脚本"
    echo "════════════════════════════════════════════════════════════"
    echo

    check_git_status
    get_version

    echo
    print_info "准备发布版本 v$version"
    echo

    read -p "确认发布？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "已取消发布"
        exit 1
    fi

    echo
    print_info "开始发布流程..."
    echo

    update_version
    commit_changes
    create_tag
    push_changes
    push_tag

    show_next_steps
}

# 运行主流程
main "$@"
