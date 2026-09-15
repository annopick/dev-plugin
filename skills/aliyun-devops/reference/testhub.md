# 测试管理 TestHub（`test-hub-*`，26 个命令）

> [SKILL.md 返回](../SKILL.md) · 对象模型 → 高频命令 → 全量索引

## 对象模型

```
测试库 test repo ── 目录 directory ── 测试用例 testcase（属性/步骤，评论）
测试计划 test plan ── 关联用例 ── 执行结果 test result（可关联缺陷 bug）
```

## 高频命令

### 测试库与用例
```bash
aliyun devops test-hub-list-test-repo                # 找测试库 ID（后续命令都要）
aliyun devops test-hub-list-directories ...          # 用例目录树
aliyun devops test-hub-search-testcases ...          # 搜索用例
aliyun devops test-hub-get-testcase ...              # 用例详情
```
创建用例前先 `test-hub-get-testcase-field-config` 查字段配置（哪些字段必填、取值范围），再 `test-hub-create-testcase` / `test-hub-update-testcase`。用例评论：`test-hub-create-testcase-comment` / `test-hub-list-testcase-comments`。

### 测试计划与执行
```bash
aliyun devops test-hub-create-test-plan ...
aliyun devops test-hub-list-test-plan ...
aliyun devops test-hub-add-test-plan-testcases ...   # 往计划里加用例
aliyun devops test-hub-get-test-plan-progress-rate ...  # 执行进度统计
aliyun devops test-hub-update-test-result ...        # 回填执行结果
```
缺陷关联：`test-hub-create-test-result-bug-relation` / `test-hub-list-test-result-bug-relations` / `test-hub-delete-test-result-bug-relation`——把失败用例和 projex 的 Bug 工作项串起来。

## 全量命令索引

| 命令 | 说明 |
| --- | --- |
| `test-hub-add-test-plan-testcases` | Add test cases to a test plan |
| `test-hub-create-directory` | Create test case directory |
| `test-hub-create-test-plan` | Create test plan |
| `test-hub-create-test-plan-testcase-comment` | Create test plan case comment |
| `test-hub-create-test-repo` | Create test repository |
| `test-hub-create-test-result-bug-relation` | Bugs linked to the test result |
| `test-hub-create-testcase` | Create test case |
| `test-hub-create-testcase-comment` | Create test case comment |
| `test-hub-delete-test-result-bug-relation` | Unlink the bug associated with a test result |
| `test-hub-delete-testcase` | Delete test case |
| `test-hub-get-test-plan-progress-rate` | Get test plan case execution progress statistics |
| `test-hub-get-test-plan-result-directory-list` | Get test plan result directory list |
| `test-hub-get-test-result-list` | Get test case list in test plan |
| `test-hub-get-testcase` | Get test case information |
| `test-hub-get-testcase-field-config` | Get test case field configuration |
| `test-hub-list-directories` | Get test case directory list |
| `test-hub-list-test-plan` | Get test plan list |
| `test-hub-list-test-plan-testcase-comments` | Get test plan case comment list |
| `test-hub-list-test-repo` | Get test repository list |
| `test-hub-list-test-repo-tags` | Get test repository label list |
| `test-hub-list-test-result-bug-relations` | Query bug list associated with the test result |
| `test-hub-list-testcase-comments` | Get test case comment list |
| `test-hub-search-testcases` | Search test cases |
| `test-hub-update-test-plan` | Update test plan |
| `test-hub-update-test-result` | Update test result |
| `test-hub-update-testcase` | Update test case information |
