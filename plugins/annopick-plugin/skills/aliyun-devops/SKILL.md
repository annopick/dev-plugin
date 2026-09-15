---
name: aliyun-devops
description: >
  通过 aliyun devops CLI（阿里云云效 Yunxiao，API 2026-05-25，434 个子命令）操作云效全链路
  DevOps：代码管理 Codeup（仓库/分支/合并请求/文件/代码检测/AI 代码评审）、流水线 Flow
  （触发运行/日志/人工卡点/变量组/主机组）、项目协作 Projex（项目/工作项/迭代/里程碑/工时）、
  应用交付 AppStack（应用/环境/变更单/部署编排）、测试管理 TestHub（测试用例/测试计划）、
  制品仓库 Packages、组织成员 Base 与效能洞察 Insight。当用户提到云效、Yunxiao、Codeup、
  流水线、合并请求/MR、工作项/需求/任务/缺陷、迭代/冲刺、测试用例、测试计划、应用部署、
  变更单、制品/Artifact、云效组织成员，或要求在云效上查询/创建/更新/删除任何资源时，
  必须使用本技能。用户说"跑一下流水线""提个 MR 到云效""查下需求状态"等场景同样触发。
allowed-tools:
  - Bash(aliyun devops *)
  - Bash(aliyun version)
---

# 阿里云云效（Yunxiao）CLI 操作指南

`aliyun devops` 是阿里云 CLI 的云效插件，一个命令对应一个 OpenAPI。输出为 JSON，命令命名遵循 `<域>-<动作>-<对象>` 规律（如 `codeup-list-repositories`、`flow-create-pipeline-run`），因此**先选域、再选动作**是找到正确命令的最快路径。

8 个域的职责划分：

| 前缀 | 域 | 管什么 | 命令数 | 详细参考 |
| --- | --- | --- | --- | --- |
| `codeup-*` | 代码管理 | 仓库、分支、合并请求、文件、commit、保护分支、SSH Key、Webhook、代码检测、AI 评审 | 114 | [reference/codeup.md](reference/codeup.md) |
| `flow-*` | 流水线 | 流水线、运行、Job/步骤日志、人工卡点、变量组、主机组、服务连接、标签 | 85 | [reference/flow.md](reference/flow.md) |
| `projex-*` | 项目协作 | 项目、工作项（需求/任务/缺陷）、迭代、里程碑、版本、工时、标签 | 74 | [reference/projex.md](reference/projex.md) |
| `app-stack-*` | 应用交付 | 应用、环境、开发流程/阶段、变更单、部署编排、变量组 | 93 | [reference/appstack.md](reference/appstack.md) |
| `test-hub-*` | 测试管理 | 测试库、用例、目录、测试计划、执行结果、缺陷关联 | 26 | [reference/testhub.md](reference/testhub.md) |
| `base-*` | 组织与成员 | 组织、成员、部门、角色、自动化事件/定时任务 | 34 | [reference/base.md](reference/base.md) |
| `packages-*` | 制品仓库 | 制品、版本、仓库 | 6 | [reference/packages.md](reference/packages.md) |
| `insight-*` | 效能洞察 | 查询清单 | 1 | 见下方说明 |

`insight-list-queries` 是效能洞察唯一命令（列出可用的洞察查询）。`aliyun devops version` 打印插件版本。

## 第一步：确认凭据与组织 ID

所有命令依赖两个环境变量（也可用同名 flag 覆盖）：

| 环境变量 | 对应 flag | 获取方式 |
| --- | --- | --- |
| `ALIBABA_CLOUD_YUNXIAO_ACCESS_TOKEN` | `--yunxiao-access-token` | 云效 → 个人设置 → 个人访问令牌 |
| `ALIBABA_CLOUD_YUNXIAO_ORGANIZATION_ID` | `--organization-id` | 见下方发现流程 |

会话内第一次执行云效操作前，先检查这两个值。organization-id 未知时按以下顺序发现（前两步均不需要组织 ID）：

```bash
# 首选：列出组织（注意：专属版/部分租户环境此接口返回 404，属已知现象，直接走下一步）
aliyun devops base-list-organizations

# 次选：用个人令牌反查令牌所属用户及其组织（无需额外参数，token 自动从环境变量读取；
# 实测在 base-list-organizations 404 的环境仍可用，组织 ID 在响应的 lastOrganization 字段）
aliyun devops base-get-user-by-token --cli-query 'lastOrganization'

# 拿到目标组织后 export，之后所有命令复用：
export ALIBABA_CLOUD_YUNXIAO_ORGANIZATION_ID=<id>
```

兜底技巧（实测）：codeup 等部分域的命令传空 `--organization-id ''` 也能正常访问（endpoint 已按租户隔离）；遇到 organization-id 缺失报错时可先用空值探测命令连通性，再补正式值。

token 缺失或返回 401/无权限类错误时，停止执行并向用户说明配置方法（云效网页端 头像 → 个人设置 → 个人访问令牌），不要猜测或重试。organization-id 建议在单次会话内 export 一次反复使用，避免每条命令都要求用户提供。

## 通用调用约定

这些规则适用于全部 434 个命令，掌握后可以举一反三：

- **输出是 JSON**。配合 `--cli-query <JMESPath>` 只取需要的字段，减少噪音，例如 `--cli-query 'result[].{name:name,id:id}'`。
- **分页参数**统一为 `--page`（从 1 开始）与 `--per-page`（常见上限 100 或 200）。列表命令加 `--pager` 可自动合并所有页。
- **必填参数**在 `--help` 中标注 `(required)`。执行前先跑 `aliyun devops <命令> --help` 确认参数名与格式，这是零成本的（纯本地，不发请求）。
- **`--cli-dry-run`** 只打印将要发送的请求、不真正执行——用于预检复杂参数（尤其 JSON 串参数）是否合法。
- **复杂筛选参数是 JSON 字符串**（如 projex 的 `--conditions`、flow 的 `--params`）。先 `--cli-dry-run` 验证 JSON 转义正确再实际执行。
- 命令动词语义：`list-*` 分页列表 / `get-*` 详情 / `search-*` 条件搜索 / `create-*`、`update-*`、`delete-*` 增改删 / `find-*` 深度查询。
- 同一对象常有新旧两套命令（如 `codeup-get-change-request` 与 `codeup-get-merge-request(old)`），标注 `(old)` 的是旧版接口，优先用新版。

## 写操作安全约定

云效是团队共享的生产系统。读取类命令（list/get/search）可直接执行；**写操作（create/update/merge/execute）执行前向用户复述关键参数**（在哪建、改什么）；**删除与不可逆操作（delete/archive/stop/close/transfer）必须获得用户明确确认后才执行**，确认时列出对象名称而不只是 ID。触发流水线运行、合并 MR、部署等影响他人的操作同理。

## 高频工作流

跨域组合的典型任务，命令细节见对应 reference 文件。

**日常代码流（codeup）**：`codeup-list-repositories`（找仓库 ID）→ `codeup-create-branch` → 本地开发推送 → `codeup-create-change-request`（提 MR，可加 `--trigger-ai-review-run`）→ `codeup-list-change-request-ci-check-list`（查 CI 状态）→ `codeup-merge-change-request`（合并前需用户确认）。

**CI/CD 流（flow）**：`flow-list-pipelines`（找流水线 ID）→ `flow-create-pipeline-run`（触发）→ `flow-get-latest-pipeline-run` 轮询状态 → `flow-get-pipeline-job-run-log` / `flow-get-pipeline-job-step-log` 排障 → 卡在人工验证时 `flow-pass-pipeline-validate` / `flow-refuse-pipeline-validate`（需用户确认）→ 失败任务 `flow-retry-pipeline-job-run` 或 `flow-rerun-pipeline-job-run`。

**需求协作流（projex）**：`projex-search-projects`（找项目 ID）→ `projex-search-workitems --category Req`（搜工作项，`--conditions` 为 JSON 筛选）→ `projex-create-workitem` / `projex-update-workitem` → `projex-list-workitem-activities`（查动态）。工作项类型：`Req` 需求 / `Task` 任务 / `Bug` 缺陷。

**发布流（app-stack + flow）**：`app-stack-list-applications` → `app-stack-list-environments` → `app-stack-create-change-request`（发起变更）→ `app-stack-list-change-orders` / `app-stack-get-change-order`（跟进部署单）→ `app-stack-get-pod-container-log` / `app-stack-get-machine-deploy-log`（排障）。

**测试流（test-hub）**：`test-hub-list-test-repo` → `test-hub-search-testcases` → `test-hub-create-test-plan` → `test-hub-add-test-plan-testcases` → `test-hub-get-test-plan-progress-rate`（进度统计）。

## Reference 文件导航

每个域的参考文件包含：对象模型说明、高频命令参数详解、全量命令索引（本技能已收录全部 434 个命令）、可直接套用的命令示例。**执行域内任务前先读对应文件**；SKILL.md 未覆盖的命令一定能在对应文件的索引表中找到，索引表没有的再查 `--help`。
