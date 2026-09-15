# 项目协作 Projex（`projex-*`，74 个命令）

> [SKILL.md 返回](../SKILL.md) · 对象模型 → 高频命令 → 全量索引

## 对象模型

```
项目 project（space-id）── 工作项 workitem（需求 Req / 任务 Task / 缺陷 Bug）
    ├── 迭代 sprint ── 里程碑 milestone ── 版本 version
    ├── 工时：预估 estimated-effort / 实际 effort-record
    └── 关联：工作项关联、外部资源关联、测试用例关联
```

工作项的**类型 ID 不是枚举字符串**：每个项目里 Req/Task/Bug 各有具体 `workitem-type-id`，创建前必须先 `projex-list-workitem-types --space-id <项目id>` 查到。

## 高频命令

### 项目发现
```bash
aliyun devops projex-search-projects
aliyun devops projex-get-project --project-id <id>
```

### 工作项查询（`projex-search-workitems`）
必填：`--category`（Req、Task、Bug 可逗号多选）、`--space-id`（`--space-type` 默认 Project，程序用 program）。筛选用 `--conditions` 传 JSON 串，结构为 `{"conditionGroups":[[条件对象,...]]}`，常用条件对象：

| 筛选 | 条件对象 |
| --- | --- |
| 标题包含"登录" | `{"fieldIdentifier":"subject","operator":"CONTAINS","value":["登录"],"className":"string","format":"input"}` |
| 指定状态 | `{"fieldIdentifier":"status","operator":"CONTAINS","value":["<状态id>"],"className":"status","format":"list"}` |
| 负责人 | `{"fieldIdentifier":"assignedTo","operator":"CONTAINS","value":["<userId>"],"className":"user","format":"list"}` |
| 创建时间区间 | `{"fieldIdentifier":"gmtCreate","operator":"BETWEEN","value":["2024-04-01 00:00:00"],"toValue":"2024-06-30 23:59:59","className":"dateTime","format":"input"}` |

```bash
aliyun devops projex-search-workitems --category Req --space-id <id> \
  --conditions '{"conditionGroups":[[{"fieldIdentifier":"subject","operator":"CONTAINS","value":["登录"],"className":"string","format":"input"}]]}'
```

### 创建/更新工作项
`projex-create-workitem` 必填：`--subject`、`--space-id`、`--workitem-type-id`（先查类型）、`--assigned-to`（负责人 userId，用 `base-search-members` 查）。常用可选：`--description`（配 `--format-type MARKDOWN|RICHTEXT`）、`--sprint`、`--parent-id`、`--labels id1 id2`、`--participants`、`--verifier`、`--custom-field-values`（JSON）。

`projex-update-workitem` 改字段；`projex-get-workitem` 详情；`projex-list-workitem-activities` 动态；`projex-list-workitem-comments` / `projex-create-workitem-comment` 评论。

### 迭代与规划
`projex-list-sprints` / `projex-get-sprint` / `projex-update-sprint`；里程碑 `projex-list-milestones`；版本 `projex-list-versions`；工时 `projex-create-effort-record`（实际）/ `projex-create-estimated-effort`（预估）。

## 全量命令索引

| 命令 | 说明 |
| --- | --- |
| `projex-create-archived-project` | Archive a project |
| `projex-create-effort-record` | Log actual work hours |
| `projex-create-estimated-effort` | Log estimated work hours |
| `projex-create-label` | Create label |
| `projex-create-milestone` | Create milestone |
| `projex-create-project` | Create project |
| `projex-create-project-member` | Add project member |
| `projex-create-project-role` | Add project role |
| `projex-create-sprint` | Create sprint |
| `projex-create-starred-project` | Favorite project |
| `projex-create-starred-workitem` | Favorite work item |
| `projex-create-version` | Create version |
| `projex-create-workitem` | Create work item |
| `projex-create-workitem-attachment` | Upload work item attachment |
| `projex-create-workitem-comment` | Create work item comment |
| `projex-create-workitem-ext-relation-record` | Create work item association with external resource |
| `projex-create-workitem-relation-record` | Create work item association |
| `projex-create-workitem-testcase-relation-record` | Create work item association with test case |
| `projex-delete-archived-project` | Unarchive project |
| `projex-delete-milestone` | Delete milestone |
| `projex-delete-project` | Delete project |
| `projex-delete-project-member` | Delete project member |
| `projex-delete-project-role` | Delete project role |
| `projex-delete-starred-project` | Unfavorite project |
| `projex-delete-starred-workitem` | Unfavorite work item |
| `projex-delete-version` | Delete version |
| `projex-delete-workitem` | Delete work item |
| `projex-delete-workitem-ext-relation-record` | Delete work item linked external resource |
| `projex-delete-workitem-relation-record` | Delete work item linked item |
| `projex-delete-workitem-testcase-relation-record` | Delete work item linked test case |
| `projex-get-project` | Get a project |
| `projex-get-project-ai-config` | Get project AI configuration |
| `projex-get-project-template-field-config` | Get project template field configuration |
| `projex-get-sprint` | Get a sprint |
| `projex-get-workitem` | Get work item |
| `projex-get-workitem-file` | Get work file information |
| `projex-get-workitem-type` | Get work item type details |
| `projex-get-workitem-type-description-config` | Get the description template configuration of a work item type in a project |
| `projex-get-workitem-type-field-config` | Get the field configuration of a work item type in a project |
| `projex-get-workitem-workflow` | Get status list of a work item workflow |
| `projex-get-workitem-workflow-info` | Get work item workflow information |
| `projex-list-all-project-roles` | Get the list of all project roles in an organization |
| `projex-list-all-workitem-types` | Get the list of all work item types in an organization |
| `projex-list-current-user-effort-records` | Get a user's actual work hours details; the interval between end time and start time cannot exceed 6 months |
| `projex-list-effort-records` | Get actual work hours details |
| `projex-list-estimated-efforts` | Get estimated work hours details |
| `projex-list-labels` | Get label list |
| `projex-list-milestones` | Get the milestone list |
| `projex-list-program-versions` | Get the program version list |
| `projex-list-project-members` | Get the project member list |
| `projex-list-project-roles` | Get the project role list |
| `projex-list-project-templates` | Get a project template |
| `projex-list-sprints` | Get the sprint list |
| `projex-list-versions` | Get version list |
| `projex-list-workitem-activities` | Get work item activities |
| `projex-list-workitem-attachments` | Get work item attachment list |
| `projex-list-workitem-comments` | Get work item comment list |
| `projex-list-workitem-ext-relation-records` | Query external resources linked to a work item |
| `projex-list-workitem-relation-records` | Get work item related items |
| `projex-list-workitem-relation-workitem-types` | Get list of work item types that can be associated with a work item |
| `projex-list-workitem-testcase-relation-records` | Query test cases linked to a work item |
| `projex-list-workitem-types` | Get the work item type list in a project |
| `projex-search-programs` | Search programs |
| `projex-search-projects` | Search projects |
| `projex-search-workitems` | Search work items |
| `projex-update-custom-field` | Update custom field |
| `projex-update-effort-record` | Update logged actual work hours |
| `projex-update-estimated-effort` | Update logged estimated work hours |
| `projex-update-label` | Update label |
| `projex-update-milestone` | Update milestone |
| `projex-update-project` | Update project |
| `projex-update-sprint` | Update sprint |
| `projex-update-version` | Update version |
| `projex-update-workitem` | Update work item |
