# 应用交付 AppStack（`app-stack-*`，93 个命令）

> [SKILL.md 返回](../SKILL.md) · 对象模型 → 高频命令 → 全量索引

## 对象模型

```
应用 application ── 环境 environment（K8s / 主机，可加锁）
    ├── 开发流程 release workflow ── 开发阶段 release stage ── 阶段执行 stage run（含人工卡点）
    ├── 变更请求 change request ── 变更单/部署单 change order ── Job 执行日志
    └── 编排 orchestration、变量组 variable group、全局变量组 global var、Webhook、应用成员
```

## 高频命令

### 应用与环境
```bash
aliyun devops app-stack-list-applications                       # 分页，支持搜索参数见 --help
aliyun devops app-stack-get-application --app-id <id>
aliyun devops app-stack-list-environments --app-id <id>
aliyun devops app-stack-get-environment --app-id <id> --env-id <id>
```
环境锁定/解锁：`app-stack-lock-env` / `app-stack-un-lock-env`（发布窗口管控，动前确认）。

### 变更与部署
```bash
aliyun devops app-stack-create-change-request ...               # 发起变更请求
aliyun devops app-stack-list-app-change-requests ...            # 变更列表
aliyun devops app-stack-list-change-orders ...                  # 部署单列表
aliyun devops app-stack-get-change-order ...                    # 部署单详情/状态
aliyun devops app-stack-list-change-order-job-logs ...          # 部署日志
```
编排：`app-stack-list-app-orchestration` / `app-stack-get-latest-orchestration`（环境当前可用编排）/ `app-stack-get-app-orchestration-export`（导出 YAML）。

### 运行态排障
K8s：`app-stack-get-pod-info` → `app-stack-get-pod-container-log`。主机：`app-stack-get-machine-deploy-log` / `app-stack-find-task-operation-log`。变更单操作：`app-stack-execute-job-action`。

### 人工卡点
`app-stack-pass-release-stage-pipeline-validate` / `app-stack-refuse-release-stage-pipeline-validate`——需用户明确指示。

### 变量组
应用级 `app-stack-get-app-variable-groups`、环境级 `app-stack-get-env-variable-groups`；创建/更新 `app-stack-create-variable-group` / `app-stack-update-variable-group`；跨应用共享用全局变量组 `app-stack-list-global-vars` / `app-stack-get-global-var`。

## 全量命令索引

| 命令 | 说明 |
| --- | --- |
| `app-stack-add-host-list-to-deploy-group` | Add hosts to a deployment group |
| `app-stack-add-host-list-to-host-group` | Add hosts to a host cluster |
| `app-stack-attach-template` | Associate an application with an application template |
| `app-stack-cancel-change-request` | Close change request |
| `app-stack-cancel-execution-release-stage` | Cancel the development stage pipeline run |
| `app-stack-close-change-request` | Complete a change request |
| `app-stack-create-app-members` | Add application member |
| `app-stack-create-app-orchestration` | Create application orchestration |
| `app-stack-create-app-stack-webhook` | Create AppStack Webhook |
| `app-stack-create-app-tag` | Create application label |
| `app-stack-create-application` | Create application |
| `app-stack-create-application-source` | Create application source |
| `app-stack-create-change-order` | Create deploy order |
| `app-stack-create-change-request` | Create change request |
| `app-stack-create-environments` | Create environment |
| `app-stack-create-global-var` | Create global variable group |
| `app-stack-create-variable-group` | Create variable group |
| `app-stack-delete-app-member` | Delete application member |
| `app-stack-delete-app-orchestration` | Delete application orchestration |
| `app-stack-delete-app-stack-webhook` | Delete AppStack Webhook |
| `app-stack-delete-app-tag` | Delete application label |
| `app-stack-delete-application` | Delete application |
| `app-stack-delete-env` | Delete environment |
| `app-stack-delete-global-var` | Delete global variable group |
| `app-stack-delete-host-list-from-deploy-group` | Remove hosts from a deployment group |
| `app-stack-delete-host-list-from-host-group` | Remove hosts from a host cluster |
| `app-stack-delete-variable-group` | Delete variable group |
| `app-stack-detach-template` | Unbind an application template from an application |
| `app-stack-execute-change-request-release-stage` | Execute a development stage pipeline |
| `app-stack-execute-job-action` | Operate environment deploy order |
| `app-stack-find-task-operation-log` | Query deployment job execution logs, which usually contain scheduling details of the downstream deployment engine |
| `app-stack-get-app-orchestration` | Get application orchestration details |
| `app-stack-get-app-orchestration-export` | Export an application orchestration |
| `app-stack-get-app-release-stage-execution-pipeline-job-log` | Query job run log of a development stage pipeline |
| `app-stack-get-app-variable-groups` | Get variable group list details of an application |
| `app-stack-get-app-variable-groups-revision` | Get variable group version of an application |
| `app-stack-get-application` | Get application details |
| `app-stack-get-change-order` | Read the materials and work order status used by the deploy order |
| `app-stack-get-change-request-audit-items` | List approval items associated with a change request |
| `app-stack-get-deployment-revision-info` | Read workload version information |
| `app-stack-get-env-variable-groups` | Get details of variable groups bound to an environment |
| `app-stack-get-environment` | Get environment details |
| `app-stack-get-global-var` | Query global variable group |
| `app-stack-get-kubernetes-object-info` | Read the materials and work order status used by the deploy order |
| `app-stack-get-latest-orchestration` | Get the latest available orchestration of an environment |
| `app-stack-get-machine-deploy-log` | Query host deployment log |
| `app-stack-get-pod-container-log` | Read Pod container logs |
| `app-stack-get-pod-info` | Query Pod information |
| `app-stack-get-release-stage-pipeline-run` | Get development stage pipeline runs |
| `app-stack-get-release-workflow-stage` | Get development stage details |
| `app-stack-get-variable-group` | Query variable group details |
| `app-stack-list-all-release-stage-briefs` | Get summaries of all development stages under a development process |
| `app-stack-list-all-release-workflow-briefs` | List summaries of all development processes under an application |
| `app-stack-list-all-release-workflows` | List all development processes under an application |
| `app-stack-list-app-change-requests` | Search change request list |
| `app-stack-list-app-orchestration` | Get application orchestration list |
| `app-stack-list-app-release-stage-execution-integrated-metadata` | Query integrated change request information of a development stage execution record |
| `app-stack-list-app-release-stage-runs` | Batch query development stage execution records |
| `app-stack-list-app-stack-webhook-history` | Get AppStack Webhook execution history |
| `app-stack-list-app-stack-webhooks` | List AppStack Webhooks |
| `app-stack-list-application-members` | List application members |
| `app-stack-list-application-sources` | List application source details with pagination |
| `app-stack-list-applications` | List application details with pagination |
| `app-stack-list-attached-change-requests` | List change requests associated with a release |
| `app-stack-list-change-order-job-logs` | Query environment deploy order log |
| `app-stack-list-change-order-versions` | View deploy order version list |
| `app-stack-list-change-orders` | Query deploy order list |
| `app-stack-list-change-orders-by-origin` | Query deploy orders by creation source |
| `app-stack-list-change-request-executions` | Query change request development process run records |
| `app-stack-list-change-request-work-items` | Query work items linked to a change request |
| `app-stack-list-environments` | List environment details with pagination |
| `app-stack-list-global-vars` | Query global variable group list |
| `app-stack-list-release-stage-flow-change-requests` | Query release stage integration metadata |
| `app-stack-lock-env` | Lock an environment |
| `app-stack-pass-release-stage-pipeline-validate` | Pass the manual checkpoint |
| `app-stack-refuse-release-stage-pipeline-validate` | Reject manual gate |
| `app-stack-retry-change-request-stage-pipeline` | Retry a development stage run |
| `app-stack-search-app-tag` | Query application labels |
| `app-stack-search-app-templates` | Search application templates |
| `app-stack-skip-change-request-stage-pipeline` | Skip development stage run |
| `app-stack-un-lock-env` | Unlock environment |
| `app-stack-update-app-member` | Update application member |
| `app-stack-update-app-orchestration` | Update application orchestration |
| `app-stack-update-app-stack-webhook` | Update an AppStack Webhook |
| `app-stack-update-app-tag` | Update application label |
| `app-stack-update-application` | Update application |
| `app-stack-update-env` | Update environment |
| `app-stack-update-env-computation-resource` | Associate compute resources with an environment |
| `app-stack-update-global-var` | Update global variable group |
| `app-stack-update-release-stage` | Update development stage |
| `app-stack-update-release-stage-flow` | Update release stage YAML configuration |
| `app-stack-update-resource-instance` | Update resource instance |
| `app-stack-update-variable-group` | Update variable group |
