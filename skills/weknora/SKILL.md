---
name: weknora
description: 通过 WeKnora REST API 导入文档、检索知识库并进行基于知识库/智能体的问答。用于上传文件/URL/Markdown 到知识库、混合检索（向量+关键词）、跨库搜索、浏览或管理知识条目、创建/管理知识库、读取/创建智能体、创建会话并发起 RAG 或 Agent 流式问答。当其他技能或工作流需要从 WeKnora 知识库获取事实依据、或需要调用 WeKnora 智能体对话时也使用。
---

WeKnora 是一个 RESTful 知识库服务。基础路径 `/api/v1`，每个请求通过 `X-API-Key` 头鉴权。工作单元是**知识库**（KB），知识库下挂**知识**条目（file / url / manual），每条被切成可检索的 chunk。对话通过**会话**（session）承载，用**智能体**（agent）决定检索与回答策略。

## 凭据校验 —— 每次调用前先做

两个环境变量必须存在。先检查；任一为空就停下并提示用户。

```bash
if [ -z "$WEKNORA_BASE_URL" ] || [ -z "$WEKNORA_API_KEY" ]; then
  echo "缺少 WeKnora 凭据。请设置 WEKNORA_BASE_URL（如 https://your-server/api/v1）与 WEKNORA_API_KEY（从 WeKnora Web 端账户信息页获取）后重试。"
  exit 1
fi
```

要跨会话持久化，把两条 `export` 写进 `~/.zshrc` 或 `~/.bashrc`。

## 调用模板

每个会话定义一次下面的 helper，所有 JSON 请求走它。文件上传用 `curl -F` 直连（multipart，**不走** helper）。

```bash
wk_api() {
  local method="$1" endpoint="$2" body="${3:-}"
  local args=(-s -X "$method" "$WEKNORA_BASE_URL/$endpoint"
    -H "X-API-Key: $WEKNORA_API_KEY"
    -H "Content-Type: application/json"
    -H "X-Request-ID: $(uuidgen 2>/dev/null || printf '%s' $$)")
  [ -n "$body" ] && args+=(-d "$body")
  curl "${args[@]}"
}
```

聊天接口返回 SSE 流，用单独的流式 helper（`-N` 关闭缓冲，逐事件输出）：

```bash
wk_stream() {
  local endpoint="$1" body="$2"
  curl -s -N -X POST "$WEKNORA_BASE_URL/$endpoint" \
    -H "X-API-Key: $WEKNORA_API_KEY" \
    -H "Content-Type: application/json" \
    -H "X-Request-ID: $(uuidgen 2>/dev/null || printf '%s' $$)" \
    -d "$body"
}
```

下面所有 endpoint 都拼在 `$WEKNORA_BASE_URL` 后。响应是 JSON：`{ "success": bool, "data": ..., "error"?: {...} }`。`success: false` 时读 `error.message` 并停下。

## 意图决策表 —— 按用户意图选 endpoint

| 用户意图 | 方法 · Endpoint | 关键参数 |
| --- | --- | --- |
| 列出我的知识库 | `GET knowledge-bases` | — |
| 知识库详情 | `GET knowledge-bases/:kb_id` | — |
| 创建知识库 | `POST knowledge-bases` | `name`、`type`（`document`\|`faq`） |
| 删除知识库 | `DELETE knowledge-bases/:kb_id` | — |
| 单库混合检索（向量+关键词） | `POST knowledge-bases/:kb_id/hybrid-search` | `query_text`、`match_count`、`vector_threshold` |
| 跨库检索（不调 LLM，返回 chunk） | `POST knowledge-search` | `query`、`knowledge_base_ids` |
| 上传文件 | `POST knowledge-bases/:kb_id/knowledge/file` | multipart：`file=@path`、`enable_multimodel` |
| 导入网页或远程文件 | `POST knowledge-bases/:kb_id/knowledge/url` | `url`；给 `file_name`/`file_type` 强制走文件模式 |
| 直接写 Markdown | `POST knowledge-bases/:kb_id/knowledge/manual` | `title`、`content` |
| 查看解析进度 | `GET knowledge/:knowledge_id` | 盯 `data.parse_status` |
| 浏览知识库内容 | `GET knowledge-bases/:kb_id/knowledge?page=1&page_size=20` | `tag_id`、`keyword`、`file_type` |
| 单条知识详情 | `GET knowledge/:knowledge_id` | — |
| 编辑 Markdown 知识 | `PUT knowledge/manual/:knowledge_id` | `title`、`content` |
| 配置变更/失败后重新解析 | `POST knowledge/:knowledge_id/reparse` | — |
| 取消进行中的解析 | `POST knowledge/:knowledge_id/cancel-parse` | — |
| 删除单条知识 | `DELETE knowledge/:knowledge_id` | — |
| 列出智能体（含内置） | `GET agents` | — |
| 智能体详情 | `GET agents/:id` | — |
| 创建智能体 | `POST agents` | `name`、`config.agent_mode` |
| 创建会话 | `POST sessions` | `title?`、`description?` |
| 列出会话 | `GET sessions?page=1&page_size=10` | `keyword`、`source`、`agent_id` |
| 基于知识库的 RAG 问答 | `POST knowledge-chat/:session_id` | `query`、`knowledge_base_ids`、`agent_id?` |
| 基于 Agent 的智能问答 | `POST agent-chat/:session_id` | `query`、`agent_id`、`agent_enabled:true` |
| 停止正在生成的回复 | `POST sessions/:session_id/stop` | `message_id` |
| 断线后续接流 | `GET sessions/continue-stream/:session_id?message_id=` | `message_id` |

完整目录（知识库拷贝/副本、知识迁移、批量删除、标签、下载/预览、向量存储绑定、FAQ/图谱配置、智能体复制/占位符）见 **[API_REFERENCE.md](API_REFERENCE.md)**。当上面表格覆盖不了用户请求时去查它。

## 状态机：parse_status

每条新建知识初始都是 `parse_status: pending`、`enable_status: disabled`。创建后轮询 `GET knowledge/:id` 直到终态：

```
pending → processing → finalizing → completed   （enable_status 自动翻成 enabled）
                                  ↘ failed       （读 error_message，处理后 reparse）
                ↘ cancelled       （用户取消；reparse 可重试）
```

- `finalizing` = 主解析已完成，摘要/问题生成/图谱抽取还在跑。视作**没完成**——继续轮询。
- `failed` → 看 `error_message`，修因后 `POST knowledge/:id/reparse`。
- 只有走到 `completed`（即 `enable_status: enabled`）的知识才会在搜索中返回 chunk。

## SSE 流式问答 —— 核心模式

所有问答接口返回 Server-Sent Events（`Content-Type: text/event-stream`）。**统一流程**：

```
1. POST sessions               创建会话，拿 data.id 作为 session_id
2. POST knowledge-chat/:sid 或 agent-chat/:sid，body 带 query
3. 消费事件流直到终止信号
```

每个事件形如 `event:message\ndata:{...}`。按 `response_type` 分类：

| response_type | 含义 | 出现在 |
| --- | --- | --- |
| `agent_query` | 开始处理（携带 `assistant_message_id`） | 两者都有 |
| `thinking` | Agent 思考过程 | agent-chat |
| `tool_call` | 工具调用（query_understand / knowledge_search / web_search…） | 两者都有 |
| `tool_result` | 工具返回结果 | 两者都有 |
| `references` | 知识库检索引用（含 `knowledge_references[]`） | 两者都有 |
| `answer` | 回答内容片段（可能多条，逐块拼接） | 两者都有 |
| `reflection` | Agent 反思 | agent-chat |
| `session_title` | 自动生成的会话标题 | 两者都有 |
| `complete` | 整轮结束 | 两者都有 |
| `error` | 错误（`data.error` 给详情，`data.stage` 给阶段） | 两者都有 |

**终止信号**（任一出现即结束）：`answer` 事件 `done:true`、`response_type:"complete"`、或 `response_type:"error"`。拼接答案时把所有 `response_type:"answer"` 的 `content` 顺序拼起来即可。

> **注意**：`knowledge-chat` 和 `agent-chat` 底层都会跑工具链（query_understand → knowledge_search → …），差别在 `agent-chat` 支持 `smart-reasoning` 多步推理、网络搜索、MCP 工具。简单 RAG 问答用 `knowledge-chat` 或 `agent_id: builtin-quick-answer` 即可。

## 常用工作流

### 上传文件并等它可被检索

```bash
# 1. 选目标库
wk_api GET "knowledge-bases"            # -> 从 data[].id 选 kb_id

# 2. 上传（multipart —— 这里不用 wk_api，也别加 Content-Type: json）
curl -s -X POST "$WEKNORA_BASE_URL/knowledge-bases/<kb_id>/knowledge/file" \
  -H "X-API-Key: $WEKNORA_API_KEY" \
  -F "file=@/path/to/document.pdf" -F "enable_multimodel=true"
# -> data.id 是 knowledge_id，parse_status 为 pending/processing

# 3. 轮询到终态
wk_api GET "knowledge/<knowledge_id>"   # -> 重复直到 parse_status ∈ completed|failed|cancelled
```

### 导入 URL / 写 Markdown / 搜索 / 浏览

```bash
wk_api POST "knowledge-bases/<kb_id>/knowledge/url" \
  '{"url":"https://example.com/article","enable_multimodel":true}'
# 然后同上轮询 GET knowledge/:id

wk_api POST "knowledge-bases/<kb_id>/knowledge/manual" \
  '{"title":"会议纪要","content":"# Q1 回顾\n\n要点..."}'

# 单库混合检索（推荐）
wk_api POST "knowledge-bases/<kb_id>/hybrid-search" \
  '{"query_text":"部署流程","match_count":5,"vector_threshold":0.5}'
# 跨库
wk_api POST "knowledge-search" \
  '{"query":"部署流程","knowledge_base_ids":["kb-1","kb-2"]}'

wk_api GET "knowledge-bases/<kb_id>/knowledge?page=1&page_size=20"
wk_api GET "knowledge/<knowledge_id>"
```

`score` 范围 0–1，越大越相关。调高 `vector_threshold`（默认 ~0.5）过滤弱匹配；要更多结果调高 `match_count`（hybrid-search **不**分页）。

### 创建会话并发起 RAG 问答

```bash
SID=$(wk_api POST "sessions" '{"title":"技能测试"}' \
  | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | head -1)

wk_stream "knowledge-chat/$SID" \
  "{\"query\":\"有哪些架构总体原则？\",\"knowledge_base_ids\":[\"<kb_id>\"],\"agent_id\":\"builtin-quick-answer\"}"
# -> 依次收到 agent_query → tool_call → references → answer(done:true)
```

### Agent 智能问答

```bash
wk_stream "agent-chat/$SID" \
  "{\"query\":\"战略驱动原则的编号是什么？\",\"agent_enabled\":true,\"agent_id\":\"builtin-quick-answer\",\"knowledge_base_ids\":[\"<kb_id>\"]}"
# agent_id 换成 builtin-smart-reasoning 可触发多步推理（需该 agent 已配 model_id）
```

> 若返回 `error: chat model is not configured: please set model_id on agent ...`，说明该 agent 在服务端没绑对话模型 —— 去 WeKnora Web 端给它配 `model_id`，不是 API/技能问题。

### 停止生成 / 续接断流

```bash
wk_api POST "sessions/<session_id>/stop" '{"message_id":"<assistant_message_id>"}'
wk_api GET  "sessions/continue-stream/<session_id>?message_id=<message_id>"
```

## 关键响应字段速查

- **知识库**（`GET knowledge-bases` 的 `data[]`）：`id`、`name`、`description`、`type`（`document`\|`faq`）、`embedding_model_id`、`knowledge_count`、`chunk_count`、`processing_count`、`created_at`。
- **知识条目**（`GET knowledge/:id` 的 `data`）：`id`、`title`、`description`（自动摘要）、`type`（`file`\|`url`\|`manual`）、`parse_status`、`enable_status`、`file_name`、`file_type`、`file_size`、`source`、`error_message`、`processed_at`。
- **搜索结果**（`data[]`）：`content`（chunk 文本）、`score`、`knowledge_id`、`knowledge_title`、`knowledge_filename`、`chunk_index`、`chunk_type`（`text`\|`summary`\|`image`）。
- **智能体**（`GET agents` 的 `data[]`）：`id`、`name`、`description`、`avatar`、`is_builtin`、`config.agent_mode`（`quick-answer`\|`smart-reasoning`）、`config.kb_selection_mode`、`config.model_id`。
- **会话**（`POST sessions` 的 `data`）：`id`、`title`、`description`、`is_pinned`、`created_at`。内置 agent id：`builtin-quick-answer`、`builtin-smart-reasoning`、`builtin-data-analyst`。
- **聊天事件**：见上方「SSE 流式问答」的事件类型表。

每个 endpoint 的字段级 schema 在 **[API_REFERENCE.md](API_REFERENCE.md)**。

## 易踩的坑

- **文件上传是 `multipart/form-data`**。用 `curl -F 'file=@path'`。上传时**别**带 `Content-Type: application/json`，否则请求体被错误解析。
- **`hybrid-search` 和 `knowledge-search` 都传 JSON body**，即便旧文档列了 GET 变体。始终用 `POST` + `-d '{...}'`。
- **`enable_status` 仅在 `parse_status` 到达 `completed` 时自动翻 `enabled`**。刚上传的文件是 `disabled`，在你轮询到完成前不会出现在搜索结果里。
- **聊天是 SSE 流**，不是单次 JSON。用 `-N` 关闭缓冲；答案靠拼接多个 `answer` 事件的 `content`，靠 `done:true`/`complete`/`error` 判终止。
- **会话是必须的**。`knowledge-chat` 和 `agent-chat` 路径里都要 `session_id`；先 `POST sessions` 建一个。
- **跨库检索、知识库拷贝/迁移要求相同 embedding 模型**。
- **`X-API-Key` 等同账户密码**。别明文回显，别提交进版本库。

## 错误处理

| HTTP | 含义 | 处理 |
| --- | --- | --- |
| 400 | 请求错误 | 检查必填字段与参数格式 |
| 401 | 未授权 | 核对 `WEKNORA_API_KEY` |
| 403 | 禁止访问 | 确认对该资源有 editor/admin 权限 |
| 404 | 不存在 | 核对 `:id` 是否存在 |
| 409 | 冲突 | 文件重复上传——响应会带回已存在条目 |
| 413 | 实体过大 | 减小文件（受 `MAX_FILE_SIZE_MB` 限制） |
| 500 | 服务端错误 | 稍等重试 |
