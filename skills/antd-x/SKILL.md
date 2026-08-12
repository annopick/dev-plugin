---
name: antd-x
description: >
  Use when building AI chat UIs or AI-native interfaces with @ant-design/x — covers all
  components (Bubble, Sender, Conversations, Prompts, ThoughtChain, Actions, Welcome,
  Attachments, Sources, Suggestion, Think, FileCard, CodeHighlighter, Mermaid, Folder,
  XProvider, Notification) and SDK utilities (useXChat, XRequest, XChatProvider, XMarkdown,
  XCard). Triggers on @ant-design/x imports, AI chat/conversation UI tasks, streaming
  response rendering, or agent-style interaction design. Based on the RICH interaction paradigm.
---

# Ant Design X（AI 原生组件）知识技能

本技能覆盖 `@ant-design/x` — 基于 **RICH 交互范式**（意图识别 → 意图确认 → 内容表达 → 反馈确认）构建 AI 驱动对话界面的 React 组件库。`@ant-design/x` 是 antd 的扩展，二者协同使用。

> **前提**：本技能聚焦 UI 组件。数据流与流式处理参见下方 [SDK 数据流指引](#sdk-数据流指引)。

## 包概览

| 包 | 职责 |
|----|------|
| `@ant-design/x` | 全部 UI 组件（本技能覆盖） |
| `@ant-design/x-sdk` | 数据 Provider、请求封装、流式状态管理（useXChat / XRequest / XChatProvider） |
| `@ant-design/x-markdown` | Markdown 流式渲染（用于 Bubble 内的富文本回复） |
| `@ant-design/x-card` | AI Agent 动态渲染富交互 UI（XCard.Box / XCard.Card / A2UI） |

```bash
npm install @ant-design/x @ant-design/x-sdk @ant-design/x-markdown @ant-design/x-card
```

> `@ant-design/x` 扩展了 antd。如果项目中使用了 `ConfigProvider`，请替换为 `XProvider`。

## 组件分组（RICH 交互范式）

| 阶段 | 组件 | 职责 |
|------|------|------|
| **通用** | `Bubble`、`Bubble.List`、`Conversations`、`Notification` | 消息气泡、消息列表、会话管理、全局通知 |
| **唤醒（Wake）** | `Welcome`、`Prompts` | 欢迎屏、预设提示词 |
| **表达（Express）** | `Sender`、`Attachments`、`Suggestion` | 输入框、附件上传、命令建议 |
| **确认（Confirmation）** | `Think`、`ThoughtChain` | 推理过程折叠展示、多步工具调用链 |
| **反馈（Feedback）** | `Actions`、`FileCard`、`Sources`、`CodeHighlighter`、`Mermaid`、`Folder` | 操作按钮、文件卡片、引用来源、代码高亮、Mermaid 图表、文件树 |
| **全局** | `XProvider` | 替代 antd `ConfigProvider`，提供 locale / direction / 主题 / 快捷键 |

## 快速选型指南

| 需求 | 组件 |
|------|------|
| 渲染单条对话消息 | `Bubble` |
| 渲染消息列表（推荐） | `Bubble.List`（自动处理滚动锚定、角色布局） |
| 输入框（发送消息） | `Sender`（`onSubmit` 发送、`onChange` 实时输入） |
| 列出/切换会话 | `Conversations` |
| 展示 AI 思考过程 | 多步工具链 → `ThoughtChain`；单块推理 → `Think` |
| 消息下方操作按钮 | `Actions`（内置 `Actions.Copy`、`Actions.Feedback`、`Actions.Audio`） |
| 欢迎屏 / 引导 | `Welcome` + `Prompts` |
| 输入区附件上传 | `Attachments` |
| 引用来源展示 | `Sources` |
| 快捷命令建议 | `Suggestion` |
| 文件/文件夹树 | `Folder` |
| 代码高亮 | `CodeHighlighter` |
| Mermaid 图表 | `Mermaid` |
| 动态渲染 Agent 富交互 UI | `XCard`（`@ant-design/x-card`） |
| 全局配置 | `XProvider`（替代 `ConfigProvider`） |

## 最小完整页面示例

```tsx
import { XProvider, Welcome, Prompts, Bubble, Sender } from '@ant-design/x';

export default function ChatApp() {
  return (
    <XProvider>
      <Welcome title="Hello!" description="How can I help you?" />
      <Prompts
        items={[{ key: '1', label: 'What can you do?' }]}
        onItemClick={(info) => console.log(info.data.label)}
      />
      <Bubble.List
        items={[{ key: '1', content: 'Hello World', placement: 'end' }]}
      />
      <Sender onSubmit={(msg) => console.log(msg)} />
    </XProvider>
  );
}
```

## SDK 数据流指引

构建完整 AI 对话应用时，组件（UI）与 SDK（数据流）需配合使用：

```
XChatProvider（会话数据流适配）
    ↓ 封装
XRequest（流式请求封装）
    ↓ 驱动
useXChat（消息状态管理 Hook）
    ↓ 渲染
x-components（Bubble / Sender / Conversations …）
    ↓ 富文本
x-markdown（Markdown 流式渲染）
```

| SDK 能力 | 说明 |
|----------|------|
| `useXChat` | 管理多会话消息列表、流式追加、错误处理。配合 `XRequest` 或自定义 Provider 使用。 |
| `XRequest` | 网络请求封装，支持 SSE 流式响应、请求取消、重试。将后端流式接口适配为标准消息格式。 |
| `XChatProvider` | 自定义 Provider 实现——将任意流式接口适配为 Ant Design X 标准格式，供 `useXChat` 消费。 |
| `XMarkdown` | 流式 Markdown 渲染，支持自定义组件映射、插件、主题。用于 `Bubble` 的 `contentRender`。 |

## 开发规则（防踩坑）

1. **始终在应用根节点使用 `XProvider`** — 它取代 antd 的 `ConfigProvider`，提供 locale、direction、主题和 X 专属快捷键。
2. **消息列表用 `Bubble.List` 而非 `map(Bubble)`** — `Bubble.List` 自动处理滚动锚定、自动滚动和基于角色的布局；手动 map `Bubble` 会丢失这些能力。
3. **保持 `components` prop 稳定** — `Bubble` 和 `Bubble.List` 的 `components` prop 内联创建会导致重渲染和打字动画重置，应提取为模块级常量或 `useMemo`。
4. **流式状态正确切换** — 流式输出时设 `streaming={true}`，最终块到达后设 `streaming={false}`；永久 `true` 会破坏完成态。
5. **`ThoughtChain` vs `Think`** — `ThoughtChain` 用于多步工具/Agent 调用链；`Think` 用于可折叠的单块推理展示。
6. **优先用 `Actions` 预设子组件** — `Actions.Copy`、`Actions.Feedback`、`Actions.Audio` 是预设子组件，优先使用而非自建等效功能。
7. **`Sender` 的 `onSubmit` vs `onChange`** — `onSubmit` 在发送按钮或回车时触发；`onChange` 在每次按键时触发，不要混淆。
8. **不要在 `Bubble` 的 `content` 字符串内渲染 `Mermaid` 或 `CodeHighlighter`** — 应通过 `contentRender` 或 `components` 映射渲染。

## XCard（动态富交互 UI）

当 AI Agent 需要动态渲染富交互 UI（表单、卡片、图表等）时，使用 `@ant-design/x-card`：

| 能力 | 说明 |
|------|------|
| `XCard.Box` | 容器组件，管理多个 Card 的布局 |
| `XCard.Card` | 单张卡片，支持标题、内容、操作按钮 |
| A2UI 协议 | v0.9 命令协议，定义 Agent → UI 的数据绑定与交互指令 |
| Catalog | 组件目录，注册可被 Agent 动态渲染的组件 |
| Actions | 卡片操作（提交、取消、跳转等） |
| 流式渲染 | 支持流式数据驱动的渐进式 UI 渲染 |

## 详细参考路由

本技能提供组件选型与开发规则的总览。如需逐组件的精确 API 文档（每个 Prop 的名称、类型、默认值），加载以下已安装的详细技能：

| 需求 | 加载技能 |
|------|----------|
| 查看具体组件的 Props、用法、示例 | `x-components` |
| 配置网络请求（XRequest） | `x-request` |
| 管理聊天消息状态（useXChat） | `use-x-chat` |
| 自定义流式数据 Provider | `x-chat-provider` |
| Markdown 流式渲染 | `x-markdown` |
| 动态渲染富交互 UI（XCard） | `x-card` |

> 这些技能由 `x-agent-skills` 插件提供。若未安装，可通过 `npm i -g @ant-design/x-skill && npx x-skill` 安装。
