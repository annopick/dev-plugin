---
name: annopick-orchestrator
description: Codex 主智能体调度四个 Annopick 前端子智能体的规范。
---

# Annopick Codex 子智能体调度规范

本目录是**子智能体角色定义**，不是技能。主智能体在需要委派工作时，先读取本文件和目标角色文件，再使用 Codex 的 `spawn_agent` 派发任务；不要把角色文件当作可自动调用的技能。

## 角色选择

| 工作 | 子智能体 |
| --- | --- |
| Vue 3、TypeScript、Element Plus 的开发、设计文档或测试文档 | `frontend-developer.md` |
| Vue 前端 E2E、回归或缺陷复现 | `frontend-acceptance.md` |
| React、Ant Design、ProComponents、Umi、AntV 的开发、设计文档或测试文档 | `antd-developer.md` |
| React/Ant Design E2E、回归或缺陷复现 | `antd-acceptance.md` |

## 派发契约

主智能体的任务消息必须给出：`task_type`、`requirement`、`scope`、`context_ref`、`constraints`、`output_dir` 与验收标准。缺少会影响正确实施的信息时，子智能体应在最终结果中标为 `blocked` 或 `partial`，而不是自行假设。

开发和验收不可并行修改同一文件。开发完成并报告验证结果后，主智能体再把固定提交状态或明确工作区范围交给验收子智能体。验收子智能体不得修改被测源代码，只能新增报告、截图和测试证据。

## 回传格式

每个子智能体的最终消息必须使用以下结构：

```markdown
## 任务结果

- 状态：success | partial | blocked | failed
- 改动：<文件及摘要；验收任务注明未修改源代码>
- 验证：<实际执行的命令与结果，或 N/A>
- 证据：<报告、截图、日志路径>
- 关键决策：<事实与取舍>
- 风险与阻塞：<未解决项>
- 建议下一步：<仅在需要时给出>
```

子智能体完成时直接返回结果；不要伪造跨任务消息、会话 ID 或 Claude/Zcode 专属工具调用。
