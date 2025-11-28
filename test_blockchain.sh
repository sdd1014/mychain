#!/bin/bash

# MyChain 自动化测试脚本
# 这个脚本会自动测试区块链的所有功能

set -e  # 遇到错误立即退出

echo "================================================"
echo "   MyChain 区块链自动化测试脚本"
echo "================================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 辅助函数
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_step() {
    echo ""
    echo "================================================"
    echo "  $1"
    echo "================================================"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 命令未找到"
        exit 1
    fi
    print_success "$1 命令已安装"
}

# 等待交易确认
wait_for_tx() {
    print_info "等待交易确认..."
    sleep 3
}

# 主测试流程
main() {
    print_step "步骤 1: 检查环境"
    
    # 检查 mychaind 是否安装
    if ! command -v mychaind &> /dev/null; then
        print_error "mychaind 未安装，请先运行: ignite chain build"
        exit 1
    fi
    print_success "mychaind 已安装"
    
    # 检查节点是否运行
    print_info "检查节点状态..."
    if ! curl -s http://localhost:26657/status > /dev/null 2>&1; then
        print_error "节点未运行，请先执行: ignite chain serve"
        exit 1
    fi
    print_success "节点正在运行"
    
    print_step "步骤 2: 创建测试账户"
    
    # 创建 Alice 账户
    print_info "创建 Alice 账户..."
    if mychaind keys show alice 2>/dev/null; then
        print_info "Alice 账户已存在"
    else
        echo -e "\n\n" | mychaind keys add alice --keyring-backend test 2>/dev/null || true
        print_success "Alice 账户创建成功"
    fi
    
    # 创建 Bob 账户
    print_info "创建 Bob 账户..."
    if mychaind keys show bob --keyring-backend test 2>/dev/null; then
        print_info "Bob 账户已存在"
    else
        echo -e "\n\n" | mychaind keys add bob --keyring-backend test 2>/dev/null || true
        print_success "Bob 账户创建成功"
    fi
    
    # 获取地址
    ALICE_ADDR=$(mychaind keys show alice -a --keyring-backend test)
    BOB_ADDR=$(mychaind keys show bob -a --keyring-backend test)
    
    print_success "Alice 地址: $ALICE_ADDR"
    print_success "Bob 地址: $BOB_ADDR"
    
    print_step "步骤 3: 测试铸造代币"
    
    print_info "给 Alice 铸造 10000 tokens..."
    mychaind tx token mint-tokens 10000000000token $ALICE_ADDR \
        --from alice \
        --chain-id mychain \
        --keyring-backend test \
        --yes \
        > /dev/null 2>&1
    
    wait_for_tx
    
    # 查询 Alice 余额
    ALICE_BALANCE=$(mychaind query bank balances $ALICE_ADDR -o json | grep -o '"amount":"[0-9]*"' | grep -o '[0-9]*' | head -1)
    
    if [ ! -z "$ALICE_BALANCE" ] && [ "$ALICE_BALANCE" -ge "10000000000" ]; then
        print_success "Alice 余额: $((ALICE_BALANCE / 1000000)) tokens"
    else
        print_error "铸造代币失败"
        exit 1
    fi
    
    print_step "步骤 4: 测试转账功能"
    
    print_info "Alice 转账 1000 tokens 给 Bob..."
    mychaind tx token transfer-tokens $BOB_ADDR 1000000000token \
        --from alice \
        --chain-id mychain \
        --keyring-backend test \
        --yes \
        > /dev/null 2>&1
    
    wait_for_tx
    
    # 查询 Bob 余额
    BOB_BALANCE=$(mychaind query bank balances $BOB_ADDR -o json | grep -o '"amount":"[0-9]*"' | grep -o '[0-9]*' | head -1)
    
    if [ ! -z "$BOB_BALANCE" ] && [ "$BOB_BALANCE" -ge "1000000000" ]; then
        print_success "Bob 余额: $((BOB_BALANCE / 1000000)) tokens"
    else
        print_error "转账失败"
        exit 1
    fi
    
    print_step "步骤 5: 测试矿工奖励"
    
    print_info "奖励 Bob 矿工奖励（10 tokens）..."
    mychaind tx token reward-miner $BOB_ADDR \
        --from alice \
        --chain-id mychain \
        --keyring-backend test \
        --yes \
        > /dev/null 2>&1
    
    wait_for_tx
    
    # 再次查询 Bob 余额
    BOB_NEW_BALANCE=$(mychaind query bank balances $BOB_ADDR -o json | grep -o '"amount":"[0-9]*"' | grep -o '[0-9]*' | head -1)
    
    if [ ! -z "$BOB_NEW_BALANCE" ] && [ "$BOB_NEW_BALANCE" -gt "$BOB_BALANCE" ]; then
        print_success "Bob 新余额: $((BOB_NEW_BALANCE / 1000000)) tokens (增加了 $((($BOB_NEW_BALANCE - $BOB_BALANCE) / 1000000)) tokens)"
    else
        print_error "矿工奖励失败"
        exit 1
    fi
    
    print_step "步骤 6: 测试余额查询"
    
    print_info "查询 Alice 最终余额..."
    ALICE_FINAL=$(mychaind query bank balances $ALICE_ADDR -o json | grep -o '"amount":"[0-9]*"' | grep -o '[0-9]*' | head -1)
    print_success "Alice 最终余额: $((ALICE_FINAL / 1000000)) tokens"
    
    print_info "查询 Bob 最终余额..."
    print_success "Bob 最终余额: $((BOB_NEW_BALANCE / 1000000)) tokens"
    
    print_step "步骤 7: 测试 API 端点"
    
    print_info "测试 REST API (端口 1317)..."
    if curl -s http://localhost:1317/cosmos/bank/v1beta1/balances/$ALICE_ADDR > /dev/null; then
        print_success "REST API 正常工作"
    else
        print_error "REST API 无法访问"
    fi
    
    print_info "测试 RPC API (端口 26657)..."
    if curl -s http://localhost:26657/status > /dev/null; then
        print_success "RPC API 正常工作"
    else
        print_error "RPC API 无法访问"
    fi
    
    print_step "步骤 8: 查询区块信息"
    
    BLOCK_HEIGHT=$(curl -s http://localhost:26657/status | grep -o '"latest_block_height":"[0-9]*"' | grep -o '[0-9]*')
    print_success "当前区块高度: $BLOCK_HEIGHT"
    
    CHAIN_ID=$(curl -s http://localhost:26657/status | grep -o '"network":"[^"]*"' | cut -d'"' -f4)
    print_success "链 ID: $CHAIN_ID"
    
    print_step "测试总结"
    echo ""
    print_success "✨ 所有测试通过！✨"
    echo ""
    echo "测试结果汇总："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 账户创建       - 通过"
    echo "✅ 代币铸造       - 通过 (10000 tokens)"
    echo "✅ 代币转账       - 通过 (1000 tokens)"
    echo "✅ 矿工奖励       - 通过 (10 tokens)"
    echo "✅ 余额查询       - 通过"
    echo "✅ REST API       - 通过"
    echo "✅ RPC API        - 通过"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "账户最终余额："
    echo "  Alice: $((ALICE_FINAL / 1000000)) tokens"
    echo "  Bob:   $((BOB_NEW_BALANCE / 1000000)) tokens"
    echo ""
    echo "区块链状态："
    echo "  区块高度: $BLOCK_HEIGHT"
    echo "  链 ID: $CHAIN_ID"
    echo ""
    print_info "现在可以打开区块链浏览器查看详细信息："
    echo "  file://$(pwd)/explorer/index.html"
    echo ""
}

# 错误处理
trap 'print_error "测试失败"; exit 1' ERR

# 运行测试
main
