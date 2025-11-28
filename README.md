# MyChain 区块链项目

这是一个基于 Cosmos SDK 开发的完整区块链应用，实现了代币生产、用户管理、代币转账、矿工奖励和区块链浏览器功能。

## 功能特性

### 1. 代币生产 (Token Minting)
- 支持铸造新代币到指定地址
- 使用 `mint-tokens` 消息类型
- 代币从模块账户铸造并发送到接收地址

### 2. 用户管理 (User Management)
- 支持创建新用户账户
- 使用 Cosmos SDK 标准账户系统
- 支持助记词恢复账户

### 3. 代币转账 (Token Transfer)
- 账户间代币转账功能
- 使用 `transfer-tokens` 消息类型
- 自动验证余额和地址有效性

### 4. 矿工奖励 (Miner Rewards)
- 区块奖励机制
- 每次奖励固定 10 tokens
- 使用 `reward-miner` 消息类型

### 5. 区块链浏览器 (Blockchain Explorer)
- 实时显示区块高度和链状态
- 查看最新区块信息
- 查询账户余额
- 友好的 Web 界面

## 快速开始

```bash
ignite chain serve
```

这个命令会编译、初始化并启动你的区块链开发环境。

## 访问区块链浏览器

启动区块链后，在浏览器中打开：

```
file:///Users/dany/web3/homework/mychain/explorer/index.html
```

或使用简单的 HTTP 服务器：

```bash
cd explorer
python3 -m http.server 8080
# 然后访问 http://localhost:8080
```

## 使用示例

### 1. 创建新账户

```bash
# 创建账户
mychaind keys add alice
mychaind keys add bob
```

### 2. 铸造代币

```bash
# 获取地址
ALICE_ADDR=$(mychaind keys show alice -a)

# 铸造代币
mychaind tx token mint-tokens 10000000000token $ALICE_ADDR --from alice --chain-id mychain --yes
```

### 3. 转账代币

```bash
BOB_ADDR=$(mychaind keys show bob -a)
mychaind tx token transfer-tokens $BOB_ADDR 1000000000token --from alice --chain-id mychain --yes
```

### 4. 查询余额

```bash
mychaind query bank balances $ALICE_ADDR
```

### 5. 奖励矿工

```bash
mychaind tx token reward-miner $BOB_ADDR --from alice --chain-id mychain --yes
```

## API 端点

### REST API (端口 1317)
- 查询余额：`GET /cosmos/bank/v1beta1/balances/{address}`
- 查询 Token 参数：`GET /mychain/token/v1/params`
- 查询特定地址余额：`GET /mychain/token/v1/balance/{address}`

### RPC API (端口 26657)
- 节点状态：`GET /status`
- 查询区块：`GET /block?height={height}`
- 最新区块：`GET /blockchain`

## 常见问题

**Q: 启动失败怎么办？**  
A: 尝试 `ignite chain serve --reset-once`

**Q: 交易失败显示余额不足？**  
A: 先铸造代币到账户

**Q: 浏览器无法连接到节点？**  
A: 确保区块链节点正在运行，API 在端口 1317，RPC 在端口 26657

## Learn more

- [Ignite CLI](https://ignite.com/cli)
- [Tutorials](https://docs.ignite.com/guide)
- [Ignite CLI docs](https://docs.ignite.com)
- [Cosmos SDK docs](https://docs.cosmos.network)
- [Developer Chat](https://discord.com/invite/ignitecli)
