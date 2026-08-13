---
name: umi
description: >
  Use when working with the Umi framework (UmiJS 4 / @umijs/max) — configuring .umirc.ts,
  setting up routing, managing data flow (useModel / getInitialState / useRequest), handling
  requests, writing mock APIs, using generators, or understanding file conventions. Triggers
  on Umi/UmiJS/Max imports, config files, or project setup tasks. Covers Umi 4 Max (the
  edition used by Ant Design Pro), NOT Umi 3.
allowed-tools:
  - WebFetch
  - Bash(max *)
  - Bash(umi *)
  - Bash(pnpm *)
---

# Umi 框架知识技能

Umi（@umijs/max v4）是 Ant Design Pro 的底层企业级前端框架。本技能内嵌从官方源码提取的权威配置参考、路由规则、数据流模式和文件约定（Layer 1），并提供按需文档检索指引（Layer 2）。

> **本技能聚焦 Umi 4 Max**（命令为 `max`）。Umi 3 的 `umi` 命令、dva、umi-request 等旧模式**已过时**，不要使用。

## 包管理器（pnpm 强制）

> **硬规则：包管理器强制使用 pnpm。** 不得使用 npm 或 yarn。不得在 `.npmrc` 或任何配置中添加 taobao / npmmirror 镜像源。

| 操作 | 命令 |
|------|------|
| 脚手架创建 | `pnpm dlx create-umi@latest` |
| Ant Design Pro 模板 | `pnpm dlx create-umi@latest --template ant-design-pro` |
| 安装依赖 | `pnpm install` |
| 添加依赖 | `pnpm add <pkg>` |
| 添加开发依赖 | `pnpm add -D <pkg>` |
| 运行 dev | `pnpm dev` 或 `pnpm max dev` |
| 构建 | `pnpm build` 或 `pnpm max build` |

Umi 配置中设置 `npmClient: 'pnpm'` 确保 MFSU 等内部依赖安装也走 pnpm。

## 配置系统

### 配置文件

| 文件 | 说明 |
|------|------|
| `.umirc.ts` | 项目根目录，优先级高于 `config/config.ts` |
| `config/config.ts` | `config/` 目录下，与 `.umirc.ts` **二选一**（互斥） |
| `config/config.{UMI_ENV}.ts` | 多环境覆盖（如 `config.dev.ts`、`config.prod.ts`） |
| `.env` | 环境变量（Node 侧）；`UMI_APP_*` 前缀的变量自动注入浏览器 |
| `.env.local` | 本地覆盖，不提交 |

配置用 `defineConfig` 包裹以获得 TypeScript 提示：

```ts
// .umirc.ts 或 config/config.ts
import { defineConfig } from '@umijs/max';
export default defineConfig({
  npmClient: 'pnpm',
  routes: [/* ... */],
  // ...其他配置
});
```

### 核心配置项

| 配置项 | 类型 | 说明 |
|--------|------|------|
| `routes` | `Route[]` | 配置式路由，未被 routes 引用的文件不参与编译 |
| `npmClient` | `'pnpm' \| 'yarn' \| 'npm'` | 包管理器，**设为 `'pnpm'`** |
| `proxy` | `Record<string, ProxyOpts>` | 开发代理（仅 dev 生效） |
| `theme` | `Record<string, string>` | Less 变量覆盖 |
| `define` | `Record<string, any>` | 构建时常量（值会 JSON.stringify） |
| `alias` | `Record<string, string>` | 模块别名（`@` → `src` 已内置） |
| `base` | `string` | 路由前缀（构建时，如 `/admin/`） |
| `publicPath` | `string` | 静态资源路径 |
| `hash` | `boolean` | 输出文件名加 hash |
| `history` | `{ type: 'browser' \| 'hash' \| 'memory' }` | 路由模式 |
| `targets` | `{ chrome: 80 }` | 浏览器兼容目标 |
| `mfsu` | `object` | Module Federation 加速（默认开启） |
| `fastRefresh` | `boolean` | 热更新 |
| `mock` | `false \| { include?, exclude? }` | Mock 配置 |
| `exportStatic` | `object` | 静态导出（SSG） |

**@umijs/max 插件配置**（必须显式启用才能使用对应 API）：

| 配置项 | 说明 | 启用后获得 |
|--------|------|------------|
| `antd: {}` | antd 集成 | 自动引入 antd，ConfigProvider 配置 |
| `layout: { ... }` | ProLayout 布局 | 运行时 `layout` 配置、菜单生成 |
| `request: { dataField: 'data' }` | axios 请求封装 | `request()`、`useRequest()` |
| `access: {}` | 权限控制 | `useAccess()`、`<Access>`、路由 `access` 字段 |
| `model: {}` | 全局状态模型 | `useModel()` |
| `initialState: {}` | 初始状态 | `getInitialState`、`useModel('@@initialState')` |
| `locale: { default, antd, baseNavigator }` | 国际化 | `useIntl()`、`<FormattedMessage>`、locale 切换 |
| `dva: {}` | dva 状态管理 | （Pro v6 已不使用，优先用 model/react-query） |
| `reactQuery: {}` | TanStack Query | `useQuery`、`useMutation` |
| `moment2dayjs: { preset: 'antd' }` | moment → dayjs 转换 | dayjs 替代 moment |
| `qiankun: {}` | 微前端 | |
| `tailwindcss: {}` | Tailwind CSS | |

> **关键陷阱**：`useRequest`/`useModel`/`useAccess`/`getInitialState` 等 API 在未启用对应插件时**不存在**。报 "not exported" 错误时先检查配置。

### 环境变量

- Node 侧：`.env` 中的所有变量
- 浏览器侧：仅 `UMI_APP_*` 前缀的变量自动注入；其他需通过 `define` 配置
- 内置变量：`PORT`（默认 8000）、`HOST`、`MOCK=none`（禁用 mock）、`UMI_ENV`、`ANALYZE=1`、`COMPRESS=none`

## 路由系统

### 配置式路由（推荐用于 Pro 项目）

在 `.umirc.ts` 或 `config/routes.ts` 中定义：

```ts
routes: [
  // 基础页面
  { path: '/', component: '@/pages/index' },
  // 重定向
  { path: '/old', redirect: '/new', keepQuery: true },
  // 动态参数
  { path: '/users/:id', component: '@/pages/userDetail' },
  // 嵌套布局（父组件渲染 <Outlet/>）
  {
    path: '/admin',
    component: '@/layouts/admin',
    routes: [
      { path: '/admin/list', component: '@/pages/admin/list' },
      { path: '/admin/edit', component: '@/pages/admin/edit' },
    ],
  },
  // 路由级权限包装（wrapper 渲染 <Outlet/> 或 <Navigate/>）
  { path: '/secure', component: '@/pages/secure', wrappers: ['@/wrappers/auth'] },
  // 无布局页（仅一级路由生效）
  { path: '/login', component: '@/pages/login', layout: false },
  // 404
  { path: '/*', component: '@/pages/404' },
],
```

- `component` 路径相对于 `src/pages`，`@` 别名指向 `src`
- 动态段 `:id`；通配符 `*` 仅在路径**末尾**
- Umi 4 默认按页面**代码分割**

### 约定式路由（无 routes 配置时）

- `src/pages/` 目录结构自动映射为路由
- `src/pages/users/$id.tsx` → `/users/:id`
- `src/pages/$.tsx` → `*` 通配符
- `src/pages/404.tsx` → 404 页面
- `src/layouts/index.tsx` → 全局布局（渲染 `<Outlet/>`）

### 布局路由扩展（Umi Max Layout 插件）

路由节点额外支持：

| 字段 | 说明 |
|------|------|
| `name` | 菜单文字（或 i18n key，如 `'welcome'` → `menu.welcome`） |
| `icon` | antd 图标名（省略 `Outlined` 后缀，如 `'home'`、`'crown'`） |
| `access` | 权限 key（对应 `access.ts` 导出的字段，不通过显示 403） |
| `hideInMenu` | 不在菜单中显示 |
| `hideChildrenInMenu` | 子路由不在菜单显示 |
| `hideInBreadcrumb` | 不在面包屑显示 |
| `flatMenu` | 扁平化子菜单 |
| `target` | `'_blank'` 新窗口打开 |
| `layout: false` | 隐藏布局 chrome（仅一级路由） |

### 导航 API（从 `umi` / `@umijs/max` 导入）

```ts
import { history, useNavigate, Link, useParams, useLocation,
         useSearchParams, useMatch, Outlet, Navigate } from '@umijs/max';

// 编程式导航
history.push('/users/1');
const navigate = useNavigate();
navigate('/dashboard');

// 获取参数
const { id } = useParams();           // /users/:id → { id }
const location = useLocation();        // { pathname, search, hash }
const [searchParams, setSearchParams] = useSearchParams();

// 布局中渲染子路由
<Outlet />
```

> **Umi 4 Breaking Change**：不再向路由组件 props 注入 `history`/`location`/`match`/`children`。必须用 Hooks 导入。`location.query` 已移除，用 `useSearchParams` 或 `query-string` 解析 `location.search`。

## 数据流

### Model 插件（useModel）

轻量级 Hooks 全局状态，无需 Redux。

```ts
// src/models/counterModel.ts —— 默认导出一个自定义 Hook
import { useState, useCallback } from 'react';
export default function CounterModel() {
  const [counter, setCounter] = useState(0);
  const increment = useCallback(() => setCounter(c => c + 1), []);
  return { counter, increment };
}
```

```tsx
// 消费 —— 任意组件中
import { useModel } from '@umijs/max';
const { counter, increment } = useModel('counterModel');
// 带选择器（避免不必要的重渲染）
const { increment } = useModel('counterModel', (m) => ({ add: m.increment }));
```

**命名约定**：
- `src/models/xxx.ts` → namespace `xxx`
- `src/pages/pageA/model.ts` → namespace `pageA.model`
- `src/pages/pageB/models/product.ts` → namespace `pageB.product`

### 初始状态（getInitialState）

```tsx
// src/app.tsx
export async function getInitialState(): Promise<{
  currentUser?: API.CurrentUser;
  settings?: LayoutSettings;
}> {
  const currentUser = await fetchUserInfo();
  return { currentUser, settings: defaultSettings };
}
```

```tsx
// 任意组件消费
const { initialState, loading, refresh, setInitialState } = useModel('@@initialState');
// loading 为 true 时页面渲染被阻塞（首次解析完成前）
```

`access.ts` 和 `layout` 运行时配置都会接收 `initialState`。

### 请求（useRequest + request）

基于 axios + ahooks `useRequest`：

```tsx
import { useRequest } from '@umijs/max';

// 自动请求
const { data, loading, error } = useRequest(fetchUserList);

// 手动触发
const { run, loading } = useRequest(addUser, { manual: true });

// 带参数
const { data } = useRequest(() => getUserDetail(id), {
  refreshDeps: [id],  // id 变化时自动刷新
});
```

`useRequest` 返回 `{ data, error, loading, run, refresh, mutate }`，支持 `manual`、`refreshDeps`、`pollingInterval`、`debounceInterval`、`throttleInterval`、`onSuccess`、`onError` 等选项。

### react-query 集成（Pro v6 推荐）

```tsx
import { useQuery, useMutation, useQueryClient } from '@umijs/max';

const { data } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
const mutation = useMutation({
  mutationFn: addUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] }),
});
```

## 请求运行时配置

```tsx
// src/app.tsx
import type { RequestConfig } from '@umijs/max';

export const request: RequestConfig = {
  baseURL: process.env.NODE_ENV === 'development' ? '' : 'https://api.example.com',
  timeout: 10000,
  headers: { 'X-Requested-With': 'XMLHttpRequest' },
  errorConfig: {
    errorThrower: (res) => {
      // 后端返回 { success: false } 时抛出业务错误
      if (!res.success) throw new BizError(res);
    },
    errorHandler: (error, opts) => {
      if (opts.skipErrorHandler) throw error;
      // 处理 BizError / axios 网络错误 / 超时 / 离线
    },
  },
  requestInterceptors: [
    (config) => {
      // 添加 token 等
      return { ...config, headers: { ...config.headers, Authorization: getToken() } };
    },
  ],
  responseInterceptors: [
    (response) => {
      // 统一处理响应
      return response;
    },
  ],
};
```

- `errorConfig` 之外的所有配置透传给 axios（`timeout`/`baseURL`/`headers` 等）
- 拦截器支持 `[fn, errorFn]` 元组形式
- `request()` 额外支持 `skipErrorHandler: true`（跳过全局错误处理）、`getResponse: true`（返回完整 axios 响应）
- Pro 项目通常将错误处理抽到 `src/requestErrorConfig.ts`，在 `app.tsx` 中展开

## 文件约定

| 路径 | 用途 |
|------|------|
| `.umirc.ts` / `config/config.ts` | 构建时配置（`defineConfig`） |
| `src/app.tsx` | **运行时配置**：`defineApp` + 导出 `getInitialState`/`request`/`layout`/`onRouteChange`/`patchRoutes`/`render`/`rootContainer` |
| `src/access.ts` | 权限定义：`export default (initialState) => ({ canAdmin: ... })` |
| `src/global.tsx` | 应用启动前执行的脚本 |
| `src/global.(css\|less)` | 全局样式（自动引入） |
| `src/loading.tsx` | 路由切换时的全局 loading 组件 |
| `src/layouts/index.tsx` | 全局布局（渲染 `<Outlet/>`） |
| `src/pages/` | 页面组件（=路由目标） |
| `src/models/` | `useModel` 全局模型 |
| `src/wrappers/` | 路由包装器（权限等） |
| `src/components/` | 共享组件 |
| `src/services/` | API 服务函数 |
| `src/locales/*.ts` | i18n 消息（`zh-CN.ts`、`en-US.ts`） |
| `src/icons/` | 本地 SVG 图标（`<Icon icon="local:xxx" />`） |
| `public/` | 静态资源（直接 `/image.png`） |
| `mock/` | Mock API（仅 dev；`MOCK=none` 禁用） |
| `plugin.ts` | 项目级插件 |
| `src/.umi` | 生成的临时文件（**禁止编辑**） |

## 构建与工具

### 命令（Max 项目用 `max`，基础 umi 用 `umi`）

| 命令 | 说明 |
|------|------|
| `max dev` | 开发服务器（端口 8000） |
| `max build` | 构建到 `dist/` |
| `max preview` | 预览构建结果（端口 4172） |
| `max setup` | 生成临时文件（用于 `prepare` 脚本） |
| `max g page <name>` | 生成页面（支持嵌套 `max g page far/away`） |
| `max g component <name>` | 生成组件 |
| `max g mock` | 生成 mock 文件 |
| `max lint` | 代码检查 |
| `max deadcode` | 死代码检测 |

### Mock 系统

```ts
// mock/user.ts
export default {
  'GET /api/users': [{ id: 1, name: 'Alice' }],
  'POST /api/users': (req, res) => {
    res.status(201).json({ id: Date.now(), ...req.body });
  },
};
```

- `mock/` 下所有 `.ts/.js` 自动注册（仅 dev）
- `mock: false` 或 `MOCK=none` 禁用
- 支持 mockjs 语法
- `mock: { include: ['src/pages/**/_mock.ts'] }` 自定义路径

## 常见陷阱

1. **插件须显式启用** — `useRequest`/`useModel`/`useAccess`/`getInitialState` 在未配置 `request: {}`/`model: {}`/`access: {}`/`initialState: {}` 时不可用。
2. **`.umirc.ts` 与 `config/config.ts` 互斥** — 二者只能存在一个，`.umirc.ts` 优先。
3. **proxy 仅 dev 生效** — 生产环境需同源部署或 nginx 转发。
4. **`layout: false` 仅一级路由** — 嵌套路由无法单独隐藏布局。
5. **`access` 依赖 `initialState`** — 路由级 `access` 需同时启用 `access: {}` 和 `initialState: {}`。
6. **浏览器环境变量需 `UMI_APP_` 前缀** — 或通过 `define` 配置。
7. **Umi 4 不再注入路由 props** — 用 `useNavigate`/`useLocation`/`useParams` Hooks 替代。
8. **`UMI_ENV` 保留值** — `dev`/`prod`/`test` 不能用作 `UMI_ENV` 的值。
9. **Node 22+ 推荐** — 确保开发环境 Node 版本 ≥ 22。

## 按需文档检索（Layer 2）

当本技能内嵌知识不足以覆盖特定场景时，按以下方式检索：

### 官方文档

| 主题 | URL |
|------|-----|
| 入门介绍 | `https://umijs.org/docs/introduce/introduce` |
| 目录结构 | `https://umijs.org/docs/guides/directory-structure` |
| 路由指南 | `https://umijs.org/docs/guides/routes` |
| 配置 API | `https://umijs.org/docs/api/config` |
| 运行时配置 | `https://umijs.org/docs/api/runtime-config` |
| Max 介绍 | `https://umijs.org/docs/max/introduce` |
| Max 布局菜单 | `https://umijs.org/docs/max/layout-menu` |
| Max 数据流 | `https://umijs.org/docs/max/data-flow` |
| Max 请求 | `https://umijs.org/docs/max/request` |
| Max 权限 | `https://umijs.org/docs/max/access` |
| Max 国际化 | `https://umijs.org/docs/max/i18n` |
| Max react-query | `https://umijs.org/docs/max/react-query` |
| Mock 指南 | `https://umijs.org/docs/guides/mock` |
| 环境变量 | `https://umijs.org/docs/guides/env-variables` |
| 生成器 | `https://umijs.org/docs/guides/generator` |

使用 `WebFetch` 工具获取上述 URL 的内容。

### GitHub 源码读取

使用 `zai-open-source-repository-mcp` 工具读取 `umijs/umi` 仓库：

- 仓库结构：`get_repo_structure("umijs/umi", "docs/docs/docs/max")`
- 文档源码：`read_file("umijs/umi", "docs/docs/docs/max/data-flow.md")`
- 示例代码：`read_file("umijs/umi", "examples/max/src/app.tsx")`

### 项目代码勘察（Layer 3）

使用 `Glob` / `Grep` / `Read` 分析现有项目：
- 扫描 `.umirc.ts` 或 `config/config.ts` 确认已启用的插件
- 读取 `src/app.tsx` 了解运行时配置
- 阅读 `src/models/` 下既有模型约定
- 检查 `package.json` 的 scripts 和依赖版本
