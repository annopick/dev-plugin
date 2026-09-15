# 代码管理 Codeup（`codeup-*`，114 个命令）

> [SKILL.md 返回](../SKILL.md) · 对象模型 → 高频命令 → 全量索引

## 对象模型

```
组织 ── 代码组(namespace/group) ── 仓库(repository)
                                    ├── 分支 branch ── 保护分支 protected branch
                                    ├── 标签 tag
                                    ├── 文件/目录（blob、blame）
                                    ├── commit（状态、评论、check run）
                                    └── 合并请求 change request（即 MR：版本 patch-set、评论、CI 检查、AI 评审）
```

关键 ID 约定：`--repository-id` 接受仓库 ID 或 **URL-Encoder 编码的全路径**；合并请求命令多用数字型 `--project-id`（即仓库的数字 ID）。新建 MR 前先 `codeup-get-repository` 拿到数字 ID。

## 高频命令

### 仓库发现
```bash
aliyun devops codeup-list-repositories --search <关键词>          # 按路径模糊搜索
aliyun devops codeup-list-repositories --archived true            # 只看已归档
aliyun devops codeup-get-repository --repository-id <id或编码路径>
```
`--order-by` 可选 `created_at/name/path/last_activity_at`；`--sort` asc/desc。代码组用 `codeup-list-namespaces`、组内仓库用 `codeup-list-group-repositories`。

### 合并请求（MR）
创建 MR 必填 6 参数（`codeup-create-change-request`）：`--repository-id`、`--source-project-id`（int）、`--source-branch`、`--target-project-id`（int）、`--target-branch`、`--title`。可选：`--reviewer-user-ids id1 id2`（list）、`--trigger-ai-review-run true`（同时触发 AI 评审）、`--work-item-ids`（关联 projex 工作项）。

```bash
aliyun devops codeup-list-change-requests --repository-id <id> --search <标题关键词> --state open
aliyun devops codeup-get-change-request --repository-id <id> --mr-id <数字>     # 或 --local-id
aliyun devops codeup-list-change-request-ci-check-list ...                     # MR 的 CI 检查状态
aliyun devops codeup-merge-change-request ...                                  # 合并——执行前需用户确认
```

### 分支与文件
```bash
aliyun devops codeup-create-branch --repository-id <id> --branch-name <名> --ref <基于的commit/分支>
aliyun devops codeup-list-branches --repository-id <id>
aliyun devops codeup-get-file-blobs ...            # 读文件内容
aliyun devops codeup-update-file ...               # 改单个文件（API 提交）
aliyun devops codeup-commit-multiple-files ...     # 一次 commit 多个文件增删改
```
`codeup-commit-multiple-files` 适合让 agent 直接产出代码变更而不依赖本地 git push；参数含文件列表 JSON，先 `--cli-dry-run` 验证。

### AI 代码评审
`codeup-create-ai-review-run` 触发 → `codeup-sync-ai-review-run` 同步状态 → `codeup-get-fix-issue-record-context` / `codeup-update-fix-issue-record` 读写智能修复记录。

## 全量命令索引

| 命令 | 说明 |
| --- | --- |
| `codeup-archive-repository` | Archive a code repository |
| `codeup-attach-labels-to-change-request` | Associate label with merge request |
| `codeup-close-change-request` | Close merge request |
| `codeup-commit-multiple-files` | Commit multiple file changes |
| `codeup-create-ai-review-run` | Trigger AI code review |
| `codeup-create-branch` | Create branch |
| `codeup-create-change-request` | Create merge request |
| `codeup-create-change-request-comment` | Create merge request comment |
| `codeup-create-check-run` | Create run check |
| `codeup-create-commit-comment` | Add a comment to a single commit |
| `codeup-create-commit-status` | Create commit status |
| `codeup-create-deploy-key` | Create deploy key |
| `codeup-create-file` | Create file |
| `codeup-create-group` | Create code group |
| `codeup-create-group-member` | Add code group member |
| `codeup-create-project-label` | Create project label |
| `codeup-create-protected-branch` | Create protected branch |
| `codeup-create-push-rule` | Create push rule |
| `codeup-create-quality-check-plan` | Create code detection scheme |
| `codeup-create-quality-check-task` | Create code detection task |
| `codeup-create-quality-scan-record` | Create scan record |
| `codeup-create-repository` | Create code repository |
| `codeup-create-repository-member` | Add code repository member |
| `codeup-create-ssh-key` | Create SSH Key |
| `codeup-create-tag` | Create label |
| `codeup-create-web-hook` | Create Webhook |
| `codeup-delete-branch` | Delete branch |
| `codeup-delete-change-request-comment` | Delete merge request comment |
| `codeup-delete-file` | Delete file |
| `codeup-delete-group-member` | Remove code group member |
| `codeup-delete-group-team-member` | Remove code group department member |
| `codeup-delete-project-label` | Delete project category |
| `codeup-delete-protected-branch` | Delete protected branch |
| `codeup-delete-push-rule` | Delete push rule |
| `codeup-delete-quality-check-plan` | Delete detection scheme |
| `codeup-delete-quality-check-task` | Delete detection task |
| `codeup-delete-repository` | Delete code repository |
| `codeup-delete-repository-member` | Remove code repository member |
| `codeup-delete-repository-team-member` | Remove code repository department member |
| `codeup-delete-ssh-key` | Delete SSH Key |
| `codeup-delete-tag` | Delete label |
| `codeup-delete-web-hook` | Delete WebHook |
| `codeup-disable-deploy-key` | Disable deploy key |
| `codeup-enable-deploy-key` | Start deploy key |
| `codeup-get-branch` | Query branch information |
| `codeup-get-change-request` | Query merge request |
| `codeup-get-change-request-labels` | Get labels of a merge request |
| `codeup-get-change-request-tree` | Query the changed file tree of a merge request |
| `codeup-get-check-run` | Query run check |
| `codeup-get-commit` | Query commit information |
| `codeup-get-compare` | Query code comparison content |
| `codeup-get-file-blame` | Get file blame information |
| `codeup-get-file-blobs` | Query file content |
| `codeup-get-fix-issue-record-context` | Get smart fix record context |
| `codeup-get-member-https-clone-username` | Query user clone account |
| `codeup-get-merge-request` | Query merge request (old) |
| `codeup-get-namespace` | Query code group information |
| `codeup-get-project-labels` | Get the project category list |
| `codeup-get-protected-branch` | Query protected branch |
| `codeup-get-push-rule` | Query push rule |
| `codeup-get-quality-check-plan` | Query detection scheme details |
| `codeup-get-quality-check-task` | Query the detection task associated with the code repository |
| `codeup-get-quality-scan-profile` | Query code repository scan configuration |
| `codeup-get-repository` | Query code repository |
| `codeup-get-ssh-key` | Query SSH Key |
| `codeup-get-web-hook` | Query WebHook |
| `codeup-list-branches` | Query branch list |
| `codeup-list-change-request-ci-check-list` | Query merge request CI automated check list |
| `codeup-list-change-request-patch-sets` | Query merge request version list |
| `codeup-list-change-requests` | Query merge request list |
| `codeup-list-check-runs` | Query run check list |
| `codeup-list-commit-statuses` | Query commit status list |
| `codeup-list-commits` | Query commit list |
| `codeup-list-files` | Query file tree |
| `codeup-list-group-members` | Query code group member list |
| `codeup-list-group-repositories` | Query code repository list under a code group |
| `codeup-list-merge-request-comments` | Query comment list |
| `codeup-list-merge-requests` | Query merge request list (old) |
| `codeup-list-namespaces` | Query code group list |
| `codeup-list-protected-branches` | Query protected branch list |
| `codeup-list-push-rules` | Query push rule list |
| `codeup-list-quality-check-plan` | Query detection scheme list |
| `codeup-list-quality-check-rule-package` | Query detection rule package list |
| `codeup-list-repositories` | Query code repository list |
| `codeup-list-repository-members` | Query code repository member list |
| `codeup-list-ssh-keys` | Query SSH Key list |
| `codeup-list-tags` | Query label list |
| `codeup-list-template-repositories` | Query template code repository list |
| `codeup-list-user-resources` | Query resources the user has permission on |
| `codeup-list-user-ssh-keys` | Query SSH Key list of the specified user |
| `codeup-list-web-hooks` | Query Webhook list |
| `codeup-merge-change-request` | Merge a merge request |
| `codeup-reopen-change-request` | Reopen a merge request |
| `codeup-review-change-request` | Review a merge request |
| `codeup-sync-ai-review-run` | Sync AI code review run status |
| `codeup-sync-scan-pipeline-steps` | Sync scan pipeline step configuration |
| `codeup-transfer-repository` | Transfer code repository |
| `codeup-update-change-request` | Update merge request basic information |
| `codeup-update-change-request-comment` | Update merge request comment |
| `codeup-update-change-request-related-person` | Update merge request stakeholders |
| `codeup-update-check-run` | Update run check |
| `codeup-update-file` | Update file content |
| `codeup-update-fix-issue-record` | Write back intelligent fix result |
| `codeup-update-group` | Update code group |
| `codeup-update-group-member` | Change the permissions of a code group member |
| `codeup-update-project-label` | Update project category label |
| `codeup-update-protected-branch` | Update protected branch |
| `codeup-update-push-rule` | Update push rule |
| `codeup-update-quality-check-plan` | Update detection scheme |
| `codeup-update-quality-check-task` | Update detection task |
| `codeup-update-quality-scan-result` | Update scan result |
| `codeup-update-repository` | Update code repository |
| `codeup-update-repository-member` | Change the permissions of a code repository member |
| `codeup-update-web-hook` | Update a WebHook |
