# Changelog

本项目的所有重要变更均会记录于此文件。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [1.4.0] - 2026-08-14

整合 Ant Design X 官方技能（@ant-design/x-skill v2.9），用 6 个官方专项技能替换原整合版 antd-x 技能；同时为 marketplace 和插件清单配置 icon。按 SemVer 升 minor。

### 新增

- **官方 x-skill 技能整合**（6 个技能，27 文件）：从 [ant-design/x](https://github.com/ant-design/x/tree/main/packages/x-skill) 官方仓库（v2.9）直接集成，替换原 `skills/antd-x/` 整合版。每个技能含 `SKILL.md` + `reference/` 详细文档：
  - `skills/x-components/`：@ant-design/x 全部 UI 组件（Bubble/Sender/Conversations/Prompts/ThoughtChain/Actions/Welcome/Attachments/Sources/Suggestion/Think/FileCard/CodeHighlighter/Mermaid/Folder/XProvider/Notification）+ reference/（COMPONENTS.md 组件指南、PATTERNS.md 页面组合模式、API.md 自动生成 Props 参考）。
  - `skills/use-x-chat/`：useXChat Hook 对话状态管理——消息列表、多会话（useXConversations）、错误处理、流式更新 + reference/（CORE.md 核心功能、API.md 完整 API、EXAMPLES.md 实践示例）。
  - `skills/x-request/`：XRequest 流式请求配置——SSE 解析、认证安全策略、重试机制、自定义流（transformStream）+ reference/（CORE.md、API.md、EXAMPLES_SERVICE_PROVIDER.md 各服务商配置示例）。
  - `skills/x-chat-provider/`：自定义 Chat Provider 四步实现——AbstractChatProvider 三个转换方法、内置 Provider（OpenAI/DeepSeek/Default）、XRequest 高级配置 + reference/（EXAMPLES.md）。
  - `skills/x-markdown/`：@ant-design/x-markdown Markdown 流式渲染——不完整语法恢复、自定义组件映射、插件、主题 + reference/（CORE.md、STREAMING.md 流式渲染、EXTENSIONS.md 组件/插件/主题、API.md）。
  - `skills/x-card/`：@ant-design/x-card Agent 动态富交互 UI——A2UI v0.9 协议（createSurface/updateComponents/updateDataModel/deleteSurface）、XCard.Box/Card、Catalog 注册、数据绑定（JSON Pointer）、Action 处理、流式渐进渲染 + reference/（USAGE.md/COMMANDS.md/DATA_BINDING.md/ACTIONS.md/CATALOG.md/API.md/INTRODUCTION.md 共 7 文件）。
- **插件 icon 配置**：`dev-plugin.png` 配置为 marketplace 和插件 icon，三处清单文件（`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json`）统一使用 GitHub raw 链接 `https://raw.githubusercontent.com/annopick/dev-plugin/main/dev-plugin.png`。

### 变更

- **antd-developer 智能体技能引用更新**：知识优先原则技能分层表从 `antd-x` 单行扩展为 6 行（x-components/use-x-chat/x-request/x-chat-provider/x-markdown/x-card）；「Ant Design X 使用规范」段落改为按技能逐项说明；工具使用规范技能列表同步更新。
- **删除** `skills/antd-x/`（原整合版 SKILL.md，已被 6 个官方技能替代）。
- **README.md 更新**：目录结构展示 6 个 x-skill 技能目录（含 reference/）；组件清单表替换 antd-x 行为 6 行官方技能。
- **插件版本号**：三处清单 `version` 统一升至 `1.4.0`。

## [1.3.0] - 2026-08-14

新增 Ant Design Pro（ProComponents）、Umi Max 4、AntV 可视化三大技能，大幅扩展 antd 智能体的全栈开发能力。同时集成 antvis-mcp-server-chart（26 个图表生成 MCP 工具）、强制 pnpm 包管理器、纳入版本发布斜杠指令。按 SemVer 升 minor。

### 新增

- **Umi 框架知识技能** (`skills/umi/SKILL.md`)：基于 `@umijs/max` v4 官方源码的内嵌知识技能。覆盖配置系统（`defineConfig` 完整配置项表）、路由系统（配置式/约定式/布局路由扩展）、数据流（`useModel`/`getInitialState`/`useRequest`/react-query）、请求运行时配置（`errorConfig`/拦截器）、文件约定表（`app.tsx`/`access.ts`/`pages`/`models`/`mock` 等）、构建命令与生成器、常见陷阱（插件须显式启用、`.umirc.ts` 与 `config/config.ts` 互斥等）、按需文档检索 URL 地图。采用三层知识检索架构（Layer 1 内嵌 API → Layer 2 WebFetch 文档 → Layer 3 项目代码勘察）。
- **Ant Design Pro + ProComponents 知识技能** (`skills/antd-pro/SKILL.md`)：基于 `@ant-design/pro-components` v3 源码的完整 API 提取。覆盖项目结构、路由菜单生成、ProLayout 布局配置，以及 ProComponents 全组件 API 参考——ProTable（`request` 签名 + `ProColumns<T>` 20+ 字段表 + `valueType` 30+ 枚举 + `actionRef` 方法表 + 排序/过滤规则）、ProForm（props 表 + 20+ 子组件清单 + `transform`/`convertValue` + `formRef` 命令式 API）、ModalForm/DrawerForm/StepsForm/BetaSchemaForm、ProList（`columns`+`listSlot`）、ProCard（栅格/split/tabs）、ProDescriptions、StatisticCard、PageContainer。含 CRUD/仪表盘/字段联动开发模式、配置参考、约定响应格式 `{data,success,total}`、常见陷阱（版本漂移/request 返回格式/sorter 语义等）、文档 URL 地图与 GitHub 源码读取指引。
- **AntV 可视化知识技能** (`skills/antv/SKILL.md`)：集成 antvis-mcp-server-chart（26 个 `generate_*` MCP 图表生成工具）+ G2/G6/X6/Ant Design Charts 代码级 API。覆盖图表选型指南（时序/对比/占比/分布/关系/层级）、26 个 MCP 工具数据格式速查、公共参数（theme/palette/texture）、G2 v5 Spec Mode 硬规则（禁用 v4 链式 API、`chart.options()` 仅调一次、transform 必须数组）、G6 v5 核心概念、X6 图编辑与 React 集成、Ant Design Charts React 组件、开发规则、文档 URL 地图。
- **antv-chart MCP 服务器** (`.mcp.json`)：新增 `antv-chart` stdio 服务器，以 `npx -y @antv/mcp-server-chart` 启动（npm包 [@antv/mcp-server-chart](https://github.com/antvis/mcp-server-chart)）。无需鉴权（使用免费公共渲染服务），提供 26 个图表生成工具（area/bar/column/line/scatter/pie/radar/dual_axes/histogram/boxplot/funnel/waterfall/liquid/word_cloud/sankey/treemap/venn/network_graph/flow_diagram/mind_map/fishbone/organization_chart/spreadsheet 等），调用后返回图片 URL 可嵌入 Markdown。
- **版本发布斜杠指令** (`commands/plugin-version-release.md`)：原为工作区本地指令（`.zcode/commands/`），现纳入 Git 仓库的 `commands/` 目录，随插件分发。执行版本升级→CHANGELOG/README 修订→commit→push+tag 全流程。
- **pnpm 强制规则**：antd-developer 智能体新增硬规则——包管理器强制使用 pnpm，禁止 npm/yarn，禁止添加 taobao/npmmirror 镜像源。umi 与 antd-pro 技能均内嵌此规则。

### 变更

- **antd-developer 智能体扩展** (`agents/antd-developer.md`)：技术栈基线新增 Umi Max 4 / ProComponents v3 / AntV 可视化；知识优先原则重构为多技能分层表（antd→antd-pro→umi→antv→antd-x，各含降级策略）；新增「Umi Max 使用规范」「ProComponents 使用规范」「AntV 可视化使用规范」三段编码规范；接口对接区分独立项目 vs Umi/Pro 项目模式；工具规范新增 antv-chart MCP 工具与 WebFetch 按需检索；Bash 命令统一为 `pnpm` 前缀。
- **antd-acceptance 智能体扩展** (`agents/antd-acceptance.md`)：描述与技术栈新增 Ant Design Pro；知识优先新增 antd-pro 技能引用；新增「ProComponents 验收要点」段落（ProTable 搜索表单/工具栏/操作列、ModalForm/DrawerForm、PageContainer、FooterToolbar、ProDescriptions 的 DOM 特征）与「AntV 可视化验收要点」段落（Canvas 渲染断言方法、图表加载等待、G6/X6 交互验证、响应式重绘）。
- **MCP 服务器总数**：`.mcp.json` 从 7 个增至 8 个服务器（新增 `antv-chart`）。
- **插件版本号**：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 的 `version` 统一升至 `1.3.0`。

### 已知限制

- Pro 与 Umi 无现成 MCP 服务器或预置技能包，知识来源依赖技能内嵌 API（Layer 1）+ WebFetch 官方文档按需检索（Layer 2）+ GitHub 源码读取，无法做到 antd CLI 那样的毫秒级离线查询。
- antv-chart MCP 服务器依赖公共渲染服务（`https://antv-studio.alipay.com/api/gpt-vis`），网络不可达时图表生成工具不可用；代码级集成（`@ant-design/charts`/G2/G6/X6）不受影响。
- AntV 详细技能（如 `x-components` 级别的逐组件 API 详参）需安装 `@antv/chart-visualization-skills` 或对应插件。

## [1.2.1] - 2026-08-13

修复 inject 脚本在用户自定义配置目录（`dataBaseDir`）下读取 `config.json` 的路径错误，并升级 weknora MCP 依赖。本次为缺陷修复与依赖更新，无新增功能，按 SemVer 升 patch。

### 修复

- **inject 脚本配置目录解析** (`scripts/inject-agent-model.sh`、`scripts/inject-agent-model.ps1`)：两个脚本原先直接写死读取 `~/.zcode/v2/config.json`。但 ZCode 支持自定义配置目录——用户修改了 `~/.zcode/v2/settings.json` 的 `dataBaseDir` 字段后，家目录下的 `.zcode` 目录不再更新，脚本会读到过期或不存在的 `config.json`，导致校验 provider/model 失败。现改为先读取 `~/.zcode/v2/settings.json` 中的 `dataBaseDir`，非空则拼接 `$dataBaseDir/.zcode/v2/config.json`，否则回退到 `~/.zcode/v2/config.json`。bash 版用 python3（脚本既有依赖）、PowerShell 版用原生 `ConvertFrom-Json` 读取。
- **README MCP 服务表遗漏 weknora** (`README.md`)：weknora MCP 服务器自 v1.1.0 引入后一直未补进 README 的 MCP 服务表，且表格上方与目录结构注释写的"6 个 server"与实际的 7 个不符。补齐 `weknora` 行并更正计数为 7。

### 变更

- **weknora MCP 依赖升级** (`.mcp.json`)：`weknora-mcp` 由 `1.0.1` 升至 `1.1.0`。
- **插件版本号**：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 的 `version` 统一升至 `1.2.1`。

## [1.2.0] - 2026-08-12

新增 Ant Design（React + TypeScript + antd）技术栈智能体对，与原有 Vue 智能体并行共存。知识来源脱离 weknora，改用 `@ant-design/cli`（MCP/CLI 离线组件知识）与 ant-design-x 技能（AI 原生组件知识）。按 SemVer 升 minor。

### 新增

- **antd MCP 服务器** (`.mcp.json`)：新增 `antd` stdio 服务器，以 `npx -y @ant-design/cli mcp` 启动（npm 包 [@ant-design/cli](https://github.com/ant-design/ant-design-cli)）。完全离线，无需 API Key 或网络，提供 7 个工具：`antd_list`（组件列表）、`antd_info`（Props/API）、`antd_doc`（完整文档）、`antd_demo`（Demo 源码）、`antd_token`（设计令牌）、`antd_semantic`（语义化 className）、`antd_changelog`（版本变更/差异），覆盖 antd v4/v5/v6。
- **antd 组件知识技能** (`skills/antd/SKILL.md`)：类比 weknora 技能的角色，教智能体在编码前通过 MCP 工具或 CLI 命令查询组件 API（不凭记忆猜测），含场景指南（编写组件/调试/迁移/分析用量）、核心规则（匹配项目版本、结构化输出优先、改后 lint）、降级策略（CLI/MCP 不可用时凭自身知识兜底）。
- **antd-x AI 原生组件知识技能** (`skills/antd-x/SKILL.md`)：覆盖 `@ant-design/x` 全部组件（Bubble、Sender、Conversations、Prompts、ThoughtChain、Actions、Welcome、Attachments、Sources、Suggestion、Think、FileCard、CodeHighlighter、Mermaid、Folder、XProvider、Notification）+ SDK 数据流（useXChat、XRequest、XChatProvider、XMarkdown、XCard）。基于 RICH 交互范式分组，含开发规则防踩坑与详细技能路由（引用已安装的 `x-components` 等技能获取逐组件 API 详参）。
- **antd 开发智能体** (`agents/antd-developer.md`)：React 18+ + TypeScript + Ant Design v5/v6 技术栈，完整镜像 `frontend-developer.md` 结构——任务派发协议、知识优先原则（antd/antd-x 技能替代 weknora）、三个工作流（编码开发/详细设计文档/单元测试文档）、React+TS+antd+x 编码规范（函数组件+Hooks、ConfigProvider 主题定制、Form.useForm 表单校验、XProvider/Bubble.List/Sender 等 AI 组件用法）。
- **antd 验收智能体** (`agents/antd-acceptance.md`)：React + Ant Design 技术栈 E2E 验收专家，镜像 `frontend-acceptance.md` 结构——Playwright 浏览器验证流程、知识优先用 antd 技能替代 weknora、antd 组件验收要点（Select/Modal/DatePicker/Table/Form 的 DOM portal 渲染特征）。

### 变更

- **inject 脚本与指令扩展** (`scripts/inject-agent-model.sh`、`scripts/inject-agent-model.ps1`、`commands/inject-agent-model.md`)：`AGENT_FILES` / `$AgentFiles` 数组从 2 个扩展到 4 个（新增 `antd-developer.md`、`antd-acceptance.md`），注释与指令描述从"两个前端 agent"更新为"四个前端 agent（Vue 与 antd 两套技术栈）"。`/inject-agent-model` 命令一次注入全部四个 agent 的 `model:` 字段。
- **插件版本号**：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 的 `version` 统一升至 `1.2.0`。

### 已知限制

- antd MCP 服务器（`npx -y @ant-design/cli mcp`）要求运行环境可执行 npx 且能从 npm registry 拉取 `@ant-design/cli`；离线环境首次启动可能失败，降级为凭智能体自身 antd 知识兜底。
- antd-x 技能的逐组件详细 API（如 `x-components`、`use-x-chat` 等）依赖 `x-agent-skills` 插件提供；未安装时 `antd-x` 技能仍提供组件选型与开发规则总览，但不包含逐 Prop 详参。

## [1.1.0] - 2026-07-28

集成官方 WeKnora MCP 服务器（PyPI 包 `weknora-mcp`），作为 weknora 技能的主接口；凭据通过 userConfig 自动注入。这是相对 1.0.6 的功能新增，按 SemVer 升 minor。

### 新增

- **WeKnora MCP 服务器** (`.mcp.json`)：新增 `weknora` stdio 服务器，以 `uvx --from weknora-mcp==1.0.1 weknora-mcp-server` 启动（PyPI 包 [weknora-mcp](https://pypi.org/project/weknora-mcp/)，源码 [Tencent/WeKnora/mcp-server](https://github.com/Tencent/WeKnora/tree/main/mcp-server)）。它把 WeKnora REST + SSE 流封装成 28 个结构化工具（知识库 CRUD、文件/URL 导入、`hybrid_search`、会话、`chat`/`agent_chat`、`list/get_agent`、`list_models`、chunk 管理、wiki 查询等）；**问答的 SSE 流已在服务端消费并拼装**，工具直接返回 `{ answer, references, ... }`，无需自行解析流。已对真实实例（`http://192.168.50.26/api/v1`）实测：initialize 握手、tools/list（28 项）、list_knowledge_bases、hybrid_search 全部通过。
- **WeKnora 凭据 userConfig** (`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`)：清单新增 `weknora_base_url`、`weknora_api_key` 两个字段（`type:string`、`required:true`，**未标 sensitive** 以便在 UI 填入并被自动替换）。ZCode 加载插件时自动把二者替换进 `.mcp.json` 的 `env.WEKNORA_BASE_URL` / `env.WEKNORA_API_KEY`。安装后在 **Plugin Management → Advanced** 填入即可。

### 变更

- **weknora 技能重写为 MCP 服务器主接口** (`skills/weknora/SKILL.md`)：意图决策表从「REST endpoint」改为「MCP 工具 → 意图」映射；明确 MCP 服务器替你做的事（SSE 流已拼装、名称即 ID、文件上传走服务端本机路径）；REST 降级为兜底，仅覆盖 MCP 未暴露的能力（写/编辑 Markdown、reparse/cancel-parse、跨库 `knowledge-search`、stop/continue-stream、KB 拷贝/迁移、创建/复制 agent），保留 curl 模板。工作流示例全部改为 MCP 工具调用风格。
- **API 参考定位调整** (`skills/weknora/API_REFERENCE.md`)：开头说明 MCP 服务器为主接口、本文件为 REST 兜底与字段级 schema 参考。
- **插件版本号**：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 的 `version` 统一升至 `1.1.0`。

### 已知限制

- `weknora_api_key` 未标记 `sensitive`（与 `zai_api_token` 同理：ZCode 当前对 sensitive 的 userConfig 值无法在 UI 填入且不持久化，故为保证可用性以明文存于配置）。`X-API-Key` 等同账户密码，请妥善保管。
- weknora MCP 服务器要求运行环境有 `uv`/`uvx`（用于拉起 PyPI 包）。

## [1.0.6] - 2026-07-23

引入 userConfig 自动注入 ZAI MCP Token，脚本转为斜杠指令（command），并对齐 ZCode 推荐清单范式、补齐文档。

### 新增

- **userConfig 自动注入 MCP Token** (`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`)：清单新增 `userConfig.zai_api_token` 字段（`type:string`、`required:true`，**未标 sensitive** 以保证可在 UI 填入并被自动替换）。`.mcp.json` 中 4 处占位符由 `${ZAI_MCP_TOKEN}` 改为 `${user_config.zai_api_token}`，ZCode 加载插件时自动把用户配置的真实 token 替换进 4 个 zai MCP 服务器的 `env`/`headers`。安装后在 **Plugin Management → Advanced** 填入 `zai_api_token` 即可，无需再手动跑脚本。
- **斜杠指令** (`commands/`)：把两个安装后配置脚本封装为插件 command（薄封装，正文指示 agent 调用 `${ZCODE_PLUGIN_ROOT}/scripts/*.sh`）。
  - `commands/inject-mcp-token.md`（`/inject-mcp-token`）：MCP token 兜底注入，当 userConfig 不可用时使用。
  - `commands/inject-agent-model.md`（`/inject-agent-model`）：为前端 agent 注入 `model:` 字段（默认 Kimi K3，支持 `--provider`/`--model`/`--version` 参数）。
- **插件说明文档** (`README.md`)：根目录新增完整的 README，含目录结构、组件清单、MCP 服务器表、快速上手（安装→配 token→注入 model）、指令说明。

### 变更

- **清单范式对齐** (`.zcode-plugin/`)：按 ZCode 推荐范式，新建 `.zcode-plugin/plugin.json` 作为清单主位置（探测优先级最高），`.claude-plugin/plugin.json` 降为兼容镜像保持内容一致。清单不再显式声明 `skills`/`agents`/`mcpServers` 字段，改由标准路径自动发现，避免重复加载诊断。补充 `description_i18n.en` 英文兜底。
- **脚本占位符同步** (`scripts/inject-mcp-token.sh`、`.ps1`)：占位符常量由 `${ZAI_MCP_TOKEN}` 同步为 `${user_config.zai_api_token}`，与 `.mcp.json` 一致；并修复 macOS BSD sed 对 `${}` 转义报 `invalid repetition count` 的问题——替换实现由 sed 改为 bash 参数展开（`${line//find/replace}`），纯字面量替换、无需转义、对 token 中的 `/ & \` 特殊字符安全。
- **脚本文档** (`scripts/README.md`)：重写以反映 userConfig 为主路径、脚本/指令为兜底；补充斜杠指令与脚本的对照、平台差异、回滚方式。
- **插件版本号**：`.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 的 `version` 统一升至 `1.0.6`。

### 已知限制

- `zai_api_token` 未标记 `sensitive`。ZCode 当前对 sensitive 的 userConfig 值无法在 UI 填入且不持久化，故为保证可用性，token 以明文存于 `~/.zcode/cli/config.json`。待 ZCode 支持敏感值安全存储后可改为 sensitive。
- 前端 agent 的 `model:` 字段仍需通过 `/inject-agent-model` 注入真实值（agent model 依赖本机 provider 配置，无法用 userConfig 统一声明）。

## [1.0.5] - 2026-07-19

修复 marketplace 清单版本号与插件清单不同步的问题，无功能变更。

### 修复

- **marketplace 清单版本号对齐** (`.claude-plugin/marketplace.json`)：该文件的 `plugins[].version` 自 v1.0.3 起滞后于 `.claude-plugin/plugin.json` 的 `version`（marketplace 停留在 1.0.3，plugin 已到 1.0.4），导致 marketplace 展示的版本与实际插件版本不一致。本次将两者统一升至 1.0.5，并在此后每次发版同步更新。

### 变更

- **插件版本号**：`.claude-plugin/plugin.json` 与 `.claude-plugin/marketplace.json` 的 `version` 均升至 `1.0.5`，与本 CHANGELOG 对齐。

## [1.0.4] - 2026-07-19

新增 Windows（PowerShell）版安装后配置脚本，与既有 bash 脚本逻辑等价，并补充统一的使用说明文档。

### 新增

- **Windows PowerShell 脚本** (`scripts/`)：与 v1.0.3 的 bash 脚本一一对应的 `.ps1` 版本，供 Windows 11 用户使用。
  - `scripts/inject-mcp-token.ps1`：对应 `inject-mcp-token.sh`。读取 `$env:ZAI_MCP_TOKEN`，替换 `%USERPROFILE%\.zcode\cli\plugins\cache\annopick-plugin\annopick-plugin\<version>\.mcp.json` 中的 `${ZAI_MCP_TOKEN}` 占位符。用 .NET 字面量 `string.Replace`（非正则）替换，token 含 `/`、`&`、`\` 等特殊字符也安全；写回保持 UTF-8 无 BOM。
  - `scripts/inject-agent-model.ps1`：对应 `inject-agent-model.sh`。默认 Kimi K3，支持 `-Provider`/`-Model`/`-Version` 参数覆盖；从 `%USERPROFILE%\.zcode\v2\config.json` 校验 provider/model 真实存在；provider key 中的 `:` 自动 URL 编码为 `%3A`；已有 `model:` 行原地替换，没有则在 frontmatter 结束 `---` 前插入。
- **脚本使用说明** (`scripts/README.md`)：统一说明两个平台下的脚本用法、Windows 执行策略（`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`）注意事项、路径对照（macOS `~/.zcode/...` vs Windows `%USERPROFILE%\.zcode\...`）、参数表与回滚方式。

### 修复

- **两个 bash 脚本版本探测的字典序问题**（`inject-mcp-token.sh`、`inject-agent-model.sh`）：原 `sort -V` 在 macOS 上对 `1.9.0` vs `1.10.0` 的排序符合版本语义；PowerShell 移植时若用 `Sort-Object -Property Name` 会退化为字典序选错版本，统一改用 `[version]` 类型排序。bash 版本经复核 `sort -V` 行为正确，无需改动。

### 变更

- **插件版本号**：`.claude-plugin/plugin.json` 的 `version` 由 `1.0.3` 升至 `1.0.4`，与本 CHANGELOG 对齐。

## [1.0.3] - 2026-07-18

新增插件安装后的配置注入脚本，并引入 agent 的 `model` 字段占位符，补齐"安装即需本地化配置"的链路。

### 新增

- **安装后配置脚本** (`scripts/`)：因 ZCode 当前不在 MCP 配置与 agent `model` 字段中展开环境变量/动态值，提供两个幂等脚本在安装后手动注入，支持自动探测最新已安装版本目录、写前备份、缺项报错退出。
  - `scripts/inject-mcp-token.sh`：读取系统环境变量 `ZAI_MCP_TOKEN`，替换插件安装目录下 `<version>/.mcp.json` 中 4 处 `${ZAI_MCP_TOKEN}` 占位符（1 处 stdio env、3 处 http headers）。对 token 中的 sed 特殊字符（`\`、`&`、`/`）做转义；占位符已不存在时视为成功跳过。
  - `scripts/inject-agent-model.sh`：将插件安装目录下两个前端 agent 文件 frontmatter 的 `model:` 字段写入 `custom:<provider>:<model-id>` 格式的真实值。默认 Kimi K3（`provider=623553b2-da8a-4b43-9320-90b1ed62a12b`、`model=k3`），支持 `--provider`/`--model`/`--version` 覆盖。写前从 `~/.zcode/v2/config.json` 校验 provider/model 真实存在；provider key 中的 `:` 自动 URL 编码为 `%3A`（与现网 `kimi-k3.md` 格式一致）；缺 `model:` 行时在 frontmatter 结束 `---` 前自动插入，有则原地替换。
- **agent `model` 字段占位符** (`agents/frontend-developer.md`、`agents/frontend-acceptance.md`)：两个 agent frontmatter 新增 `model: "custom:<provider>:<modelid>"` 占位符行。**该值为字面占位符，安装后需运行 `inject-agent-model.sh` 注入真实值后 agent 才能按指定模型运行**；不注入则 agent 的 model 配置无效。

### 使用说明（安装后必做）

```bash
export ZAI_MCP_TOKEN=<你的智谱 API Key>
bash scripts/inject-mcp-token.sh
bash scripts/inject-agent-model.sh   # 默认 Kimi K3；可加 --provider/--model 改用其他模型
```

### 变更

- **插件版本号**：`.claude-plugin/plugin.json` 的 `version` 由 `1.0.2` 升至 `1.0.3`，与本 CHANGELOG 对齐。

## [1.0.2] - 2026-07-18

前端智能体接入 WeKnora 知识库检索能力，并修正 v1.0.1 遗留的环境变量注入语法。

### 新增

- **智能体接入 `weknora` 技能** (`agents/frontend-developer.md`、`agents/frontend-acceptance.md`)：两个智能体均新增「知识库优先原则（WeKnora）」章节，作为贯穿性原则生效。
  - **优先查询**：涉及前端编码规范、组件/接口约定、架构决策、验收标准、业务规则等事实性问题时，优先通过 `weknora` 技能检索 WeKnora 知识库；知识库中的项目规范与智能体默认判断冲突时以知识库为准。
  - **非阻塞降级**：凭据缺失（`WEKNORA_BASE_URL`/`WEKNORA_API_KEY` 未配置）、无 `kb_id` 且无可匹配库、检索空、服务不可达四种情形立即降级为凭自身能力/案例描述继续工作，不卡住任务，并在结果中标注"未引用（降级原因）"。
  - 各自工作流相应步骤（开发者「项目结构探查」、验收「解析验证案例」）前置知识库检索引用；工具规范新增 `Skill（weknora）` 条目；结果回传/验收报告模板新增 `知识库引用` 字段。
  - 两个智能体 `description` 补充知识库优先说明，便于主智能体派遣时感知此能力。
  - 附带修正 `frontend-acceptance.md` 中 `description` 的 `截图取>证` 笔误。

### 修复

- **MCP 环境变量注入语法** (`.mcp.json`)：4 个 `zai-*` 服务的鉴权引用由 `${env:ZAI_MCP_TOKEN}` 修正为 `${ZAI_MCP_TOKEN}`，使运行时能正确解析并注入环境变量（v1.0.1 的 `${env:...}` 语法在当前运行时下不被识别）。

### 变更

- **插件版本号**：`.claude-plugin/plugin.json` 的 `version` 由 `1.0.1` 升至 `1.0.2`，与本 CHANGELOG 对齐。

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

[1.2.1]: https://github.com/annopick/dev-plugin/releases/tag/v1.2.1
[1.2.0]: https://github.com/annopick/dev-plugin/releases/tag/v1.2.0
[1.1.0]: https://github.com/annopick/dev-plugin/releases/tag/v1.1.0
[1.0.6]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.6
[1.0.5]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.5
[1.0.4]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.4
[1.0.3]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.3
[1.0.2]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.2
[1.0.1]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.1
[1.0.0]: https://github.com/annopick/dev-plugin/releases/tag/v1.0.0
