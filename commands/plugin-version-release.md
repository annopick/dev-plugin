---
description: Coding Agent插件版本发布
---

1、比较 `.zcode-plugin/plugin.json`、`.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` 与 `plugins/annopick-plugin/.codex-plugin/plugin.json` 的版本号，并统一升级。
2、根据本次提交内容，修订 `CHANGELOG.md`、`README.md`。
3、运行 Codex 插件校验：`python <plugin-creator>/scripts/validate_plugin.py plugins/annopick-plugin`。
4、git commit、git push，并创建同版本 tag。
