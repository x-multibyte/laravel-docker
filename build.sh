#!/bin/bash

# 构建 Docker 镜像脚本

set -e

echo "开始构建 Docker 镜像..."
make build
echo "构建完成!"
