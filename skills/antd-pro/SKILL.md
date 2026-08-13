---
name: antd-pro
description: >
  Use when developing with Ant Design Pro or ProComponents (@ant-design/pro-components) —
  writing ProTable/ProForm/ProList/ProCard/ProDescriptions/StatisticCard pages, configuring
  ProLayout, setting up CRUD pages, working with config/routes.ts, or following Pro project
  conventions. Triggers on ProComponents imports, ProLayout usage, config/routes.ts, or
  enterprise admin/dashboard development tasks. Built on Umi Max 4 + antd v5/v6.
allowed-tools:
  - WebFetch
---

# Ant Design Pro + ProComponents 知识技能

Ant Design Pro v6 是基于 Umi Max 4 + antd + ProComponents 的企业级中后台脚手架。ProComponents（`@ant-design/pro-components` v3）提供 ProTable、ProForm、ProLayout 等高级组件。

本技能内嵌从官方源码提取的权威 API 参考（Layer 1），并提供按需文档检索指引（Layer 2）。

> **前置技能**：本技能依赖 `umi` 技能（配置/路由/数据流）和 `antd` 技能（基础组件 API）。

## 包管理器（pnpm 强制）

> **硬规则：包管理器强制使用 pnpm。** 不得使用 npm 或 yarn。不得添加 taobao / npmmirror 镜像源。详见 `umi` 技能。

## 技术栈基线（Pro v6）

- **框架**：`@umijs/max` v4（命令 `max`）
- **UI**：antd v6 + `@ant-design/pro-components` v3
- **React**：19
- **状态**：`@tanstack/react-query` v5（mutations/invalidateQueries）
- **图表**：`@ant-design/plots`（封装 AntV）
- **日期**：dayjs（通过 `moment2dayjs` 插件）
- **测试**：Vitest
- **Node**：≥ 22

## 项目结构

```text
config/
  config.ts             # Umi defineConfig（启用所有插件）
  defaultSettings.ts     # ProLayout 设置（navTheme/layout/colorPrimary...）
  proxy.ts               # 开发代理（按 UMI_ENV 键控）
  routes.ts              # 路由表（驱动菜单生成）
  oneapi.json            # OpenAPI schema（可选，生成 services/mock）
src/
  app.tsx                # 运行时配置：getInitialState、layout、request
  access.ts              # 权限定义函数
  requestErrorConfig.ts  # 请求/响应拦截器 + 错误处理
  global.tsx / global.less
  pages/                 # 路由组件
    table-list/          # CRUD 示例（index + components/CreateForm + UpdateForm）
    dashboard/  form/  user/  profile/  account/  exception/
  components/            # 共享组件
  services/              # API 函数（常由 OpenAPI 生成）
  locales/               # i18n 消息
mock/                    # Mock 数据
```

> **关键规则**：只有被 `routes.ts` 引用的文件才参与编译。

## 路由与菜单（config/routes.ts）

路由同时驱动路由器**和** ProLayout 菜单：

```ts
export default [
  { path: '/user', layout: false, routes: [
    { path: '/user/login', component: './user/login' },
  ]},
  { path: '/welcome', name: 'welcome', icon: 'home', component: './Welcome' },
  { path: '/admin', name: 'admin', icon: 'crown', access: 'canAdmin', routes: [
    { path: '/admin', redirect: '/admin/sub-page' },
    { path: '/admin/sub-page', name: 'sub-page', component: './Admin' },
  ]},
  { path: '/', redirect: '/dashboard/analysis' },
  { component: './exception/404', path: '/*' },
];
```

| 路由字段 | 说明 |
|----------|------|
| `name` | 菜单文字 / i18n key（`'welcome'` → `menu.welcome`） |
| `icon` | antd 图标名（省略 `Outlined`，如 `'home'`、`'crown'`、`'table'`） |
| `access` | 权限 key，不通过时显示 403 |
| `layout: false` | 隐藏布局（仅一级路由，用于登录页） |
| `hideInMenu` / `hideChildrenInMenu` | 菜单隐藏控制 |

## 布局系统

### src/app.tsx 的 layout 运行时配置

```tsx
import { RunTimeLayoutConfig } from '@umijs/max';

export const layout: RunTimeLayoutConfig = ({ initialState }) => ({
  title: 'My App',
  logo: '/logo.png',
  // 菜单项渲染：包裹 <Link>
  menuItemRender: (item, dom) => <Link to={item.path} prefetch>{dom}</Link>,
  // 页面切换：登录守卫
  onPageChange: () => {
    const { location } = history;
    if (!initialState?.currentUser && location.pathname !== '/user/login') {
      history.push(`/user/login?redirect=${location.pathname}`);
    }
  },
  avatarProps: {
    src: initialState?.currentUser?.avatar,
    render: (_, dom) => <Dropdown menu={{ items: userMenuItems }}>{dom}</Dropdown>,
  },
  footerRender: () => <Footer />,
  childrenRender: (children) => <>{children}<SettingDrawer /></>,
});
```

### defaultSettings.ts

```ts
export default {
  navTheme: 'light',           // 'light' | 'realDark'
  colorPrimary: '#1677ff',
  layout: 'mix',               // 'side' | 'top' | 'mix'
  contentWidth: 'Fluid',       // 'Fluid' | 'Fixed'
  fixedHeader: false,
  fixSiderbar: false,
  colorWeak: false,
  title: 'Ant Design Pro',
  logo: '/logo.png',
};
```

`layout: 'mix'` 时一级菜单在顶部、子菜单在侧边。

## ProComponents API 参考

### ProTable

**核心**：`request` prop 驱动数据加载。

```tsx
<ProTable<API.RuleListItem, API.PageParams>
  actionRef={actionRef}
  rowKey="id"
  search={{ labelWidth: 120 }}
  toolBarRender={() => [<Button key="create">新建</Button>]}
  request={async (params, sort, filter) => {
    // params = { pageSize, current, ...searchFormValues }
    const res = await queryRuleList(params);
    return {
      data: res.data,
      success: res.success,
      total: res.total,
    };
  }}
  columns={columns}
  rowSelection={{ onChange: (_, rows) => setSelectedRows(rows) }}
/>
```

**request 返回格式（约定）**：
```ts
{ data: T[]; success: boolean; total: number }
```

#### ProColumns\<T\> 字段表

| 字段 | 类型 | 说明 |
|------|------|------|
| `title` | `ReactNode` | 列标题 |
| `dataIndex` | `string \| string[]` | 数据字段路径 |
| `valueType` | `ValueType` | 值类型（见下表），决定渲染方式与表单控件 |
| `valueEnum` | `Map \| Record` | 枚举映射 `{ text, status }`，status: `'Success' \| 'Processing' \| 'Error' \| 'Default'` |
| `render(dom, record, index, action)` | `function` | 自定义单元格渲染 |
| `renderText(text, record, index)` | `function` | 纯文本转换（返回 string） |
| `fieldProps` | `object` | 透传给表单控件的 props |
| `formItemProps` | `{ rules?: Rule[] }` | 表单项 props（含校验规则） |
| `search` | `false \| { transform }` | `false` 隐藏搜索项；`transform` 转换搜索参数名 |
| `hideInTable` | `boolean` | 表格中隐藏 |
| `hideInForm` | `boolean` | 表单中隐藏 |
| `hideInSearch` | `boolean` | 搜索中隐藏 |
| `hideInDescriptions` | `boolean` | 描述中隐藏 |
| `sorter` | `boolean \| function \| string` | `true`=服务端排序；function=本地排序；string=覆盖排序字段名 |
| `filters` / `onFilter` | `array / function` | 本地过滤（配合使用） |
| `copyable` | `boolean` | 可复制图标 |
| `ellipsis` | `boolean` | 省略号 |
| `tooltip` | `string` | 表单项提示 |
| `fixed` | `'left' \| 'right'` | 固定列 |
| `width` | `number` | 列宽 |
| `request` | `async () => options` | 远程枚举选项 |
| `dependencies` | `string[]` | 字段联动依赖 |
| `transform(value, allValues)` | `function` | 提交时转换值（返回标量替换或对象合并） |
| `convertValue(value)` | `function` | 回显时转换值 |
| `initialValue` | `any` | 默认值 |
| `order` | `number` | 搜索项权重（越大越靠前） |
| `colSize` | `number` | 搜索项栅格宽度（默认 1，可设 2/3 占多列） |

#### valueType 枚举

`text` `password` `money` `textarea` `date` `dateTime` `dateWeek` `dateMonth` `dateQuarter` `dateYear` `dateRange` `dateTimeRange` `time` `timeRange` `select` `checkbox` `radio` `rate` `switch` `digit` `second` `avatar` `code` `jsonCode` `progress` `percent` `digitRange` `tag` `textStyle` `image` `slider` `index`（自动行号） `indexBorder` `option`（操作列） `group` `dependency` `formList` `cascader` `treeSelect` `color` `segmented` `multiple` `file` `fileImage` `divider` `selectMultiple`

#### actionRef 方法

```ts
const actionRef = useRef<ActionType>();
// 刷新（可选重置到第一页）
actionRef.current?.reload();
actionRef.current?.reload(true);   // 重置到第一页
actionRef.current?.reloadAndRest(); // 刷新并清空选择
actionRef.current?.reset();         // 重置搜索表单
actionRef.current?.clearSelected(); // 清空选择
actionRef.current?.startEditable(rowKey); // 开始行内编辑
actionRef.current?.cancelEditable(rowKey);
```

#### 排序与过滤规则

| 配置 | 行为 |
|------|------|
| `sorter: true` | **服务端**排序——触发 `request` 时传入 `sort` 参数 |
| `sorter: (a, b) => a - b` | **本地**排序——不触发请求 |
| `filters: [...]` + `onFilter: (value, record) => ...` | **本地**过滤 |
| 服务端过滤 | 在 `request` 中读取 `filter` 参数自行处理 |

### ProForm

antd Form 的增强封装。布局变体：**ProForm**（标准）、**ModalForm**（弹窗）、**DrawerForm**（抽屉）、**QueryFilter/LightFilter**（筛选器）、**StepsForm**（分步）、**LoginForm**（登录）。

```tsx
<ProForm
  onFinish={async (values) => {
    await saveData(values);
    return true; // 返回 true 自动重置表单 + 设置按钮 loading 完成
  }}
  formRef={formRef}
  initialValues={{ name: '' }}
>
  <ProFormText name="name" label="名称" rules={[{ required: true }]} />
  <ProFormSelect name="type" label="类型" request={async () => fetchOptions()} />
</ProForm>
```

**关键 props**：

| Prop | 说明 |
|------|------|
| `onFinish(values) => Promise<boolean\|void>` | 提交；返回 truthy 重置表单；自动管理提交按钮 loading |
| `formRef` | `ProFormInstance` 引用，命令式操作 |
| `initialValues` | 初始值 |
| `submitter` | `false` 隐藏按钮；或自定义 `{ searchConfig, submitButtonProps, resetButtonProps, render }` |
| `grid` / `rowProps` / `colProps` | 栅格布局模式 |
| `omitNil` | 提交时移除 null/undefined（默认 true） |
| `dateFormatter` | 日期格式化策略 |
| `request` | 异步获取初始值 |
| `params` | request 的参数 |

**formRef 命令式 API**：
```ts
formRef.current?.validateFields();          // 校验
formRef.current?.setFieldsValue({ ... });   // 设置值
formRef.current?.resetFields();             // 重置
formRef.current?.getFieldsFormatValue();    // 获取格式化后的值
```

#### ProForm 子组件清单

`ProFormText` `ProFormDigit` `ProFormSelect` `ProFormCascader` `ProFormTreeSelect` `ProFormDatePicker` `ProFormDateRangePicker` `ProFormTimePicker` `ProFormTextArea` `ProFormRadio.Group` `ProFormCheckbox.Group` `ProFormSwitch` `ProFormSlider` `ProFormRate` `ProFormUploadDragger` `ProFormUploadButton` `ProFormMoney` `ProFormColorPicker` `ProFormSegmented` `ProFormDependency` `ProForm.Group` `ProFormFieldSet` `ProFormList` `ProFormDigitRange` `ProFormText.Password` `ProFormMentions` `ProFormAutoComplete`

每个子组件支持：`name`、`label`、`tooltip`、`width`（`xs|sm|md|lg|xl`）、`rules`、`fieldProps`、`request`（远程选项）、`valueEnum`、`valueType`、`transform`、`convertValue`、`disabled`、`readonly`。

> **陷阱**：不要在 ProForm 子组件上设置 `value` / `onChange` / `defaultValue`——它们由 Form 接管。用 `initialValues` 或 `formRef.current?.setFieldsValue` 设值。

### ModalForm / DrawerForm

trigger 模式（无需管理 open 状态）：

```tsx
<ModalForm
  trigger={<Button>新建</Button>}
  title="新建用户"
  width={600}
  onFinish={async (values) => {
    await createUser(values);
    message.success('创建成功');
    return true; // true → 自动关闭 + 重置
  }}
  modalProps={{ destroyOnHidden: true }}
>
  <ProFormText name="name" label="姓名" rules={[{ required: true }]} />
</ModalForm>
```

DrawerForm 额外支持 `resize`（拖拽调整宽度）。两者都支持 `open` / `onOpenChange` 受控模式。

### StepsForm

```tsx
<StepsForm
  onFinish={async (allValues) => { /* 合并所有步骤数据提交 */ }}
>
  <StepsForm.StepForm name="step1" title="基本信息" onFinish={async () => true}>
    <ProFormText name="name" />
  </StepsForm.StepForm>
  <StepsForm.StepForm name="step2" title="详细配置">
    <ProFormSelect name="type" />
  </StepsForm.StepForm>
</StepsForm>
```

### BetaSchemaForm（JSON 驱动）

```tsx
<BetaSchemaForm
  layoutType="Form"  // 'Form' | 'ModalForm' | 'DrawerForm' | 'StepsForm' | 'LightFilter' | 'QueryFilter'
  columns={[
    { title: '名称', dataIndex: 'name', valueType: 'text', formItemProps: { rules: [{ required: true }] } },
    { title: '类型', dataIndex: 'type', valueType: 'select', valueEnum: {...} },
  ]}
/>
```

`columns` 复用 ProColumns schema，适合动态表单。

### ProList

基于 ProTable，**推荐 `columns` + `listSlot`** 模式（废弃 `metas`）：

```tsx
<ProList<API.Item>
  rowKey="id"
  request={async (params) => { /* 同 ProTable */ }}
  columns={[
    { title: '标题', dataIndex: 'title', listSlot: 'title' },
    { title: '描述', dataIndex: 'desc', listSlot: 'description' },
    { title: '操作', dataIndex: 'option', valueType: 'option', listSlot: 'actions' },
  ]}
  pagination={{ pageSize: 10 }}
  toolBarRender={() => [<Button key="add">添加</Button>]}
/>
```

`listSlot` 值：`title` `subTitle` `avatar` `description` `content` `actions` `aside` `type`。

### ProCard

```tsx
{/* 栅格布局 */}
<ProCard gutter={16} direction="row">
  <ProCard colSpan={8} title="左侧">内容</ProCard>
  <ProCard colSpan={16} title="右侧">内容</ProCard>
</ProCard>

{/* 分割 */}
<ProCard split="vertical">
  <ProCard title="A">A</ProCard>
  <ProCard title="B">B</ProCard>
</ProCard>

{/* 标签页 */}
<ProCard tabs={{ items: [
  { key: 'tab1', label: 'Tab 1', children: <Content1 /> },
  { key: 'tab2', label: 'Tab 2', children: <Content2 /> },
]}} />
```

Props：`colSpan`（24 栅格，支持 `{xs,sm,md,...}` 响应式）、`split`（`vertical|horizontal`）、`direction`（`row|column`）、`ghost`（无 padding/bg）、`bordered`/`variant`、`collapsible`、`tabs`、`gutter`、`headerBordered`、`hoverable`。

### ProDescriptions

只读展示，复用 ProColumns：

```tsx
<ProDescriptions<API.User>
  column={2}
  request={async () => ({ data: currentUser, success: true })}
  columns={columns}  // 同一个 columns 数组！
  editable={false}
/>
```

返回格式：`{ data: T; success: boolean }`。

### StatisticCard

```tsx
<StatisticCard
  statistic={{
    title: '总销售额',
    value: 126560,
    prefix: '¥',
    status: 'success',     // 'success' | 'processing' | 'default' | 'error' | 'warning'
    trend: 'up',           // 'up' | 'down'
    description: '较昨日 +12%',
  }}
  chart={<Line {...config} />}    // 图表槽位
  chartPlacement="bottom"  // 'left' | 'right' | 'bottom'
  footer={<div>底部内容</div>}
/>
```

### PageContainer（@ant-design/pro-layout）

```tsx
<PageContainer
  header={{ title: '用户管理' }}
  content="管理所有系统用户"
  extra={[<Button key="export">导出</Button>]}
  tabList={[{ tab: '全部', key: 'all' }, { tab: '活跃', key: 'active' }]}
  onTabChange={setActiveTab}
>
  {/* 页面内容 */}
</PageContainer>
```

配合 `<FooterToolbar>` 实现底部固定操作栏（读取 RouteContext 自动吸附）。

## 开发模式

### CRUD 页面模板（最常用）

```tsx
// src/pages/table-list/index.tsx
const TableList: React.FC = () => {
  const actionRef = useRef<ActionType>();
  const [modalOpen, setModalOpen] = useState(false);
  const [currentRow, setCurrentRow] = useState<API.RuleListItem>();

  const columns: ProColumns<API.RuleListItem>[] = [
    { title: '名称', dataIndex: 'name', render: (_, record) => (
      <a onClick={() => setCurrentRow(record)}>{record.name}</a>
    )},
    { title: '状态', dataIndex: 'status', valueType: 'select',
      valueEnum: { enabled: { text: '启用', status: 'Success' },
                   disabled: { text: '禁用', status: 'Error' }}},
    { title: '操作', valueType: 'option', render: (_, record) => [
      <a key="edit" onClick={() => { setCurrentRow(record); setModalOpen(true); }}>编辑</a>,
      <a key="del" onClick={() => handleRemove(record)}>删除</a>,
    ]},
  ];

  return (
    <PageContainer>
      <ProTable<API.RuleListItem>
        headerTitle="规则列表"
        actionRef={actionRef}
        rowKey="id"
        search={{ labelWidth: 120 }}
        request={async (params) => {
          const res = await queryRuleList(params);
          return { data: res.data, success: res.success, total: res.total };
        }}
        columns={columns}
        toolBarRender={() => [
          <Button key="create" type="primary" onClick={() => { setCurrentRow(undefined); setModalOpen(true); }}>
            <PlusOutlined /> 新建
          </Button>,
        ]}
      />
      <ModalForm
        title={currentRow ? '编辑' : '新建'}
        open={modalOpen}
        onOpenChange={setModalOpen}
        initialValues={currentRow}
        onFinish={async (values) => {
          if (currentRow?.id) await updateRule({ ...values, id: currentRow.id });
          else await addRule(values);
          actionRef.current?.reload();
          return true;
        }}
      >
        <ProFormText name="name" label="名称" rules={[{ required: true }]} />
      </ModalForm>
    </PageContainer>
  );
};
```

**关键要点**：
- `actionRef.current?.reload()` 在 CRUD 操作后刷新表格
- 同一个 `columns` 数组复用于 ProTable + ProDescriptions
- ModalForm 用 `open` + `onOpenChange` 受控模式（编辑场景），新建场景可用 `trigger`
- 操作列用 `valueType: 'option'`

### 仪表盘模式

```tsx
<PageContainer>
  <ProCard gutter={[16, 16]} direction="row">
    <StatisticCard colSpan={8} statistic={{ title: '访问量', value: 12345, trend: 'up' }} />
    <StatisticCard colSpan={8} statistic={{ title: '订单', value: 678 }} chart={<MiniArea data={data} />} />
    <StatisticCard colSpan={8} statistic={{ title: '转化率', value: '23%' }} />
  </ProCard>
  <ProCard title="销售趋势" headerBordered>
    <Line {...chartConfig} />
  </ProCard>
</PageContainer>
```

### 字段联动（ProFormDependency）

```tsx
<ProFormDependency name={['type']}>
  {({ type }) => {
    if (type === 'person') return <ProFormText name="idCard" label="身份证" />;
    if (type === 'company') return <ProFormText name="creditCode" label="信用代码" />;
    return null;
  }}
</ProFormDependency>
```

### i18n

路由 `name` 自动解析为 `menu.{name}` i18n key。组件中使用：

```tsx
const intl = useIntl();
intl.formatMessage({ id: 'pages.searchTable.createForm.ruleName', defaultMessage: '规则名称' });
// 或 JSX
<FormattedMessage id="pages.searchTable.createForm.ruleName" defaultMessage="规则名称" />
```

每个路由的 `name` 需在所有语言的 `menu.ts` 中添加对应 key。

## 配置参考

### config/config.ts

```ts
import { defineConfig } from '@umijs/max';
import defaultSettings from './defaultSettings';
import proxy from './proxy';
import routes from './routes';

export default defineConfig({
  hash: true,
  npmClient: 'pnpm',           // ← 强制 pnpm
  routes,
  proxy: proxy[process.env.UMI_ENV || 'dev'],
  fastRefresh: true,
  model: {},
  initialState: {},
  layout: { locale: true, ...defaultSettings },
  moment2dayjs: { preset: 'antd', plugins: ['duration', 'relativeTime'] },
  locale: { default: 'zh-CN', antd: true, baseNavigator: true },
  antd: { configProvider: { theme: { cssVar: true } } },
  request: {},
  reactQuery: {},
  access: {},
  mock: { include: ['src/pages/**/_mock.ts'] },
});
```

### 约定响应格式

ProTable / ProList / ProDescriptions 的 `request` 统一返回：

```ts
// 列表类
{ data: T[]; success: boolean; total: number }

// 详情类（ProDescriptions）
{ data: T; success: boolean }
```

后端返回格式不同时，在 `requestErrorConfig.ts` 或 `app.tsx` 的请求配置中用 `adaptor` 或拦截器统一适配。

## 常见陷阱

1. **版本漂移** — 旧博客引用 Umi 3、dva、umi-request。**当前 Pro v6 使用 Umi 4 Max + react-query**，不要混用旧模式。
2. **request 返回格式** — `{ data, success, total }` 是 ProTable 的核心约定，返回格式不对会导致数据不渲染。
3. **`sorter: true` = 服务端** — 会触发 request 传 `sort` 参数。本地排序用比较函数。
4. **columns 数组复用** — 同一个 `ProColumns` 数组可同时用于 ProTable、ProList、ProDescriptions，最大化复用。
5. **ProForm 子组件不可设 `value`/`onChange`** — 它们由 Form 接管，设了会变成受控组件破坏表单逻辑。用 `initialValues` / `formRef.setFieldsValue`。
6. **`transform` 返回值** — 返回标量替换字段；返回对象则合并到提交数据中（可实现字段重命名/嵌套）。
7. **`access` 依赖 `initialState`** — 路由级权限需同时启用 `access: {}` 和 `initialState: {}`。
8. **ProList 用 `columns` + `listSlot`** — 废弃的 `metas` 不要再使用。

## 按需文档检索（Layer 2）

### ProComponents 文档

| 组件 | URL |
|------|-----|
| ProTable | `https://procomponents.ant.design/components/table` |
| 可编辑表格 | `https://procomponents.ant.design/components/editable-table` |
| ProForm | `https://procomponents.ant.design/components/form` |
| SchemaForm | `https://procomponents.ant.design/components/schema-form` |
| ModalForm | `https://procomponents.ant.design/components/modal-form` |
| StepsForm | `https://procomponents.ant.design/components/steps-form` |
| QueryFilter | `https://procomponents.ant.design/components/query-filter` |
| ProForm 联动 | `https://procomponents.ant.design/components/dependency` |
| ProLayout | `https://procomponents.ant.design/components/layout` |
| PageContainer | `https://procomponents.ant.design/components/page-container` |
| ProList | `https://procomponents.ant.design/components/list` |
| ProCard | `https://procomponents.ant.design/components/card` |
| StatisticCard | `https://procomponents.ant.design/components/statistic-card` |
| ProDescriptions | `https://procomponents.ant.design/components/descriptions` |
| 组件总览 | `https://procomponents.ant.design/components` |

### Ant Design Pro 文档

| 主题 | URL |
|------|-----|
| 入门 | `https://pro.ant.design/docs/getting-started` |
| 路由与菜单 | `https://pro.ant.design/docs/router-and-menu` |
| 请求 | `https://pro.ant.design/docs/request` |
| 权限 | `https://pro.ant.design/docs/auth` |
| 布局 | `https://pro.ant.design/docs/layout` |
| OpenAPI | `https://pro.ant.design/docs/openapi` |
| Mock | `https://pro.ant.design/docs/mock-api` |
| 部署 | `https://pro.ant.design/docs/deploy` |
| i18n | `https://pro.ant.design/docs/i18n` |

### 官方预览示例

| 页面 | URL |
|------|-----|
| 分析仪表盘 | `https://preview.pro.ant.design/dashboard/analysis` |
| 表格列表 | `https://preview.pro.ant.design/list/table-list` |
| 基础表单 | `https://preview.pro.ant.design/form/basic-form` |
| 分步表单 | `https://preview.pro.ant.design/form/step-form` |
| 高级表单 | `https://preview.pro.ant.design/form/advanced-form` |
| 详情页 | `https://preview.pro.ant.design/profile/basic` |

使用 `WebFetch` 获取上述 URL 内容。使用 `zai-open-source-repository-mcp` 读取 GitHub 源码：
- `get_repo_structure("ant-design/pro-components", "src")` — 组件源码
- `get_repo_structure("ant-design/pro-components", "demos")` — 可运行示例
- `get_repo_structure("ant-design/ant-design-pro", "src/pages")` — 模板页面
