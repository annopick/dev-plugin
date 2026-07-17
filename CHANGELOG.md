# Changelog

本项目的所有重要变更均会记录于此文件。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [1.0.1] - 2026-07-18

修复 MCP 服务凭据管理方式，避免占位符残留与误提交真实密钥的风险。

### 变更

- **MCP 凭据改为环境变量注入** (`.mcp.json`)：4 个 `zai-*` 服务（`zai-visual-understanding`、`zai-web-search`、`zai-web-page-reading-mcp`、`zai-open-source-repository-mcp`）的鉴权信息由硬编码占位符 `<Z_AI_API_KEY>` 统一改为环境变量引用 `${env:ZAI_MCP_TOKEN}`。
  - 部署/使用前需在运行环境中设置 `ZAI_MCP_TOKEN` 环境变量为真实的智谱 API Key。
  - 该改动同时消除了 v1.0.0 中"占位符需手动替换"的已知限制，并避免真实密钥被误提交进版本库。
- **插件版本号**：`.claude-plugin/plugin.json` 的 `version` 由 `1.0.0` 升至 `1.0.1`，与本 CHANGELOG 对齐。

## [1.0.0] - 2026-07-18

首个正式版本。确立 `annopick-plugin` 的插件清单、智能体、技能、MCP 服务与许可证基线。

### 新增

- **插件清单** (`.claude-plugin/plugin.json`)：声明插件元信息（`name`、`display_name`、`version`、`author`、`homepage`、`repository`、`license`），并注册 `skills`、`agents`、`mcpServers` 三类组件。
- **智能体**
  - `agents/frontend-acceptance.md`：前端 E2E 验收智能体，基于 Playwright MCP 进行自动化调试、功能验证、截图取证，并输出结构化验收报告。
  - `agents/frontend-developer.md`：前端开发智能体（支持子智能体派遣），专精 Vue3 + TypeScript + Element Plus，承担编码开发、前端详细设计文档、前端单元测试文档三类任务，并按约定协议回传结构化结果。
- **技能 `weknora`** (`skills/weknora/`)
  - `SKILL.md`：WeKnora REST API 技能。覆盖知识库/知识条目管理、文件·URL·Markdown 导入、单库混合检索与跨库检索、SSE 流式 RAG / Agent 问答、会话管理、解析状态机轮询等完整工作流；内含意图决策表、状态机说明与易踩坑提示。
  - `API_REFERENCE.md`：WeKnora 全量端点目录与字段级 schema，作为 SKILL.md 决策表覆盖不足时的精确参考。
- **MCP 服务** (`.mcp.json`)：声明 5 个 MCP server，供智能体与技能调用：
  - `playwright`（stdio，浏览器自动化，供验收智能体使用）
  - `zai-visual-understanding`（stdio，图像/视频/图表理解）
  - `zai-web-search`（http，联网搜索）
  - `zai-web-page-reading-mcp`（http，网页读取）
  - `zai-open-source-repository-mcp`（http，GitHub 仓库检索）
- **许可证** (`LICENSE`)：采用 MIT License，版权归属 `Annopick`。
- **变更日志** (`CHANGELOG.md`)：本文件。

### 已知限制

- `hooks/hooks.json` 当前为空文件，未注册任何 hook；如后续需要会话/工具事件钩子，需补充 `hooks` 配置并确保 `hooks.enabled: true`。
- 插件配置已写入文件，但需在 ZCode 客户端 **Settings → Plugin Management** 重新启用/重载本插件后，智能体与技能才会被加载（分别在 **Settings → Subagents** 与 **`/` 菜单** 出现）。

[1.0.1]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.1
[1.0.0]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.0
