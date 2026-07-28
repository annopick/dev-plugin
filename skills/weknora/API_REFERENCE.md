# WeKnora API 参考

WeKnora REST API 的完整端点目录、请求/响应 schema 与枚举值。

> **接口选择**：大部分操作（知识库 CRUD、文件/URL 导入、混合检索、会话、RAG/Agent 问答、wiki 查询）应优先用官方 **MCP 服务器** `weknora-mcp-server`（本插件配置为 `weknora` MCP 服务器，工具前缀 `mcp__weknora__*`）——它封装了 REST + SSE 流，问答返回已拼装好的 `{ answer, references }`。**本文件是 REST 兜底与补充参考**：用于 MCP 未覆盖的能力（写/编辑 Markdown、reparse/cancel-parse、跨库 `knowledge-search`、stop/continue-stream、KB 拷贝/迁移、创建/复制 agent 等），以及需要精确字段名/类型时。MCP 工具与意图的对照见 [SKILL.md](SKILL.md)。

- **基础 URL**：`$WEKNORA_BASE_URL`（以 `/api/v1` 结尾）
- **鉴权**：每个请求带 `X-API-Key: $WEKNORA_API_KEY`
- **追踪**：可选 `X-Request-ID` 头
- **响应封装**：`{ "success": bool, "data": ..., "error"?: { "code", "message", "details" } }`

---

## 知识库

| 方法 | 路径 | 描述 |
| --- | --- | --- |
| POST | `/knowledge-bases` | 创建知识库 |
| GET | `/knowledge-bases` | 列表（`?agent_id=` 按共享 agent 过滤） |
| GET | `/knowledge-bases/:id` | 详情（`?agent_id=` 校验共享 agent 权限） |
| PUT | `/knowledge-bases/:id` | 更新（name/description/config） |
| DELETE | `/knowledge-bases/:id` | 删除（级联）—— 仅 owner |
| PUT | `/knowledge-bases/:id/pin` | 切换置顶 |
| POST | `/knowledge-bases/:id/hybrid-search` | 混合检索（向量+关键词） |
| GET | `/knowledge-bases/:id/hybrid-search` | 混合检索（旧版兼容，仍需 JSON body） |
| POST | `/knowledge-bases/copy` | 异步深拷贝（配置+全部知识） |
| GET | `/knowledge-bases/copy/progress/:task_id` | 拷贝进度 |
| POST | `/knowledge-bases/:id/duplicate` | 同步仅设置副本 |
| GET | `/knowledge-bases/:id/move-targets` | 可迁移目标列表 |

### 创建知识库 — `POST /knowledge-bases`

请求体字段：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `name` | string | 是 | |
| `description` | string | 否 | |
| `type` | string | 否 | `document`（默认）\| `faq` |
| `is_temporary` | bool | 否 | 默认 `false`；临时库不在 UI 显示 |
| `chunking_config` | object | 否 | 见下 |
| `image_processing_config` | object | 否 | `{ "model_id": "..." }` |
| `embedding_model_id` | string | 否 | |
| `summary_model_id` | string | 否 | |
| `vlm_config` | object | 否 | `{ "enabled": bool, "model_id": "..." }` |
| `asr_config` | object | 否 | `{ "enabled": bool, "model_id": "", "language": "" }` |
| `storage_provider_config` | object | 否 | 如 `{ "provider": "local" }` |
| `storage_config` | object | 否 | 旧版 COS 凭据；新集成留空 |
| `extract_config` | object\|null | 否 | 图谱抽取；`enabled=true` 时需 `text`/`tags`/`nodes`/`relations` |
| `faq_config` | object\|null | 否 | 仅 FAQ 类型库 |
| `question_generation_config` | object | 否 | `{ "enabled": bool, "question_count": 3 }` |
| `vector_store_id` | string | 否 | 绑定向量存储；**创建后不可改**；无效/跨租户 → 400 |

`chunking_config`：

```json
{
  "chunk_size": 1000,
  "chunk_overlap": 200,
  "separators": ["\n\n", "\n", "。", "！", "？", ";", "；"],
  "enable_multimodal": true,
  "parser_engine_rules": [{ "file_types": [".pdf", ".docx"], "engine": "builtin" }],
  "enable_parent_child": false,
  "parent_chunk_size": 4096,
  "child_chunk_size": 384
}
```

### 知识库响应对象（创建/详情/列表项返回）

包含所有请求字段，外加：`id`、`tenant_id`、`is_pinned`、`pinned_at`、`knowledge_count`、`chunk_count`、`processing_count`、`share_count`、`created_at`、`updated_at`、`deleted_at`。

向量存储元数据（仅详情接口返回；列表接口为避免 N+1 不返回）：

| 字段 | 取值 |
| --- | --- |
| `vector_store_name` | 展示名；未绑定时 `"System default"` |
| `vector_store_source` | `user` \| `env` \| `shared` \| `unavailable` |
| `vector_store_engine_type` | `elasticsearch` \| `qdrant` \| `milvus` \| … |
| `vector_store_status` | `available` \| `unavailable` |

向量存储错误：`400 code 2200` 无效/跨租户 ID；`400 code 2201` 存在但未注册到引擎。

### 混合检索 — `POST /knowledge-bases/:id/hybrid-search`

JSON 请求体（`SearchParams`）：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `query_text` | string | 是 | |
| `vector_threshold` | number | 否 | 0–1 相似度阈值 |
| `keyword_threshold` | number | 否 | |
| `match_count` | integer | 否 | 结果上限 |
| `disable_keywords_match` | bool | 否 | |
| `disable_vector_match` | bool | 否 | |
| `knowledge_ids` | string[] | 否 | 仅在这些知识范围内召回 |
| `tag_ids` | string[] | 否 | 标签过滤（FAQ 优先级） |
| `only_recommended` | bool | 否 | |
| `knowledge_base_ids` | string[] | 否 | 跨库召回（需相同 embedding 模型）；优先级高于路径 `:id` |
| `skip_context_enrichment` | bool | 否 | 跳过父子/相邻片段上下文补全（chat 流程用） |

### 拷贝 / 副本

`POST /knowledge-bases/copy` body：`{ "source_id", "target_id"?, "task_id"? }`。返回 `{ "task_id", "source_id", "target_id", "message" }`。指定 `target_id` 时预检：embedding 不一致或跨向量存储 → `400`，任务不入队。轮询 `GET /knowledge-bases/copy/progress/:task_id` → `{ "status": pending\|processing\|completed\|failed, "progress": 0–100, "total", "processed", "error" }`。

`POST /knowledge-bases/:id/duplicate`（Contributor+ 且对源有读权限）：同步仅设置副本，不复制知识。新名按本地化（`… 副本` / `… Copy`）。

---

## 知识

| 方法 | 路径 | 描述 |
| --- | --- | --- |
| POST | `/knowledge-bases/:id/knowledge/file` | 上传文件（multipart） |
| POST | `/knowledge-bases/:id/knowledge/url` | 导入 URL（网页抓取或文件下载） |
| POST | `/knowledge-bases/:id/knowledge/manual` | 创建 Markdown 知识 |
| GET | `/knowledge-bases/:id/knowledge` | 列出库下知识（分页/筛选） |
| DELETE | `/knowledge-bases/:id/knowledge` | 清空库下所有知识（异步）—— 仅 owner |
| GET | `/knowledge/batch` | 按 `ids=...&ids=...` 批量获取 |
| GET | `/knowledge/:id` | 知识详情 |
| PUT | `/knowledge/:id` | 更新元信息（title/description/tag/enable_status） |
| DELETE | `/knowledge/:id` | 删除单条 |
| PUT | `/knowledge/manual/:id` | 更新 Markdown 知识 |
| POST | `/knowledge/:id/reparse` | 重新解析（异步） |
| POST | `/knowledge/:id/cancel-parse` | 取消进行中的解析 |
| GET | `/knowledge/:id/download` | 下载原始文件（`attachment`） |
| GET | `/knowledge/:id/preview` | 内联预览（按扩展名设 Content-Type） |
| PUT | `/knowledge/image/:id/:chunk_id` | 更新图像分块信息 |
| PUT | `/knowledge/tags` | 批量设置/清除标签 |
| GET | `/knowledge/search` | 跨库关键词/过滤搜索 |
| POST | `/knowledge/batch-delete` | 同库内批量删除（异步，≤200） |
| POST | `/knowledge/move` | 迁移知识到另一库（异步） |
| GET | `/knowledge/move/progress/:task_id` | 迁移进度 |

> `/knowledge-bases/...` 下的 `:id` 是**知识库 ID**；`/knowledge/...` 下的 `:id` 是**知识 ID**。

### 上传文件 — `POST /knowledge-bases/:kb_id/knowledge/file`（multipart）

表单字段：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `file` | file | 是 | |
| `fileName` | string | 否 | 保留相对路径用于"文件夹上传"（如 `docs/intro.md`） |
| `metadata` | string | 否 | JSON 字符串 → `map[string]string` |
| `enable_multimodel` | string | 否 | `"true"` / `"false"` |
| `process_config` | string | 否 | JSON 覆盖：`parser_engine_rules`、`chunking_config`、`enable_multimodel`、`vlm_config`、`asr_config`、`question_generation_config`、`graph_enabled`、`extract_config` |
| `tag_id` | string | 否 | `__untagged__` 或空 = 未分类 |
| `channel` | string | 否 | 默认 `web` |

重复 → `409` 带已存在条目。超限 → `400 文件大小不能超过 N MB`。

### 导入 URL — `POST /knowledge-bases/:kb_id/knowledge/url`

body：`url`（必填）、`file_name?`、`file_type?`、`enable_multimodel?`、`title?`、`tag_id?`、`channel?`。给了 `file_name`/`file_type` 或 URL 含已知扩展名 → 文件下载模式；否则网页抓取模式。经 SSRF 校验（禁内网/回环）。

### 手写 Markdown — `POST /knowledge-bases/:kb_id/knowledge/manual`

body：`title`（必填）、`content`（必填，Markdown）、`status?`（`draft` 不触发解析）、`tag_id?`、`channel?`。

### 列出知识 — `GET /knowledge-bases/:kb_id/knowledge`

query：`page`（从 1 起）、`page_size`（默认 20）、`tag_id`、`keyword`、`file_type`（扩展名，或 `manual`/`url` 命中 `type`）、`parse_status`（`pending`/`processing`/`completed`/`failed`）、`source`（`web`/`api`/`feishu`/`notion`/…；`manual`/`url` 命中 `type`）、`start_time`、`end_time`（RFC3339 或 `YYYY-MM-DD HH:MM:SS` / `YYYY-MM-DD`）。响应：`data[]` + `page`、`page_size`、`total`。

### 知识对象（详情/列表项返回）

| 字段 | 说明 |
| --- | --- |
| `id`、`knowledge_base_id`、`tenant_id` | 标识 |
| `type` | `file` \| `url` \| `manual` |
| `title`、`description` | description = 自动摘要 |
| `source` | `url` 类型的来源 URL |
| `channel` | 如 `web`、`api`、`browser_extension`、`feishu`、`notion`、`yuque`、`wechat` |
| `tag_id` | |
| `summary_status` | |
| `parse_status` | 见枚举 |
| `enable_status` | `enabled` \| `disabled` |
| `embedding_model_id` | |
| `file_name`、`file_type`、`file_size`、`file_hash`、`file_path`、`storage_size` | 文件类字段 |
| `metadata` | |
| `error_message` | `failed` 时填充 |
| `created_at`、`updated_at`、`processed_at`、`deleted_at` | RFC3339 |

### 重新解析 / 取消

`POST /knowledge/:id/reparse` → `parse_status` 转 `pending` → `processing` → `completed`/`failed`。

`POST /knowledge/:id/cancel-parse` —— `pending`/`processing`/`finalizing` 可取消；置 `cancelled`、`error_message: 用户已取消解析`。对已 `cancelled` 幂等。`completed`/`failed`/`deleting` 不可取消。

### 批量标签更新 — `PUT /knowledge/tags`

body：`{ "kb_id"?, "updates": { "<knowledge_id>": "<tag_id>" | null } }`。`null` 清除标签。共享 KB 场景建议带 `kb_id` 鉴权。

### 跨库关键词搜索 — `GET /knowledge/search`

query：`keyword?`、`offset`（默认 0）、`limit`（默认 20）、`file_types`（逗号分隔如 `txt,pdf`）、`agent_id?`。返回 `{ "data": [...], "has_more": bool }` —— 注意 `data` 是数组，`has_more` 与之同级（非嵌套）。

### 批量删除 — `POST /knowledge/batch-delete`

body：`{ "kb_id", "ids": [...] }`（≤200，全部须属该 `kb_id`）。异步；返回 `{ "task_id", "deleted_count" }`。任一 ID 不属 → `400` 整批拒绝。

### 迁移知识 — `POST /knowledge/move`

body：`{ "knowledge_ids": [...], "source_kb_id", "target_kb_id", "mode": "reuse_vectors" | "reparse" }`。约束：同租户、同 `type`、**相同 embedding 模型**、仅 `parse_status=completed` 可迁。轮询 `GET /knowledge/move/progress/:task_id` → `{ "status", "progress": 0–100, "total", "processed", "failed", "error" }`。

---

## 跨库语义检索

### `POST /knowledge-search`

body：`query`（必填）、`knowledge_base_id`（单个）**或** `knowledge_base_ids`（数组，互斥）、`knowledge_ids?`（限定具体文件）。至少指定一个 KB 范围。不调 LLM——返回原始排序后的 chunk。

响应 `data[]`：`id`（chunk id）、`content`、`knowledge_id`、`chunk_index`、`knowledge_title`、`start_at`、`end_at`、`seq`、`score`（rerank 后归一化）、`chunk_type`（`text`/`image`/…）、`image_info`（JSON 字符串）、`metadata`、`knowledge_filename`、`knowledge_source`（`file`/`url`/`manual`）。

---

## 智能体（Agent）

| 方法 | 路径 | 描述 |
| --- | --- | --- |
| POST | `/agents` | 创建智能体（返回 201） |
| GET | `/agents` | 列表（含内置与自定义） |
| GET | `/agents/:id` | 详情 |
| PUT | `/agents/:id` | 更新（内置不可改） |
| DELETE | `/agents/:id` | 删除（内置不可删） |
| POST | `/agents/:id/copy` | 复制（副本始终为自定义，返回 201） |
| GET | `/agents/placeholders` | 获取提示词占位符定义 |

### 内置智能体

| ID | 名称 | 模式 |
| --- | --- | --- |
| `builtin-quick-answer` | 快速问答 | quick-answer（RAG） |
| `builtin-smart-reasoning` | 智能推理 | smart-reasoning（ReAct 多步） |
| `builtin-data-analyst` | 数据分析师 | smart-reasoning（CSV/Excel + SQL） |

### 创建智能体 — `POST /agents`

body：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `name` | string | 是 | |
| `description` | string | 否 | |
| `avatar` | string | 否 | emoji 或图标名 |
| `config` | object | 否 | 见下 |

### `config` 配置项

**基础**

| 字段 | 说明 |
| --- | --- |
| `agent_mode` | `quick-answer`（RAG） \| `smart-reasoning`（ReAct） |
| `system_prompt` / `system_prompt_id` | 系统提示词 / 模板 ID |
| `context_template` / `context_template_id` | 上下文模板（仅 quick-answer） |

**模型**

| 字段 | 默认 | 说明 |
| --- | --- | --- |
| `model_id` | — | 对话模型 ID（**缺失时 agent-chat 报 `chat model is not configured`**） |
| `rerank_model_id` | — | 重排序模型 |
| `temperature` | 0.7 | 0–1 |
| `max_completion_tokens` | 2048 | |
| `thinking` | nil | 是否启用扩展思考 |

**Agent 模式**

| 字段 | 说明 |
| --- | --- |
| `max_iterations` | ReAct 最大迭代（默认 10） |
| `allowed_tools` | 允许的工具列表 |
| `mcp_selection_mode` / `mcp_services` | `all`/`selected`/`none` 与选中服务 |
| `skills_selection_mode` / `selected_skills` | `all`/`selected`/`none` 与选中 Skill |

**知识库**

| 字段 | 说明 |
| --- | --- |
| `kb_selection_mode` | `all` / `selected` / `none` |
| `knowledge_bases` | 关联 KB ID 列表 |
| `retrieve_kb_only_when_mentioned` | 仅 @ 提及时检索 |
| `supported_file_types` | 如 `["csv","xlsx"]` |

**多模态**：`image_upload_enabled`、`vlm_model_id`、`image_storage_provider`（`local`/`minio`/`cos`/`tos`/`oss`）。

**FAQ 策略**：`faq_priority_enabled`（默认 true）、`faq_direct_answer_threshold`（0.9）、`faq_score_boost`（1.2）。

**网络搜索**：`web_search_enabled`（默认 true）、`web_search_max_results`（5）、`web_search_provider_id`、`web_fetch_enabled`、`web_fetch_top_n`（3）。

**多轮**：`multi_turn_enabled`（默认 true）、`history_turns`（默认 5）。

**检索策略**：`embedding_top_k`（10）、`keyword_threshold`（0.3）、`vector_threshold`（0.5）、`rerank_top_k`（5）、`rerank_threshold`（0.5）。

**推荐问题**：`suggested_prompts: []string`。

**高级**：`enable_query_expansion`、`enable_rewrite`、`rewrite_prompt_system`/`rewrite_prompt_user`、`fallback_strategy`（`fixed`/`model`，默认 `model`）、`fallback_response`、`fallback_prompt`。

### 智能体错误码

| HTTP | code | 说明 |
| --- | --- | --- |
| 400 | 1000 | 参数错误 / 名称为空 |
| 401 | 1001 | 缺少租户上下文 |
| 403 | 1002 | 无法修改/删除内置 agent |
| 404 | 1003 | 不存在 |
| 500 | 1007 | 服务端错误 |

---

## 会话（Session）

会话是纯对话容器，只存基础信息（标题/描述/置顶）。KB、模型、检索策略配置都在**查询时**由 agent 提供，不存进会话。

| 方法 | 路径 | 描述 |
| --- | --- | --- |
| POST | `/sessions` | 创建会话 |
| GET | `/sessions` | 列表（分页/关键字/来源/agent 过滤） |
| GET | `/sessions/:id` | 详情 |
| PUT | `/sessions/:id` | 更新 |
| DELETE | `/sessions/:id` | 删除 |
| DELETE | `/sessions/batch` | 批量删除（`ids` 或 `delete_all:true`） |
| DELETE | `/sessions/:id/messages` | 清空消息（保留会话） |
| POST | `/sessions/:session_id/generate_title` | 按消息生成标题 |
| POST | `/sessions/:session_id/stop` | 停止生成 |
| POST | `/sessions/:session_id/pin` | 置顶 |
| DELETE | `/sessions/:id/pin` | 取消置顶 |
| GET | `/sessions/continue-stream/:session_id?message_id=` | 续接未完成的流 |

> POST `/pin` 与 DELETE `/pin` 路径参数名不同（`:session_id` vs `:id`），语义都是会话 ID。

### 创建会话 — `POST /sessions`

body：`{ "title"?, "description"? }`（均可选）。响应 `data`：`id`、`title`、`description`、`tenant_id`、`user_id`、`is_pinned`、`created_at`、`updated_at`。通过 API-Key 调用时 `user_id` 可能为空，会话以租户级可见。

### 列出会话 — `GET /sessions`

query：`page`（默认 1）、`page_size`（默认 10）、`keyword`（标题 ILIKE）、`source`（`web` 或 IM 平台名如 `feishu`/`wechat`/`slack`）、`agent_id`（仅对 IM 会话）。响应 `data[]` + `total`/`page`/`page_size`。IM 字段（`im_platform`/`im_chat_id`/`im_thread_id`/`im_user_id`/`im_agent_id`/`im_channel_id`）仅 IM 会话填充。

### 停止生成 — `POST /sessions/:session_id/stop`

body：`{ "message_id" }`。后端向流追加 `stop` 事件。已完成返回 `"Message already completed"`。消息不属于会话 → `403`；不存在 → `404`。

### 续接流 — `GET /sessions/continue-stream/:session_id?message_id=`

SSE 连接断开后重连：先回放已产生事件，再续推到 `complete`。`message_id` 来自 `GET /messages/:session_id/load` 中 `is_completed:false` 的消息。流中无事件 → `404 No stream events found`；消息不存在 → `404 Incomplete message not found`。

---

## 聊天（SSE 流）

| 方法 | 路径 | 描述 |
| --- | --- | --- |
| POST | `/knowledge-chat/:session_id` | 基于知识库的 RAG 问答 |
| POST | `/agent-chat/:session_id` | 基于 Agent 的智能问答 |
| POST | `/knowledge-search` | 基于知识库的搜索（非 LLM） |

所有聊天返回 `Content-Type: text/event-stream`，事件 `event:message\ndata:{...}`。

### `POST /knowledge-chat/:session_id`

body：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `query` | string | 是 | 查询文本 |
| `knowledge_base_ids` | string[] | 否 | 知识库列表 |
| `knowledge_ids` | string[] | 否 | 限定具体文件 |
| `agent_id` | string | 否 | 自定义 agent |
| `summary_model_id` | string | 否 | 覆盖默认摘要模型 |
| `mentioned_items` | object[] | 否 | @ 提及的库/文件 |
| `disable_title` | bool | 否 | 禁用自动标题（默认 false） |
| `enable_memory` | bool | 否 | 记忆功能 |
| `images` | object[] | 否 | 图片（base64，需 agent 开启图片上传） |
| `channel` | string | 否 | `web`/`api`/`im`/`browser_extension` |

### `POST /agent-chat/:session_id`

body：除 `knowledge-chat` 的字段外，增加：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `agent_enabled` | bool | 是否启用 Agent 模式（默认 false） |
| `web_search_enabled` | bool | 是否启用网络搜索（默认 false） |

`mentioned_items` 结构：`{ "id", "name", "type": "kb"\|"file", "kb_type"?: "document"\|"faq" }`。
`images` 结构：`{ "data": "data:image/png;base64,..." }`。

### 事件类型（response_type）

| response_type | 描述 |
| --- | --- |
| `agent_query` | 开始处理（带 `assistant_message_id`） |
| `thinking` | Agent 思考过程 |
| `tool_call` | 工具调用（`data.tool_name`、`data.arguments`） |
| `tool_result` | 工具结果（`data.output`、`data.success`、`data.duration_ms`） |
| `references` | 知识库引用（`knowledge_references[]`，每项含 `content`/`score`/`knowledge_title`/`knowledge_filename`/`chunk_type`） |
| `answer` | 回答片段（`content` 需顺序拼接；终止事件 `done:true`） |
| `reflection` | Agent 反思 |
| `session_title` | 自动会话标题 |
| `complete` | 整轮结束 |
| `error` | 错误（`data.error` 详情、`data.stage` 阶段） |

终止信号：`answer` 且 `done:true`、`complete`、或 `error`。常见工具：`query_understand`（问题理解）、`knowledge_search`（知识检索）、`web_search`（联网搜索）。

---

## 枚举

- **知识库 type**：`document`（默认） \| `faq`
- **知识 type**：`file` \| `url` \| `manual`
- **parse_status**：`pending` → `processing` → `finalizing` → `completed` \| `failed` \| `cancelled`
  - `processing` = DocReader/分块/向量化
  - `finalizing` = 主解析完成，摘要/问题生成/图谱抽取仍在跑
  - `completed` 要求所有子任务到终态
- **enable_status**：`enabled` \| `disabled`（`parse_status=completed` 时自动 `enabled`）
- **summary_status**：`none` \| `processing` \| `completed` \| `failed`
- **chunk_type**：`text` \| `summary` \| `image`
- **agent_mode**：`quick-answer` \| `smart-reasoning`
- **任务状态**（拷贝/迁移/批量删除）：`pending` \| `processing` \| `completed` \| `failed`
- **vector_store_source**：`user` \| `env` \| `shared` \| `unavailable`
- **vector_store_status**：`available` \| `unavailable`

## 分页

- **偏移分页**（`GET .../knowledge`、列表接口）：`page` + `page_size`；响应带 `total`。
- **`GET /knowledge/search`**：`offset` + `limit`；响应带 `has_more`。
- **hybrid-search / knowledge-search**：不分页——调高 `match_count` / `limit` 取更多。
