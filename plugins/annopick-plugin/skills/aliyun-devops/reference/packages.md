# 制品仓库 Packages（`packages-*`，6 个命令）

> [SKILL.md 返回](../SKILL.md) · 命令少，一页讲完

## 高频命令

```bash
aliyun devops packages-list-repositories ...      # 制品仓库列表（拿 repoId）
aliyun devops packages-list-artifacts ...         # 制品查询
aliyun devops packages-get-artifact ...           # 单个制品信息
aliyun devops packages-get-task ...               # 批量任务状态
```

删除类（`packages-delete-artifact` / `packages-delete-artifact-version`）不可逆，必须用户明确确认后执行。

## 全量命令索引

| 命令 | 说明 |
| --- | --- |
| `packages-delete-artifact` | Delete a single artifact |
| `packages-delete-artifact-version` | Delete a single artifact version |
| `packages-get-artifact` | View information of a single artifact |
| `packages-get-task` | View batch job |
| `packages-list-artifacts` | Query artifact information |
| `packages-list-repositories` | View repository information |
