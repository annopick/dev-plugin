---
name: weknora
description: 通过 WeKnora MCP 服务器（PyPI 包 weknora-mcp，uvx 启动）导入文档、检索知识库并进行基于知识库/智能体的问答。用于上传文件/URL 到知识库、混合检索（向量+关键词）、浏览或管理知识条目、创建/管理知识库与会话、读取智能体、发起 RAG 或 Agent 问答，以及查询 LLM 生成的 wiki 页面。当其他技能或工作流需要从 WeKnora 知识库获取事实依据、或需要调用 WeKnora 智能体对话时也使用。
---

WeKnora 是一个 RESTful 知识库服务（基础路径 `/api/v1`，`X-API-Key` 鉴权）。**本技能的主接口是 WeKnora MCP 服务器**（源码 [`weknora-mcp-server`](https://github.com/Tencent/WeKnora/tree/main/mcp-server)，由本插件通过 PyPI 包 [`weknora-mcp`](https://pypi.org/project/weknora-mcp/) `>=1.0.1` 以 `uvx` 启动，配置为 `weknora` MCP 服务器，工具前缀 `mcp__weknora__*`）。它把 REST + SSE 流封装成结构化工具：**问答的 SSE 流已在服务端被消费并拼装好**，工具直接返回 `{ answer, references, ... }`，无需自己解析流。

工作单元是**知识库**（KB），知识库下挂**知识**条目（file / url / manual），每条被切成可检索的 chunk。对话通过**会话**（session）承载，用**智能体**（agent）决定检索与回答策略。

## 凭据与 MCP 可用性 —— 每次调用前确认

`weknora` MCP 服务器由插件 **userConfig** 自动注入凭据（见 `.mcp.json` 的 `env`）：

- `weknora_base_url` → `WEKNORA_BASE_URL`（以 `/api/v1` 结尾，如 `https://your-server/api/v1`）
- `weknora_api_key` → `WEKNORA_API_KEY`（从 WeKnora Web 端账户信息页获取）

在 **Settings → Plugin Management → annopick-plugin → Advanced** 填好这两项即完成配置。**`weknora_api_key` 未标记 sensitive**（按需求，以便在 UI 填入并被 ZCode 自动替换进 `.mcp.json`）。

**优先用 MCP 工具**。仅当 MCP 工具不可用（服务器未连接 / ZCode 未启动 MCP），或需要 MCP 服务器未覆盖的能力（见下方「REST 兜底」）时，才直接走 REST——此时需自行 `export WEKNORA_BASE_URL` / `WEKNORA_API_KEY`，任一为空就停下并提示用户。

## 意图决策表（主路径：MCP 工具）

| 用户意图 | MCP 工具 | 关键参数 |
| --- | --- | --- |
| 列出我的知识库 | `list_knowledge_bases` | — |
| 知识库详情 | `get_knowledge_base` | `kb_id`（UUID 或名称） |
| 创建知识库 | `create_knowledge_base` | `name`、`description`、`embedding_model_id?`、`summary_model_id?` |
| 删除知识库 | `delete_knowledge_base` | `kb_id` |
| 单库混合检索（向量+关键词） | `hybrid_search` | `kb_id`（UUID 或名称）、`query`、`match_count`、`vector_threshold`、`keyword_threshold` |
| 上传本地文件 | `create_knowledge_from_file` | `kb_id`、`file_path`（运行 ZCode 本机的绝对路径）、`enable_multimodel?` |
| 导入网页或远程文件 | `create_knowledge_from_url` | `kb_id`、`url`、`enable_multimodel?` |
| 浏览知识库内容 | `list_knowledge` | `kb_id`、`page`、`page_size` |
| 单条知识详情 | `get_knowledge` | `knowledge_id` |
| 删除单条知识 | `delete_knowledge` | `knowledge_id` |
| 查看解析进度 | `get_knowledge` | 盯 `data.parse_status` |
| 列出知识块 | `list_chunks` | `knowledge_id`、`page`、`page_size` |
| 删除知识块 | `delete_chunk` | `knowledge_id`、`chunk_id` |
| 列出智能体（含内置） | `list_agents` | `page`、`page_size` |
| 智能体详情（看 kb_selection_mode） | `get_agent` | `agent_id`（UUID 或名称） |
| 列出模型 | `list_models` | — |
| 创建会话 | `create_session` | **`kb_id`（必填）**、`title?`、`max_rounds?`、`enable_rewrite?` |
| 列出会话 | `list_sessions` | `page`、`page_size` |
| 基于知识库的 RAG 问答 | `chat` | `session_id`、`query`、`knowledge_base_ids?`（名称或 UUID）、`web_search_enabled?` |
| 基于 Agent 的智能问答 | `agent_chat` | `session_id`、`query`、`agent_id`（必填）、`knowledge_base_ids?`、`web_search_enabled?` |
| wiki 全文搜索 | `wiki_search` | `kb_id`、`query`、`limit?` |
| 读取 wiki 页 | `wiki_read_page` | `kb_id`、`slug` |
| wiki 目录索引 | `wiki_index_view` | `kb_id`、`limit?` |

### MCP 服务器替你做的事（重要）

- **SSE 流已拼装**：`chat` / `agent_chat` 在服务端消费整条 SSE 流，返回 `{ answer, references[], session_id, _debug_events[] }`。`answer` 是多个 `answer` 事件的 `content` 顺序拼接；`references` 是 `knowledge_references[]`。**不要自己解析流。**
- **名称即 ID**：`hybrid_search`、`chat`、`agent_chat` 的 `kb_id` / `knowledge_base_ids` / `agent_id` 既可传 UUID 也可传**名称**（服务端按名称解析，大小写不敏感）。不必先 `list_*` 拿 ID——除非要确认存在或看配置。
- **文件上传走服务端文件系统**：`create_knowledge_from_file` 的 `file_path` 是**运行 MCP 服务器（即运行 ZCode）的本机**上的绝对路径；stdio 传输下不限制目录。不是 multipart 上传——工具自己读文件。

## 状态机：parse_status

每条新建知识初始都是 `parse_status: pending`、`enable_status: disabled`。创建后轮询 `get_knowledge` 直到终态：

```
pending → processing → finalizing → completed   （enable_status 自动翻成 enabled）
                                  ↘ failed       （读 error_message，处理后 reparse）
                ↘ cancelled       （用户取消；reparse 可重试）
```

- `finalizing` = 主解析已完成，摘要/问题生成/图谱抽取还在跑。视作**没完成**——继续轮询。
- `failed` → 看 `error_message`，修因后重新解析（MCP 无 reparse 工具，走下方「REST 兜底」）。
- 只有走到 `completed`（即 `enable_status: enabled`）的知识才会在搜索中返回 chunk。

> `create_knowledge_from_file` / `_from_url` 是异步的——调用返回 `knowledge_id`（`parse_status: pending`）后，**轮询 `get_knowledge`** 到终态再用。

## 问答核心模式（MCP）

统一三步，所有 SSE 细节被 `chat` / `agent_chat` 封装：

```
1. create_session(kb_id=...)            拿 data.id 作为 session_id
2. chat(session_id, query, knowledge_base_ids=[...])          # RAG
   或 agent_chat(session_id, query, agent_id=..., knowledge_base_ids=[...])  # Agent
3. 读 result.answer（已拼好）、result.references
```

**选哪个**：
- 简单 RAG 问答 → `chat`（务必传 `knowledge_base_ids`，否则退化为 LLM 自有知识）。
- 多步推理 / 对比分析 / 需要工具调用 → `agent_chat`（`agent_id` 必填）。

**`agent_chat` 的坑**：很多 agent 的 `kb_selection_mode` 是 `none` 且无内置知识库。此时**必须传 `knowledge_base_ids`**，否则报 `no search targets available`。先用 `get_agent` 看 `kb_selection_mode` 与 `knowledge_bases`：若为 `none` 或 `selected` 但列表空，就一定带上 `knowledge_base_ids`。

> 若返回 `chat model is not configured: please set model_id on agent ...`，说明该 agent 在服务端没绑对话模型——去 WeKnora Web 端给它配 `model_id`，不是工具/技能问题。

内置 agent：`builtin-quick-answer`（RAG）、`builtin-smart-reasoning`（ReAct 多步）、`builtin-data-analyst`（CSV/Excel + SQL）。

## 常用工作流

### 上传文件并等它可被检索

```
1. create_knowledge_from_file(kb_id="my-kb", file_path="/abs/path/doc.pdf", enable_multimodel=true)
   → 返回 knowledge_id（parse_status: pending）
2. get_knowledge(knowledge_id)   # 重复直到 parse_status ∈ {completed, failed, cancelled}
3. hybrid_search(kb_id="my-kb", query="部署流程", match_count=5, vector_threshold=0.5)
```

### 导入 URL / 搜索 / 浏览

```
create_knowledge_from_url(kb_id="my-kb", url="https://example.com/article", enable_multimodel=true)
# 然后同上轮询 get_knowledge

list_knowledge(kb_id="my-kb", page=1, page_size=20)
get_knowledge(knowledge_id="<id>")
```

`score` 范围 0–1，越大越相关。调高 `vector_threshold`（默认 0.5）过滤弱匹配；要更多结果调高 `match_count`（hybrid-search **不**分页）。

### 创建会话并发起 RAG 问答

```
sid = create_session(kb_id="my-kb", title="技能测试").data.id

chat(session_id=sid,
     query="有哪些架构总体原则？",
     knowledge_base_ids=["my-kb"])    # 名称或 UUID 均可
# → result.answer（完整回答）、result.references（引用片段）
```

### Agent 智能问答

```
agent_chat(session_id=sid,
           query="战略驱动原则的编号是什么？",
           agent_id="builtin-quick-answer",     # 名称或 UUID
           knowledge_base_ids=["my-kb"])        # agent 无内置 KB 时必传
```

### 查询 wiki（LLM 生成的知识库百科）

```
wiki_search(kb_id="my-kb", query="RAG 是什么")          # 全文搜页
wiki_read_page(kb_id="my-kb", slug="concept/rag")       # 读整页 markdown + 双链
wiki_index_view(kb_id="my-kb")                          # 按类型分组的目录
```

## REST 兜底 —— MCP 未覆盖的能力

下列能力**WeKnora MCP 服务器未暴露**，需直接走 REST（curl）。此时用环境变量 `$WEKNORA_BASE_URL` / `$WEKNORA_API_KEY`（与 userConfig 同值）：

| 能力 | 方法 · Endpoint | 备注 |
| --- | --- | --- |
| 写 Markdown 知识 | `POST knowledge-bases/:kb_id/knowledge/manual` | body：`title`、`content` |
| 编辑 Markdown 知识 | `PUT knowledge/manual/:knowledge_id` | `title`、`content` |
| 重新解析（failed 后） | `POST knowledge/:knowledge_id/reparse` | — |
| 取消进行中的解析 | `POST knowledge/:knowledge_id/cancel-parse` | — |
| 跨库检索（不调 LLM） | `POST knowledge-search` | `query`、`knowledge_base_ids`（需相同 embedding） |
| 停止正在生成的回复 | `POST sessions/:session_id/stop` | `message_id` |
| 断线后续接流 | `GET sessions/continue-stream/:session_id?message_id=` | SSE |
| 知识库拷贝/副本/迁移 | `POST knowledge-bases/copy` 等 | 见 API_REFERENCE.md |
| 创建/复制智能体 | `POST agents` / `POST agents/:id/copy` | MCP 仅 list/get |

REST 调用模板（仅兜底用；问答仍优先用 MCP 的 `chat`/`agent_chat`，别自己拼 SSE）：

```bash
# 先确认凭据
[ -z "$WEKNORA_BASE_URL" ] || [ -z "$WEKNORA_API_KEY" ] && { echo "缺少 WeKnora 凭据"; exit 1; }

# JSON 请求
wk_api() {
  local method="$1" endpoint="$2" body="${3:-}"
  local args=(-s -X "$method" "$WEKNORA_BASE_URL/$endpoint"
    -H "X-API-Key: $WEKNORA_API_KEY" -H "Content-Type: application/json"
    -H "X-Request-ID: $(uuidgen 2>/dev/null || printf '%s' $$)")
  [ -n "$body" ] && args+=(-d "$body")
  curl "${args[@]}"
}

# 例：写 Markdown
wk_api POST "knowledge-bases/<kb_id>/knowledge/manual" \
  '{"title":"会议纪要","content":"# Q1 回顾\n\n要点..."}'

# 例：跨库检索
wk_api POST "knowledge-search" \
  '{"query":"部署流程","knowledge_base_ids":["kb-1","kb-2"]}'
```

文件上传（multipart，**不走** `wk_api`）：

```bash
curl -s -X POST "$WEKNORA_BASE_URL/knowledge-bases/<kb_id>/knowledge/file" \
  -H "X-API-Key: $WEKNORA_API_KEY" \
  -F "file=@/path/to/document.pdf" -F "enable_multimodel=true"
```

响应是 JSON：`{ "success": bool, "data": ..., "error"?: {...} }`。`success: false` 时读 `error.message` 并停下。完整的 REST 端点目录与字段级 schema 见 **[API_REFERENCE.md](API_REFERENCE.md)**——当 MCP 工具表与上面兜底表都覆盖不了请求时去查它。

## 关键响应字段速查

- **知识库**（`list_knowledge_bases` 的 `data[]`）：`id`、`name`、`description`、`type`（`document`\|`faq`）、`embedding_model_id`、`knowledge_count`、`chunk_count`、`processing_count`、`created_at`。
- **知识条目**（`get_knowledge` 的 `data`）：`id`、`title`、`description`（自动摘要）、`type`（`file`\|`url`\|`manual`）、`parse_status`、`enable_status`、`file_name`、`file_type`、`file_size`、`source`、`error_message`、`processed_at`。
- **搜索结果**（`hybrid_search` 的 `data[]`）：`content`（chunk 文本）、`score`、`knowledge_id`、`knowledge_title`、`knowledge_filename`、`chunk_index`、`chunk_type`（`text`\|`summary`\|`image`）。
- **智能体**（`list_agents` 的 `data[]`）：`id`、`name`、`description`、`is_builtin`、`config.agent_mode`（`quick-answer`\|`smart-reasoning`）、`config.kb_selection_mode`、`config.knowledge_bases`、`config.model_id`。
- **会话**（`create_session` 的 `data`）：`id`、`title`、`description`、`created_at`。
- **聊天结果**（`chat`/`agent_chat` 返回）：`answer`（已拼接的完整回答）、`references[]`（含 `content`/`score`/`knowledge_title`/`knowledge_filename`/`chunk_type`）、`session_id`、`_debug_events[]`（事件类型轨迹）。

## 易踩的坑

- **优先 MCP，兜底 REST**：`chat`/`agent_chat` 已拼好答案；只有 MCP 未覆盖的能力（manual/reparse/跨库 knowledge-search/stop 等）才走 curl。
- **`hybrid_search` 是单库**：MCP 工具只暴露 `kb_id`，无跨库参数。跨库检索用 REST 的 `knowledge-search`，或让 `chat`/`agent_chat` 传多个 `knowledge_base_ids`。
- **`enable_status` 仅在 `parse_status` 到达 `completed` 时自动翻 `enabled`**。刚上传的文件是 `disabled`，在你轮询到完成前不会出现在搜索结果里。
- **会话必填 `kb_id`**：MCP 的 `create_session` 把 `kb_id` 列为必填（比 REST 更严格）；`chat`/`agent_chat` 路径里都要 `session_id`，先建会话。
- **`create_knowledge_from_file` 读的是本机路径**：`file_path` 必须是运行 ZCode 的机器上的绝对路径（stdio 传输下不限制目录）。
- **跨库检索、知识库拷贝/迁移要求相同 embedding 模型**。
- **`X-API-Key` 等同账户密码**。别明文回显，别提交进版本库。

## 错误处理

| HTTP / 现象 | 含义 | 处理 |
| --- | --- | --- |
| MCP 工具不出现 | `weknora` 服务器未连接 | 核对 userConfig（`weknora_base_url`/`weknora_api_key`）已填、`uvx` 可用 |
| `no search targets available` | agent 无知识库 | `agent_chat` 必传 `knowledge_base_ids` |
| `chat model is not configured` | agent 未绑对话模型 | 去 Web 端给 agent 配 `model_id` |
| 400 | 请求错误 | 检查必填字段与参数格式 |
| 401 | 未授权 | 核对 `WEKNORA_API_KEY` |
| 403 | 禁止访问 | 确认对该资源有 editor/admin 权限 |
| 404 | 不存在 | 核对 `:id` 是否存在（名称解析失败也报这个） |
| 409 | 冲突 | 文件重复上传——响应会带回已存在条目 |
| 413 | 实体过大 | 减小文件（受 `MAX_FILE_SIZE_MB` 限制） |
| 500 | 服务端错误 | 稍等重试 |
