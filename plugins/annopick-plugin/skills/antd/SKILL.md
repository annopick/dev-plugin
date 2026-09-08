---
name: antd
description: >
  Use when the task involves Ant Design (antd) — writing or modifying antd component code,
  debugging antd issues, querying component APIs/props/tokens/demos, migrating between antd
  versions, or analyzing antd usage in a project. Triggers on antd-related code, imports from
  'antd', or explicit antd questions. Provides offline component knowledge via MCP tools (mcp__antd__*)
  or the antd CLI command line. Completely offline — no API key or network needed.
allowed-tools:
  - Bash(antd *)
  - Bash(npm install -g @ant-design/cli*)
  - Bash(which antd)
  - mcp__antd__list
  - mcp__antd__info
  - mcp__antd__doc
  - mcp__antd__demo
  - mcp__antd__token
  - mcp__antd__semantic
  - mcp__antd__changelog
---

# Ant Design 组件知识技能

你可以通过 `@ant-design/cli` 获取 Ant Design（antd）v4 / v5 / v6 的组件元数据，包括 Props、文档、Demo、设计令牌（Design Token）、语义化 className、版本变更日志等。所有数据完全离线，毫秒级查询，无需网络或 API Key。

支持两种调用方式，**优先使用 MCP 工具**，CLI 命令作为兜底。

## MCP 工具（优先）

当 antd MCP 服务器（`.mcp.json` 中的 `antd` 条目）可用时，可直接调用以下 7 个工具。MCP 工具自动探测项目 `node_modules` 中的 antd 版本，无需手动指定。

| 工具 | 用途 | 关键参数 |
|------|------|----------|
| `mcp__antd__list` | 列出所有组件（名称、分类、描述） | 无 |
| `mcp__antd__info` | 查询组件 API：Props、类型、默认值 | `component`（必填）、`detail`（布尔，含 FAQ/方法） |
| `mcp__antd__doc` | 获取组件完整 Markdown 文档 | `component`（必填） |
| `mcp__antd__demo` | 获取组件 Demo 源码 | `component`（必填）、`name`（指定 Demo） |
| `mcp__antd__token` | 查询设计令牌（全局或组件级） | `component`（可选） |
| `mcp__antd__semantic` | 查询语义化定制结构（classNames/styles） | `component`（必填） |
| `mcp__antd__changelog` | 查询版本变更日志或两个版本间的 API 差异 | `version` / `v1`+`v2`（二选一）、`component`（过滤） |

## CLI 兜底

当 MCP 工具不可用（服务器未启动、工具未注册）时，降级为 CLI 命令行调用。首次使用前检查安装状态：

```bash
which antd || npm install -g @ant-design/cli
```

CLI 命令与 MCP 工具一一对应，**始终加 `--format json` 获取可解析的结构化输出**：

```bash
antd list --format json                          # 列出组件
antd info Button --format json                   # 组件 API
antd info Button --version 5.12.0 --format json  # 指定版本
antd doc Table --format json                     # 完整文档
antd doc Table --lang zh                         # 中文文档
antd demo Button basic --format json             # Demo 源码
antd token Button --format json                  # 组件级设计令牌
antd token --format json                         # 全局设计令牌
antd semantic Button --format json               # 语义化 className
antd changelog 5.22.0 --format json             # 单版本变更
antd changelog 5.18.0..5.22.0 --format json     # 版本范围
antd migrate 4 5 --format json                  # 迁移指南
antd usage ./src --format json                   # 项目用量分析
antd lint ./src --format json                    # 废弃 API 检测
```

## 何时查询

| 场景 | 查询动作 |
|------|----------|
| **编写组件代码前** | `antd info <Component>` → 了解 Props → `antd demo <Component>` → 获取可运行示例 → 写代码 |
| **需要完整文档** | `antd doc <Component>` → Markdown 文档（非仅 Props） |
| **自定义主题/样式** | `antd token <Component>` → 设计令牌 → `antd semantic <Component>` → 语义化 className |
| **调试组件问题** | `antd info <Component> --version <项目版本>` → 验证 API 是否存在 → `antd lint <file>` → 检测废弃用法 |
| **版本迁移** | `antd migrate <from> <to>` → 迁移清单 → `antd changelog <v1> <v2>` → 破坏性变更 |
| **选择组件** | `antd list` → 浏览可用组件及分类 |
| **修改代码后验证** | `antd lint <changed-files>` → 确保无废弃或有问题的用法 |

## 核心规则

1. **编码前先查，不凭记忆猜测 API** — 写任何 antd 组件代码前，先用 `antd info` 查 Props。
2. **匹配项目版本** — 若项目使用 antd 4.x，查询时传 `--version 4.24.0`。MCP 工具会自动探测，CLI 需手动指定。
3. **结构化输出优先** — CLI 始终加 `--format json`，解析 JSON 而非正则匹配文本。
4. **改后 lint** — 编写或修改 antd 代码后，运行 `antd lint` 检查废弃或有问题的用法。
5. **迁移前先查** — 建议版本升级前，先运行 `antd changelog <v1> <v2>` 和 `antd migrate`。

## 降级策略

出现以下情况，**立即降级**为凭自身 Ant Design 知识 + 项目代码勘察继续工作，并在结果中标注"未使用 antd CLI/MCP"及降级原因，**不得卡住任务**：

- antd CLI 未安装且自动安装失败（网络受限等）。
- MCP 服务器的 `mcp__antd__*` 工具未注册（服务器未启动）。
- 查询返回错误或空结果（组件名不存在、版本不支持）。

降级后照常推进编码、出文档、自检，以通用 Ant Design 最佳实践与项目既有代码约定兜底。
