# 组织与成员 Base（`base-*`，34 个命令）

> [SKILL.md 返回](../SKILL.md) · 对象模型 → 高频命令 → 全量索引

## 对象模型

```
组织 organization ── 部门 department ── 成员 member（绑定信息/角色 role）
自动化：事件任务 event task（事件触发）、定时任务 scheduled task
```

## 高频命令

### 组织发现（无需 organization-id）
```bash
aliyun devops base-list-organizations        # 首选：列出组织
aliyun devops base-get-user-by-token         # 次选：令牌自检，组织 ID 在响应的 lastOrganization 字段
```
已知现象：专属版/部分租户环境下 `base-list-organizations` 返回 404，此时改用 `base-get-user-by-token` 反查（组织 ID 取 `lastOrganization` 字段，可加 `--cli-query 'lastOrganization'` 直接提取）。另有兜底：codeup 等域的命令传空 `--organization-id ''` 也能访问（endpoint 已按租户隔离），可用空值探测连通性。

### 成员查询
```bash
aliyun devops base-list-members ...          # 全量成员
aliyun devops base-search-members ...        # 按关键词搜（拿 userId 给 projex 指派用）
aliyun devops base-get-member --userId <id>
```
projex 指派工作项（`--assigned-to`）、codeup 评审人（`--reviewer-user-ids`）需要的 userId 都从这里查。部门树：`base-list-departments` / `base-list-department-ancestors`；角色：`base-list-roles` / `base-get-role`。

### 自动化任务
事件任务：`base-list-automation-event-tasks`、`base-get-automation-event-task`、启用暂停 `base-update-automation-event-task-enabled`；事件类型目录 `base-list-automation-event-types`（建任务前先查可订阅的事件）。
定时任务：`base-list-automation-scheduled-tasks`、立即执行 `base-execute-automation-scheduled-task`、启用暂停 `base-update-automation-scheduled-task-enabled`。
执行记录：`base-list-automation-event-task-runs` / `base-list-automation-scheduled-task-runs`。

## 全量命令索引

| 命令 | 说明 |
| --- | --- |
| `base-create-automation-event-task` | Create an event task |
| `base-create-automation-scheduled-task` | Create scheduled task |
| `base-delete-automation-event-task` | Delete an event task |
| `base-delete-automation-scheduled-task` | Delete scheduled task |
| `base-execute-automation-scheduled-task` | Run scheduled task immediately |
| `base-get-automation-event-task` | Query event task details |
| `base-get-automation-event-type-fields` | Query event field catalog |
| `base-get-automation-scheduled-task` | Query scheduled task details |
| `base-get-automation-scheduled-task-capabilities` | Query scheduled task channel availability |
| `base-get-bind-info` | Get binding information of a single member |
| `base-get-department` | Query organization department information |
| `base-get-member` | Query member information |
| `base-get-role` | Query role information |
| `base-get-user-by-token` | Query the corresponding user information by personal access token |
| `base-list-automation-event-task-runs` | Query event task execution records |
| `base-list-automation-event-tasks` | Query event task list |
| `base-list-automation-event-types` | Query event type catalog |
| `base-list-automation-scheduled-task-runs` | Query scheduled task execution records |
| `base-list-automation-scheduled-tasks` | Query scheduled task list |
| `base-list-bind-info` | List binding information of a specific type for organization members |
| `base-list-department-ancestors` | Query all parent departments of a department in the organization |
| `base-list-departments` | Query organization department list |
| `base-list-members` | Query member list |
| `base-list-org-domains` | Query enterprise domain list |
| `base-list-organizations` | Query organization list |
| `base-list-roles` | Query organization role list |
| `base-read-member-by-user` | Query member information |
| `base-register-member` | Register organization member |
| `base-search-members` | Search member list |
| `base-update-automation-event-task` | Update event task |
| `base-update-automation-event-task-enabled` | Enable or pause an event task |
| `base-update-automation-scheduled-task` | Update scheduled task |
| `base-update-automation-scheduled-task-enabled` | Enable or pause scheduled task |
| `base-update-member` | Update member information |
