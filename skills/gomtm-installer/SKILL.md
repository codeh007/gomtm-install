---
name: gomtm-installer
description: 适用于初始化 gomtm 周边 Linux 主机、准备开发机、诊断安装前置条件，或判断某个主机安装任务应进入 gomtm-install 而不是 gomtm 主仓的场景。
---

# gomtm 安装器

## 核心规则

- 主机初始化、开发环境准备、Agent 工具安装、VNC/browser 环境和未来基础镜像组装，优先放在 `gomtm-install`。
- 现有 `gomtm install` 命令只是 gomtm 主仓迁移期兼容入口。不要继续向 `pkg/mtinstall/installers` 增加新的安装职责。
- 脚本优先。CLI 只做轻量分发，不承载复杂安装逻辑。
- 脚本必须可重复执行、易读，并且能够独立运行。
- 当命令支持 `--dry-run` 时，真实修改主机前必须先 dry-run。
- 操作远程主机前，先在本地确认命令路由和 dry-run 行为。
- 尽量从 `gomtm-install` 仓库安装本技能；其他技能仓库中的同名文件只是兼容镜像。

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

## 工作流

1. 运行 `bin/gomtm-install doctor --json` 了解当前主机状态。
2. 选择最小安装目标：
   - `install base`：runtime 主机基础依赖。
   - `install runtime-languages`：Go、Node/Bun、uv 和 Python。
   - `install docker`：Docker 和 docker-compose。
   - `install dev`：开发机初始化；内部组合调用 base、runtime languages 和 Docker。
   - `install agent-tools`：Claude Code、Gemini CLI、OpenClaw、Wrangler、Playwright 和 pre-commit。
   - `install vnc`：KasmVNC desktop 依赖。
3. 先带 `--dry-run` 执行目标命令。
4. 只有 dry-run 输出符合预期后，才去掉 `--dry-run` 真实执行。
5. 修改脚本或 CLI 路由后，运行 `tests/smoke.sh`。

## 边界

- 不要默认把 OpenCLI 或 CLI-Anything 技能复制进本项目；它们只作为 Agent-native CLI 设计参考。
- 在 gomtm 主仓调用方和 Dockerfile 使用方完成后续迁移前，不要删除 `gomtm install`。
- 新的主机安装职责不要再进入 `gomtm/pkg/mtinstall/installers`。
- 未完成本地 dry-run 和远程目标确认前，不要执行 remote bootstrap。

## 验证

```bash
tests/smoke.sh
```
