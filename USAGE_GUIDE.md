# MyChain 区块链完整使用指南

## 项目概述

MyChain 是基于 Cosmos SDK v0.53 开发的区块链应用，包含以下核心功能：

1. ✅ **代币生产**：铸造新代币到指定地址
2. ✅ **用户管理**：创建和管理区块链账户
3. ✅ **代币转账**：账户间转移代币
4. ✅ **矿工奖励**：区块奖励机制（每次 10 tokens）
5. ✅ **区块链浏览器**：Web 界面查看链状态和区块信息

## 第一步：启动区块链

在项目根目录执行：

```bash
cd /Users/dany/web3/homework/mychain/mychain
ignite chain serve
```

启动成功后，你会看到：
- ✅ 区块链节点运行在 26657 端口（RPC）
- ✅ REST API 运行在 1317 端口
- ✅ 自动创建的测试账户（alice, bob 等）

**重要**：保持终端窗口运行，不要关闭！

## 第二步：打开区块链浏览器

### 方法 1：直接打开 HTML 文件

在浏览器地址栏输入：
```
file:///Users/dany/web3/homework/mychain/explorer/index.html
```

### 方法 2：使用 HTTP 服务器（推荐）

打开新终端窗口：

```bash
cd /Users/dany/web3/homework/mychain/explorer
python3 -m http.server 8080
```

然后在浏览器访问：`http://localhost:8080`

## 第三步：创建用户账户

### 在浏览器中创建

1. 打开区块链浏览器
2. 点击"创建账户"按钮
3. **重要**：复制并保存显示的 24 个单词助记词
4. 在终端导入账户：

```bash
mychaind keys add myaccount --recover
# 粘贴助记词并按回车
# 输入加密密码（至少 8 个字符）
```

### 使用命令行直接创建

```bash
# 创建新账户（会自动生成助记词）
mychaind keys add alice

# 查看账户地址
mychaind keys show alice -a

# 查看所有账户
mychaind keys list
```

## 第四步：代币操作

### 1. 铸造代币（Mint Tokens）

给账户铸造初始代币：

```bash
# 获取账户地址
ALICE_ADDR=$(mychaind keys show alice -a)

# 铸造 10000 tokens（注意：1 token = 1,000,000 基本单位）
mychaind tx token mint-tokens 10000000000token $ALICE_ADDR \
  --from alice \
  --chain-id mychain \
  --yes

# 等待几秒后查询余额
mychaind query bank balances $ALICE_ADDR
```

**预期输出**：
```yaml
balances:
- amount: "10000000000"
  denom: token
pagination:
  total: "1"
```

### 2. 转账代币（Transfer Tokens）

从一个账户转账到另一个账户：

```bash
# 创建第二个账户
mychaind keys add bob

# 获取 Bob 的地址
BOB_ADDR=$(mychaind keys show bob -a)

# Alice 转 1000 tokens 给 Bob
mychaind tx token transfer-tokens $BOB_ADDR 1000000000token \
  --from alice \
  --chain-id mychain \
  --yes

# 查询 Bob 的余额
mychaind query bank balances $BOB_ADDR
```

### 3. 奖励矿工（Reward Miner）

模拟区块挖矿奖励：

```bash
# 奖励 Bob 作为矿工（固定奖励 10 tokens）
mychaind tx token reward-miner $BOB_ADDR \
  --from alice \
  --chain-id mychain \
  --yes

# 再次查询 Bob 余额，应该增加了 10 tokens
mychaind query bank balances $BOB_ADDR
```

## 第五步：使用区块链浏览器

浏览器提供以下功能：

### 实时统计面板
- **当前区块高度**：实时显示最新区块编号
- **节点状态**：显示 ✅ 在线 或 ❌ 离线
- **链 ID**：显示区块链网络标识符

### 用户操作
1. **生成新账户**：点击按钮生成助记词
2. **查询余额**：输入地址查看账户余额

### 代币操作
所有操作都会显示对应的命令行指令：
- 铸造代币
- 转账代币
- 奖励矿工

### 区块浏览
- 显示最新 10 个区块
- 每个区块显示：
  - 区块高度
  - 区块哈希
  - 创建时间
  - 提议者地址
  - 交易数量
- 自动每 10 秒刷新

## 完整测试流程

按顺序执行以下命令，完成一个完整的测试周期：

```bash
# 1. 确保区块链正在运行
# 如果没有运行，执行：ignite chain serve

# 2. 创建两个测试账户
mychaind keys add alice 2>/dev/null || echo "alice already exists"
mychaind keys add bob 2>/dev/null || echo "bob already exists"

# 3. 获取地址
ALICE_ADDR=$(mychaind keys show alice -a)
BOB_ADDR=$(mychaind keys show bob -a)

echo "Alice 地址: $ALICE_ADDR"
echo "Bob 地址: $BOB_ADDR"

# 4. 给 Alice 铸造 10000 tokens
echo "\n=== 铸造代币 ==="
mychaind tx token mint-tokens 10000000000token $ALICE_ADDR \
  --from alice \
  --chain-id mychain \
  --yes

sleep 3

# 5. 查询 Alice 余额
echo "\n=== Alice 初始余额 ==="
mychaind query bank balances $ALICE_ADDR

# 6. Alice 转账 1000 tokens 给 Bob
echo "\n=== 转账给 Bob ==="
mychaind tx token transfer-tokens $BOB_ADDR 1000000000token \
  --from alice \
  --chain-id mychain \
  --yes

sleep 3

# 7. 查询 Bob 余额
echo "\n=== Bob 转账后余额 ==="
mychaind query bank balances $BOB_ADDR

# 8. 奖励 Bob 10 tokens
echo "\n=== 奖励矿工 ==="
mychaind tx token reward-miner $BOB_ADDR \
  --from alice \
  --chain-id mychain \
  --yes

sleep 3

# 9. 再次查询 Bob 余额
echo "\n=== Bob 获得奖励后余额 ==="
mychaind query bank balances $BOB_ADDR

# 10. 查询 Alice 最终余额
echo "\n=== Alice 最终余额 ==="
mychaind query bank balances $ALICE_ADDR
```

### 预期结果

执行上述测试后：

- **Alice**：
  - 初始：10000 tokens
  - 转出：1000 tokens
  - 最终：9000 tokens

- **Bob**：
  - 初始：0 tokens
  - 收到转账：1000 tokens
  - 收到矿工奖励：10 tokens
  - 最终：1010 tokens

## 常见命令参考

### 账户管理

```bash
# 创建账户
mychaind keys add [账户名]

# 恢复账户（使用助记词）
mychaind keys add [账户名] --recover

# 查看账户地址
mychaind keys show [账户名] -a

# 查看账户详细信息
mychaind keys show [账户名]

# 列出所有账户
mychaind keys list

# 删除账户
mychaind keys delete [账户名]

# 导出私钥
mychaind keys export [账户名]
```

### 余额查询

```bash
# 查询指定地址的所有余额
mychaind query bank balances [地址]

# 查询指定代币余额
mychaind query bank balance [地址] token

# 使用 REST API 查询
curl http://localhost:1317/cosmos/bank/v1beta1/balances/[地址]
```

### 交易操作

```bash
# 铸造代币
mychaind tx token mint-tokens [数量] [接收地址] \
  --from [发送者] \
  --chain-id mychain \
  --yes

# 转账代币
mychaind tx token transfer-tokens [接收地址] [数量] \
  --from [发送者] \
  --chain-id mychain \
  --yes

# 奖励矿工
mychaind tx token reward-miner [矿工地址] \
  --from [发送者] \
  --chain-id mychain \
  --yes

# 查询交易
mychaind query tx [交易哈希]
```

### 区块链查询

```bash
# 查询最新区块
mychaind query block

# 查询指定高度区块
mychaind query block [高度]

# 查询节点状态
mychaind status

# 查询链信息
mychaind query bank total
```

## 故障排除

### 问题 1：启动失败

**错误**：端口已被占用

**解决方案**：
```bash
# 清理并重新启动
ignite chain serve --reset-once
```

### 问题 2：余额不足

**错误**：`insufficient funds`

**解决方案**：
```bash
# 先铸造代币到账户
mychaind tx token mint-tokens 10000000000token [地址] \
  --from [账户名] \
  --chain-id mychain \
  --yes
```

### 问题 3：账户不存在

**错误**：`account not found`

**解决方案**：
```bash
# 账户必须先接收代币才会被创建
# 给新账户铸造或转账一些代币
```

### 问题 4：浏览器无法连接

**症状**：浏览器显示"离线"或无法加载数据

**检查清单**：
1. 确认区块链节点正在运行
2. 检查 API 端口 1317 是否可访问
   ```bash
   curl http://localhost:1317/cosmos/base/tendermint/v1beta1/node_info
   ```
3. 检查 RPC 端口 26657 是否可访问
   ```bash
   curl http://localhost:26657/status
   ```

### 问题 5：交易卡住

**症状**：交易提交后一直没有确认

**解决方案**：
```bash
# 查看交易池
mychaind query txs --events 'tx.height=0'

# 如果区块链停止，重启
# Ctrl+C 停止，然后重新启动
ignite chain serve
```

## 进阶功能

### 1. 自定义配置

编辑 `config.yml` 文件：

```yaml
accounts:
  - name: alice
    coins:
      - 100000token
      - 1000000stake
  - name: bob
    coins:
      - 50000token

validator:
  name: validator
  staked: 100000000stake
```

### 2. 添加更多验证者

```bash
# 创建验证者账户
mychaind keys add validator2

# 获取验证者公钥
mychaind comet show-validator

# 创建验证者交易
mychaind tx staking create-validator \
  --amount=1000000stake \
  --pubkey=$(mychaind comet show-validator) \
  --moniker="validator2" \
  --chain-id=mychain \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --from=validator2
```

### 3. 查看日志

```bash
# 实时查看日志
tail -f ~/.mychain/mychaind.log

# 或在启动时指定日志级别
ignite chain serve --verbose
```

## API 参考

### REST API (端口 1317)

```bash
# 节点信息
GET /cosmos/base/tendermint/v1beta1/node_info

# 查询余额
GET /cosmos/bank/v1beta1/balances/{address}

# 查询总供应量
GET /cosmos/bank/v1beta1/supply

# Token 模块参数
GET /mychain/token/v1/params

# 查询特定地址余额（Token 模块）
GET /mychain/token/v1/balance/{address}
```

### RPC API (端口 26657)

```bash
# 节点状态
GET /status

# 查询区块
GET /block?height={height}

# 区块链信息
GET /blockchain?minHeight={min}&maxHeight={max}

# 交易搜索
GET /tx_search?query="tx.height={height}"
```

## 项目结构说明

```
mychain/
├── app/                       # 应用配置和初始化
│   ├── app.go                # 主应用文件
│   └── app_config.go         # 应用配置
├── cmd/                       # CLI 命令
│   └── mychaind/             # 主命令
├── explorer/                  # 区块链浏览器
│   └── index.html            # Web 界面
├── proto/                     # Protocol Buffers 定义
│   └── mychain/
│       └── token/
│           └── v1/
│               ├── tx.proto  # 交易消息定义
│               └── query.proto # 查询定义
├── x/                         # 自定义模块
│   └── token/                # Token 模块
│       ├── keeper/           # 业务逻辑层
│       │   ├── keeper.go
│       │   ├── msg_server_mint_tokens.go
│       │   ├── msg_server_transfer_tokens.go
│       │   ├── msg_server_reward_miner.go
│       │   └── query_balance.go
│       ├── types/            # 类型定义
│       │   ├── expected_keepers.go
│       │   ├── codec.go
│       │   └── keys.go
│       └── module/           # 模块配置
├── config.yml                # 链配置文件
└── README.md                 # 项目文档
```

## 下一步

1. **添加更多功能**：
   - 代币销毁（burn）
   - 代币冻结/解冻
   - 交易手续费自定义

2. **集成智能合约**：
   - 使用 CosmWasm 添加智能合约支持

3. **跨链通信**：
   - 使用 IBC 协议连接其他 Cosmos 链

4. **治理功能**：
   - 添加链上提案和投票

5. **质押功能**：
   - 实现代币质押和奖励分配

## 学习资源

- [Cosmos SDK 官方文档](https://docs.cosmos.network/)
- [Ignite CLI 文档](https://docs.ignite.com/)
- [Cosmos SDK 教程](https://tutorials.cosmos.network/)
- [Tendermint 文档](https://docs.tendermint.com/)

## 技术支持

如有问题，请参考：
1. 本文档的故障排除部分
2. Cosmos SDK 官方文档
3. Ignite CLI 社区 Discord

祝你使用愉快！🚀
