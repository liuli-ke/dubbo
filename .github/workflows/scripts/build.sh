#!/bin/bash

echo "==> 执行脚本 $0 ——> 当前目录: $(pwd)"

# 可配置参数
VERSION=${1:-"2.8.2"}  # 可以通过命令行参数传入版本号，默认2.8.4
TAR_FILE="dubbox-${VERSION}.tar.gz"
SOURCE_DIR="dubbox-dubbox-${VERSION}"
WAR_FILE="dubbo-admin-${VERSION}.war"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "命令 $1 不存在，请先安装"
        exit 1
    fi
}

# 清理函数
cleanup() {
    print_info "清理临时文件..."
    rm -f "${TAR_FILE}"
    rm -rf "${SOURCE_DIR}"
}

# 设置错误处理
set -e
trap cleanup EXIT
trap 'print_error "脚本执行失败，退出码: $?"' ERR

# 检查必要命令
check_command docker
check_command curl

# 1. 下载源代码
print_info "下载 Dubbox ${VERSION} 源代码..."
if [ ! -f "${TAR_FILE}" ]; then
    # wget "https://github.com/dangdangdotcom/dubbox/archive/refs/tags/dubbox-${VERSION}.tar.gz" -O "${TAR_FILE}"
    curl -L "https://github.com/dangdangdotcom/dubbox/archive/refs/tags/dubbox-${VERSION}.tar.gz" -o "${TAR_FILE}"
    
    # 检查下载是否成功
    if [ $? -ne 0 ]; then
        print_error "下载失败，请检查网络连接和版本号是否正确"
        exit 1
    fi
else
    print_warn "文件 ${TAR_FILE} 已存在，跳过下载"
fi

# 2. 解压源代码
print_info "解压源代码..."
if [ ! -d "${SOURCE_DIR}" ]; then
    tar -xzf "${TAR_FILE}"
else
    print_warn "目录 ${SOURCE_DIR} 已存在，跳过解压"
fi

# 3. 使用 Maven 构建
print_info "使用 Maven 构建项目..."
docker run --rm --name dubbo-build \
    -v "$(pwd)/${SOURCE_DIR}:/opt/dubbo" \
    -w /opt/dubbo \
    maven:3.6.3-jdk-8 \
    mvn clean install -DskipTests

# 4. 检查构建结果
WAR_PATH="${SOURCE_DIR}/dubbo-admin/target/${WAR_FILE}"
if [ ! -f "${WAR_PATH}" ]; then
    print_error "构建失败，未找到 WAR 文件: ${WAR_PATH}"
    exit 1
fi

print_info "构建成功，WAR 文件: ${WAR_PATH}"
