# 流水线 Flow（`flow-*`，85 个命令）

> [SKILL.md 返回](../SKILL.md) · 对象模型 → 高频命令 → 全量索引

## 对象模型

```
流水线 pipeline ── 运行 pipeline run ── Job（按阶段分类）── Step（步骤，日志可下载）
     ├── 流水线分组 group / 标签 tag / 关联关系 relation
     └── 配套资源：变量组 variable-group、主机组 host-group、服务连接 service-connection、
         服务凭证 service-credential、VPC 构建集群 build-group、部署单 vm-deploy-order
```

状态枚举（`--status-list`）：`SUCCESS / RUNNING / FAIL / CANCELED / WAITING`（WAITING 即卡在人工验证）。

## 高频命令

### 触发与跟踪
```bash
aliyun devops flow-list-pipelines --pipeline-name <名>            # per-page 上限 30
aliyun devops flow-create-pipeline-run --pipeline-id <id>         # 触发运行
aliyun devops flow-get-latest-pipeline-run --pipeline-id <id>     # 最新一次运行
aliyun devops flow-list-pipeline-runs --pipeline-id <id>          # 历史运行
aliyun devops flow-get-pipeline-run --pipeline-id <id> --run-id <id>
```
带参数运行用 `--params` 传 JSON 串（如 `{"envs":{"KEY":"val"},"runningBranchs":{"仓库地址":"分支"}}`），先 `--cli-dry-run` 验证转义。

空结果判读：列表响应带 `x-total` 响应头。`x-total: 0` 且换个域（如 codeup）有数据返回，说明凭据与组织 ID 有效、该域确实没有资源——直接向用户报告"未找到"，不要反复换参数重试。

### 日志排障
```bash
aliyun devops flow-get-pipeline-job-run-log --pipeline-id <id> --run-id <id> --job-id <id>
aliyun devops flow-get-pipeline-job-steps ...                      # 步骤列表
aliyun devops flow-get-pipeline-job-step-log ...                   # 步骤日志
aliyun devops flow-get-pipeline-job-step-log-url ...               # 日志下载 URL
```

### 运行控制（影响流水线状态，执行前需用户确认）
`flow-stop-pipeline-job-run`（终止单 Job）、`flow-update-pipeline-run`（终止整个 run）、`flow-retry-pipeline-job-run`（失败重试）、`flow-rerun-pipeline-job-run`（重跑）、`flow-skip-pipeline-job-run`（跳过）。

### 人工卡点
`flow-pass-pipeline-validate`（通过）/ `flow-refuse-pipeline-validate`（拒绝）——这是替人做决策的命令，必须用户明确指示后才执行。

### 部署单（主机部署）
`flow-get-vm-deploy-order` → `flow-get-vm-deploy-machine-log` 排障 → `flow-retry-vm-deploy-machine` / `flow-skip-vm-deploy-machine` / `flow-resume-vm-deploy-order` / `flow-stop-vm-deploy-order`。

## 全量命令索引

| 命令 | 说明 |
| --- | --- |
| `flow-add-pipeline-relations` | Add pipeline association |
| `flow-add-to-pipeline-group` | Add a pipeline to a pipeline group |
| `flow-create-build-group` | Create managed VPC build cluster |
| `flow-create-flow-tag` | Create label |
| `flow-create-flow-tag-group` | Create label category |
| `flow-create-host-group` | Create host group |
| `flow-create-pipeline` | Create pipeline |
| `flow-create-pipeline-group` | Create pipeline group |
| `flow-create-pipeline-run` | Run pipeline |
| `flow-create-resource-member` | Insert resource member |
| `flow-create-service-auth` | Create service authorization |
| `flow-create-service-connection` | Create service connection |
| `flow-create-service-credential` | Create service credential |
| `flow-create-ssh-key` | Create enterprise public key |
| `flow-create-variable-group` | Create variable group |
| `flow-delete-flow-tag` | Delete label |
| `flow-delete-flow-tag-group` | Delete label category |
| `flow-delete-host-group` | Delete host group |
| `flow-delete-machine-group-machines` | Delete machine from host group |
| `flow-delete-pipeline` | Delete pipeline |
| `flow-delete-pipeline-group` | Delete pipeline group |
| `flow-delete-pipeline-relations` | Delete pipeline association |
| `flow-delete-resource-member` | Delete resource member |
| `flow-delete-variable-group` | Delete variable group |
| `flow-execute-pipeline-job-action` | Run follow-up action of pipeline job |
| `flow-execute-pipeline-job-run` | Manually run a pipeline job |
| `flow-get-build-resource-network-status` | Check VPC build resources and network |
| `flow-get-flow-tag-group` | Get label category |
| `flow-get-host-group` | Get host group |
| `flow-get-latest-pipeline-run` | Get the latest pipeline run information |
| `flow-get-pipeline` | Get pipeline details |
| `flow-get-pipeline-artifact-url` | Get pipeline build artifact download URL |
| `flow-get-pipeline-debug-websocket-url` | Get pipeline task debug URL |
| `flow-get-pipeline-emas-artifact-url` | Get temporary download URL for pipeline emas build artifacts |
| `flow-get-pipeline-group` | Get pipeline group |
| `flow-get-pipeline-job-run-log` | Query job run log |
| `flow-get-pipeline-job-step-log` | Get pipeline task step logs |
| `flow-get-pipeline-job-step-log-url` | Get download URL for pipeline task step logs |
| `flow-get-pipeline-job-steps` | Get pipeline task step list |
| `flow-get-pipeline-run` | Get pipeline run |
| `flow-get-pipeline-scan-report-url` | Get scan report download URL |
| `flow-get-variable-group` | Get variable group |
| `flow-get-vm-deploy-machine-log` | Query machine deployment log |
| `flow-get-vm-deploy-order` | Get deploy order details |
| `flow-list-flow-tag-groups` | Get label category list |
| `flow-list-host-groups` | Get host group list |
| `flow-list-pipeline-group-pipelines` | Get pipeline list under a pipeline group |
| `flow-list-pipeline-groups` | Get pipeline group list |
| `flow-list-pipeline-job-historys` | Get execution history of a pipeline task |
| `flow-list-pipeline-jobs` | Get pipeline execution jobs by job category |
| `flow-list-pipeline-relations` | Get pipeline association list |
| `flow-list-pipeline-runs` | Get pipeline run list |
| `flow-list-pipelines` | Get pipeline list |
| `flow-list-resource-members` | Get the resource member list |
| `flow-list-security-groups` | Query security group list |
| `flow-list-service-auths` | Get service authorization list |
| `flow-list-service-connections` | Get service connection list |
| `flow-list-service-credentials` | Get service certificate list |
| `flow-list-variable-groups` | Get variable group list |
| `flow-list-vpc-regions` | Query supported VPC region list |
| `flow-list-vpc-zones` | Query availability zone list |
| `flow-list-vpcs` | Query VPC list |
| `flow-list-vswitchs` | Query switch list |
| `flow-pass-pipeline-validate` | Pass the manual checkpoint |
| `flow-refuse-pipeline-validate` | Reject manual gate |
| `flow-rerun-pipeline-job-run` | Rerun a pipeline job |
| `flow-resume-vm-deploy-order` | Resume deploy order run |
| `flow-retry-pipeline-job-run` | Retry a pipeline job run |
| `flow-retry-vm-deploy-machine` | Retry machine deployment |
| `flow-skip-pipeline-job-run` | Skip pipeline job run |
| `flow-skip-vm-deploy-machine` | Skip host deployment |
| `flow-stop-pipeline-job-run` | Terminate pipeline job run |
| `flow-stop-vm-deploy-order` | Terminate machine deployment |
| `flow-update-flow-tag` | Update label |
| `flow-update-flow-tag-group` | Update label category |
| `flow-update-host-group` | Update a host group |
| `flow-update-kubernetes-kube-config` | Update the Kubernetes cluster name and config file |
| `flow-update-pipeline` | Update pipeline |
| `flow-update-pipeline-base-info` | Update pipeline basic information |
| `flow-update-pipeline-group` | Update pipeline group |
| `flow-update-pipeline-run` | Terminate pipeline run |
| `flow-update-resource-member` | Update resource member |
| `flow-update-resource-owner` | Transfer resource object owner |
| `flow-update-ssh-key` | Reset the enterprise public key |
| `flow-update-variable-group` | Update variable group |
