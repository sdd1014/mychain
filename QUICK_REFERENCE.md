# MyChain 快速参考卡片

## 🚀 快速启动

```bash
cd /Users/dany/web3/homework/mychain
./start.sh
```

## 🌐 访问地址

- **区块链浏览器**: `file:///Users/dany/web3/homework/mychain/explorer/index.html`
- **REST API**: http://localhost:1317
- **RPC API**: http://localhost:26657

## 📝 常用命令

### 账户管理
```bash
# 创建账户
mychaind keys add alice

# 查看地址
mychaind keys show alice -a

# 查看所有账户
mychaind keys list
```

### 代币操作
```bash
# 铸造代币
mychaind tx token mint-tokens 10000000000token [地址] \
  --from alice --chain-id mychain --yes

# 转账
mychaind tx token transfer-tokens [接收地址] 1000000000token \
  --from alice --chain-id mychain --yes

# 奖励矿工
mychaind tx token reward-miner [矿工地址] \
  --from alice --chain-id mychain --yes
```

### 查询
```bash
# 查询余额
mychaind query bank balances [地址]

# 查询节点状态
mychaind status

# 查询区块
mychaind query block [高度]
```

## 🧪 测试

```bash
./test_blockchain.sh
```

## 📚 文档

- `README.md` - 项目说明
- `USAGE_GUIDE.md` - 详细使用指南
- `PROJECT_OVERVIEW.md` - 项目概览

## 💡 快速测试流程

```bash
# 1. 创建账户
mychaind keys add alice
mychaind keys add bob

# 2. 获取地址
ALICE=$(mychaind keys show alice -a)
BOB=$(mychaind keys show bob -a)

# 3. 铸造代币
mychaind tx token mint-tokens 10000000000token $ALICE \
  --from alice --chain-id mychain --yes

# 4. 转账
mychaind tx token transfer-tokens $BOB 1000000000token \
  --from alice --chain-id mychain --yes

# 5. 奖励矿工
mychaind tx token reward-miner $BOB \
  --from alice --chain-id mychain --yes

# 6. 查询余额
mychaind query bank balances $BOB
```

## 🎯 功能清单

- ✅ 代币铸造（Mint）
- ✅ 代币转账（Transfer）
- ✅ 矿工奖励（Reward）
- ✅ 用户创建（Keys）
- ✅ 余额查询（Balance）
- ✅ 区块浏览器（Explorer）

## 🔗 重要端点

### REST API
- 余额查询: `/cosmos/bank/v1beta1/balances/{address}`
- Token 参数: `/mychain/token/v1/params`
- 节点信息: `/cosmos/base/tendermint/v1beta1/node_info`

### RPC API  
- 状态: `/status`
- 区块: `/block?height={h}`
- 交易: `/tx?hash={hash}`

## ⚡ 故障排除

### 节点未启动
```bash
ignite chain serve --reset-once
```

### 余额不足
```bash
# 先铸造代币
mychaind tx token mint-tokens 10000000000token [地址] \
  --from alice --chain-id mychain --yes
```

### 端口占用
```bash
pkill -f mychaind
./start.sh
```

## 📊 代币单位

- 1 token = 1,000,000 基本单位
- 铸造 10000 tokens = 10000000000 基本单位
- 转账 1000 tokens = 1000000000 基本单位
- 矿工奖励 = 10 tokens (10000000 基本单位)

---

**项目位置**: `/Users/dany/web3/homework/mychain`  
**框架**: Cosmos SDK v0.53.4  
**工具**: Ignite CLI
