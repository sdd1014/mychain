#!/bin/bash

# MyChain 快速启动脚本

echo "🚀 启动 MyChain 区块链..."
echo ""

# 检查是否已经有实例在运行
if lsof -Pi :26657 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  检测到区块链节点已在运行"
    echo ""
    read -p "是否要停止现有节点并重新启动？(y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "停止现有节点..."
        pkill -f mychaind || true
        sleep 2
    else
        echo "使用现有节点"
        echo ""
        echo "📊 区块链状态："
        curl -s http://localhost:26657/status | grep -o '"latest_block_height":"[0-9]*"' | cut -d'"' -f4 | awk '{print "   区块高度: " $0}'
        echo ""
        echo "🌐 访问区块链浏览器："
        echo "   file://$(pwd)/explorer/index.html"
        echo ""
        exit 0
    fi
fi

echo "📦 构建区块链..."
ignite chain build

echo ""
echo "✨ 启动区块链节点..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  区块链浏览器："
echo "    file://$(pwd)/explorer/index.html"
echo ""
echo "  或启动 HTTP 服务器："
echo "    cd explorer && python3 -m http.server 8080"
echo ""
echo "  REST API: http://localhost:1317"
echo "  RPC API:  http://localhost:26657"
echo ""
echo "  按 Ctrl+C 停止区块链"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 启动区块链
ignite chain serve
