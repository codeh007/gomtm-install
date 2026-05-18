# gomtm-install

`gomtm-install` 是 gomtm 周边主机安装与 Agent bootstrap 的独立公开仓库。

gomtm 主仓应继续聚焦 runtime、server、control-plane 和数据库行为。宿主机初始化、开发机初始化、Agent 工具、VNC/browser 环境和基础镜像组装等外围安装职责，统一放在本仓维护。

## 仓库结构

```text
bin/       面向人类和 Agent 的轻量 CLI 分发入口。
scripts/   可重复执行的安装脚本、诊断脚本和共享 shell helper。
skills/    可安装的 Agent 技能入口。
tests/     覆盖命令路由、脚本语法和 dry-run 行为的 smoke 测试。
```

## 命令

```bash
bin/gomtm-install doctor
bin/gomtm-install doctor --json
bin/gomtm-install install base --dry-run
bin/gomtm-install install dev --dry-run
bin/gomtm-install install runtime-languages --dry-run
bin/gomtm-install install docker --dry-run
bin/gomtm-install install agent-tools --dry-run
bin/gomtm-install install vnc --dry-run
bin/gomtm-install remote bootstrap --dry-run user@host
```

`install dev` 会组合调用 `install base`、`install runtime-languages` 和 `install docker`，用于开发机初始化。

## 安装技能

`npx skills` 通过 git 克隆源仓库。它不提供单独的 token 参数；访问凭据需要通过标准 git 认证路径准备好。

从公开仓库列出可用技能：

```bash
npx skills add https://github.com/codeh007/gomtm-install --list
```

全局安装 canonical `gomtm-installer` 技能：

```bash
npx skills add https://github.com/codeh007/gomtm-install --skill gomtm-installer --global --yes
```

开发本仓时，可以从本地 checkout 安装：

```bash
npx skills add . --skill gomtm-installer --global --yes
```

如果运行环境需要显式 GitHub 凭据，优先让 git 本身可认证：

```bash
gh auth login --with-token
gh auth setup-git
```

自动化或只读 Agent 环境可通过环境变量提供 token：

```bash
export GH_TOKEN=...
# or: export GITHUB_TOKEN=...
npx skills add https://github.com/codeh007/gomtm-install --list
```

## Agent 入口

`skills/gomtm-installer/SKILL.md` 是本仓面向 Agent 的 canonical 入口。需要初始化 Linux 主机、准备 gomtm 开发机、安装 Agent 工具、准备 VNC/browser 环境，或判断某项安装职责是否应从 gomtm 主仓迁移时，应优先读取该技能。

## 迁移边界

本仓是新的主机安装 canonical 位置。现有 `gomtm install` 命令在迁移期继续保留在 gomtm 主仓中，用于兼容旧调用方和仍待迁移的 Dockerfile/base-image 行为。不要继续向 `gomtm/pkg/mtinstall/installers` 增加新的安装职责。

当前已迁移到本仓的低耦合安装能力：

- 基础 OS package 列表。
- 开发机 package 列表。
- Go 1.26.2、Node.js 22、Bun、uv 0.9.17、Python 3.12。
- Docker 和 docker-compose。
- Agent CLI 工具：Claude Code、Gemini CLI、OpenClaw、Wrangler、Playwright、pre-commit。
- KasmVNC desktop 依赖安装。

## 验证

```bash
tests/smoke.sh
```
