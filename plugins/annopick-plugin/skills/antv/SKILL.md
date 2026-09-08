---
name: antv
description: >
  Use when creating data visualizations with AntV — generating charts via MCP tools
  (mcp__antv-chart__generate_*), writing G2/G6/X6 code, integrating @ant-design/charts
  React components, or building dashboards with visual analytics. Triggers on AntV/G2/G6/X6
  imports, chart rendering tasks, data visualization requirements, or graph/diagram editing.
  Covers chart type selection, MCP-based image generation, and code-level integration.
allowed-tools:
  - WebFetch
  - mcp__antv-chart__generate_area_chart
  - mcp__antv-chart__generate_bar_chart
  - mcp__antv-chart__generate_column_chart
  - mcp__antv-chart__generate_line_chart
  - mcp__antv-chart__generate_scatter_chart
  - mcp__antv-chart__generate_pie_chart
  - mcp__antv-chart__generate_radar_chart
  - mcp__antv-chart__generate_dual_axes_chart
  - mcp__antv-chart__generate_histogram_chart
  - mcp__antv-chart__generate_boxplot_chart
  - mcp__antv-chart__generate_funnel_chart
  - mcp__antv-chart__generate_waterfall_chart
  - mcp__antv-chart__generate_liquid_chart
  - mcp__antv-chart__generate_word_cloud_chart
  - mcp__antv-chart__generate_sankey_chart
  - mcp__antv-chart__generate_treemap_chart
  - mcp__antv-chart__generate_venn_chart
  - mcp__antv-chart__generate_network_graph
  - mcp__antv-chart__generate_flow_diagram
  - mcp__antv-chart__generate_mind_map
  - mcp__antv-chart__generate_fishbone_diagram
  - mcp__antv-chart__generate_organization_chart
  - mcp__antv-chart__generate_spreadsheet
---

# AntV 可视化知识技能

AntV 是蚂蚁集团开源的数据可视化生态，包含 G2（统计图表）、G6（图网络）、X6（图编辑）、Ant Design Charts（React 封装）等。本技能提供两层能力：

1. **MCP 图表生成**（Layer 1）：通过 `antv-chart` MCP 服务器的 26 个 `generate_*` 工具直接生成图表图片 URL
2. **代码级集成**（Layer 2）：G2/G6/X6/Ant Design Charts 的 API 参考与开发规则

## MCP 图表生成工具

`antv-chart` MCP 服务器（`@antv/mcp-server-chart`）提供 26 个图表生成工具，调用后返回**图片 URL**，可直接嵌入 Markdown `![chart](URL)`。无需鉴权，开箱即用。

### 图表选型指南

| 数据场景 | 推荐工具 | 说明 |
|----------|----------|------|
| 时间序列趋势 | `generate_line_chart` / `generate_area_chart` | 数据含 time + value |
| 分类对比 | `generate_column_chart`（纵向）/ `generate_bar_chart`（横向） | 数据含 category + value |
| 占比/构成 | `generate_pie_chart` / `generate_treemap_chart` | 占比用饼图；层级占比用矩形树图 |
| 多维对比 | `generate_radar_chart` | name + value + group |
| 双轴对比 | `generate_dual_axes_chart` | 柱+线组合 |
| 分布 | `generate_histogram_chart` / `generate_scatter_chart` / `generate_boxplot_chart` | 直方图/散点/箱线图 |
| 转化漏斗 | `generate_funnel_chart` | 有序流程各阶段量 |
| 累计变化 | `generate_waterfall_chart` | 增量+总计 |
| 进度/达成 | `generate_liquid_chart` | 百分比水波球 |
| 文本关键词 | `generate_word_cloud_chart` | text + value |
| 流向/转移 | `generate_sankey_chart` | source + target + value |
| 集合关系 | `generate_venn_chart` | sets + value |
| 网络关系 | `generate_network_graph` | nodes + edges |
| 流程图 | `generate_flow_diagram` | nodes + edges |
| 思维导图 | `generate_mind_map` | name + children |
| 鱼骨图 | `generate_fishbone_diagram` | name + children |
| 组织架构 | `generate_organization_chart` | name + children + description |
| 数据表格 | `generate_spreadsheet` | Record[] + pivot 配置 |

### 工具数据格式速查

```js
// 折线/面积图
generate_line_chart({ data: [{time:'2024-01',value:100,group:'A'}], axisXTitle:'月份', axisYTitle:'销量' })

// 柱状/条形图（支持分组/堆叠）
generate_column_chart({ data: [{category:'Q1',value:200,group:'产品A'}], group:true, stack:true })

// 饼图（innerRadius > 0 为环形）
generate_pie_chart({ data: [{category:'搜索',value:60}], innerRadius: 0.5 })

// 双轴图
generate_dual_axes_chart({ categories:['Q1','Q2','Q3'], series:[
  { type:'column', data:[100,200,150], axisYTitle:'销量' },
  { type:'line', data:[0.8,0.9,0.85], axisYTitle:'转化率' }
]})

// 桑基图
generate_sankey_chart({ data:[{source:'首页',target:'列表',value:500}] })

// 网络图
generate_network_graph({ nodes:[{name:'Alice'},{name:'Bob'}], edges:[{source:'Alice',target:'Bob',name:'朋友'}] })

// 思维导图（最多 3 层）
generate_mind_map({ name:'根节点', children:[{name:'子节点A',children:[{name:'孙节点'}]}] })

// 组织架构图
generate_organization_chart({ name:'CEO', children:[{name:'CTO',description:'技术'}], orient:'LR' })

// 水波球（进度）
generate_liquid_chart({ percent: 0.75, shape:'circle' })

// 透视表
generate_spreadsheet({ data:[{region:'华东',product:'A',sales:100}], rows:['region'], columns:['product'], values:['sales'] })
```

### 公共参数

所有图表工具支持：

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `theme` | `'default' \| 'academy' \| 'dark'` | `'default'` | 主题 |
| `width` | `number` | `600`（地图 `1600`） | 图宽 |
| `height` | `number` | `400`（地图 `1000`） | 图高 |
| `title` | `string` | — | 图表标题 |
| `axisXTitle` / `axisYTitle` | `string` | — | 轴标题（轴类图表） |
| `style.backgroundColor` | `string` | — | 背景色 |
| `style.palette` | `string[]` | — | 自定义色板 |
| `style.texture` | `'default' \| 'rough'` | `'default'` | 手绘风格 |
| `style.startAtZero` | `boolean` | `false` | Y 轴从零开始 |

## 代码级集成

### Ant Design Charts（React 封装，推荐用于 Pro 项目）

```bash
pnpm add @ant-design/charts
```

```tsx
import { Line, Column, Pie, Bar, Area, Scatter } from '@ant-design/charts';

const config = {
  data: [{ time: '2024-01', value: 100 }],
  xField: 'time',
  yField: 'value',
  seriesField: 'group',  // 分组
  smooth: true,
};

<Line {...config} />
```

常用组件：`Line` `Area` `Column` `Bar` `Pie` `Scatter` `Histogram` `Heatmap` `Treemap` `Gauge` `DualAxes` `Funnel` `Waterfall` `Tiny.Line` / `Tiny.Area` / `Tiny.Column`（迷你图，用于 StatisticCard）。

在 Pro 项目中，Ant Design Charts 常嵌入 `StatisticCard` 的 `chart` 槽位或 `ProCard` 中展示。

### G2 v5（底层可视化语法）

```bash
pnpm add @antv/g2
```

**G2 v5 Spec Mode** — 使用 `chart.options()` 一次性声明完整配置：

```js
import { Chart } from '@antv/g2';

const chart = new Chart({ container: 'container', autoFit: true });

chart.options({
  type: 'interval',           // 标记类型
  data: [{ genre: 'Sports', sold: 275 }],
  encode: { x: 'genre', y: 'sold', color: 'genre' },  // 视觉通道映射
  transform: [{ type: 'stackY' }],  // 变换（必须数组）
  labels: [{ text: 'sold' }],       // 标签（复数 labels）
  scale: { y: { type: 'linear' } }, // 比例尺
  axis: { x: { title: '类型' } },   // 坐标轴
});

chart.render();
```

**核心概念**：

| 概念 | 说明 |
|------|------|
| **Chart** | 核心入口，`new Chart({ container, width, height, autoFit, theme })` |
| **Mark（标记）** | 基本视觉单元。类型：`interval` `line` `area` `point` `rect` `cell` `text` `image` `link` `box` `heatmap` `treemap` `sankey` `wordCloud` `gauge` `liquid` 等 |
| **encode（视觉通道）** | 数据字段 → 视觉属性映射：`x` `y` `color` `size` `shape` `y1`（范围编码） |
| **Scale（比例尺）** | 数据 → 视觉值转换：`linear` `band` `point` `time` `log` `pow` `ordinal` 等。**不要过度指定 type**，G2 自动推断 |
| **Coordinate（坐标系）** | `cartesian`（默认）`polar` `theta` `radial` 等。转置是 **transform**，不是坐标系类型 |
| **Transform（变换）** | 标记级：`stackY` `dodgeX` `normalizeY` `binX` `jitter` `sortX` 等；数据级（`data.transform`）：`fold` `filter` `sort` `map` `kde` |
| **Composition（组合）** | 多标记叠加用 `type: 'view'` + `children` 数组；复杂布局用 `spaceLayer` / `spaceFlex` / `facetRect` |

**G2 v5 硬规则**：
1. **禁用 v4 链式 API** — `.interval().encode().style()` 形式在 v5 中不可用
2. **`chart.options()` 仅调用一次** — 多次调用会覆盖；多标记用 `type: 'view'` + `children`
3. **`transform` 必须是数组** — `transform: [{ type: 'stackY' }]`
4. **标签用复数 `labels`** — `labels: [{ text: 'value' }]`
5. **`children` 不可嵌套** — 复杂布局用 `spaceLayer` / `spaceFlex`
6. **动画默认开启** — 仅在明确要求时添加 `animate` 配置

### G6 v5（图网络可视化）

```bash
pnpm add @antv/g6
```

```js
import { Graph } from '@antv/g6';

const graph = new Graph({
  container: 'container',
  data: {
    nodes: [{ id: 'node1', data: { x: 100, y: 100 } }],
    edges: [{ source: 'node1', target: 'node2' }],
  },
  node: { style: { size: 20 } },
  layout: { type: 'force' },
  behaviors: ['zoom-canvas', 'drag-element'],
});

graph.render();
```

核心概念：`Graph`（实例）、`Node`（节点，形状 `circle`/`rect`/`diamond`/`image`）、`Edge`（边）、`Combo`（分组）、`Layout`（布局算法：力导向/网格/树/辐射等）、`Behavior`（交互：缩放/拖拽/框选）、`Plugin`（插件：minimap/toolbar/tooltip）。

### X6（图编辑/流程图）

```bash
pnpm add @antv/x6 @antv/x6-react-shape
```

```js
import { Graph } from '@antv/x6';

const graph = new Graph({
  container: document.getElementById('container'),
  width: 800, height: 600,
  background: { color: '#f5f5f5' },
  grid: { visible: true },
});

graph.fromJSON({
  nodes: [
    { id: 'node1', shape: 'rect', x: 40, y: 40, width: 100, height: 40, label: '开始',
      attrs: { body: { fill: '#52c41a' } } },
  ],
  edges: [
    { source: 'node1', target: 'node2', label: '流转' },
  ],
});
```

**React 自定义节点**：
```tsx
import { Register } from '@antv/x6-react-shape';
Register({ shape: 'my-react-node', width: 200, height: 60, component: MyComponent });
// 使用：graph.addNode({ shape: 'my-react-node', ... })
```

核心概念：`Graph`（画布）、`Shape`（内置形状）、`Node`（`id`/`shape`/`x`/`y`/`width`/`height`/`label`/`attrs`）、`Edge`（`source`/`target`/`label`/`attrs`）、`Port`（连接桩）、`Markup`（自定义 SVG 结构）。

## 开发规则

1. **Pro 项目优先用 `@ant-design/charts`** — React 封装，配置式 API，与 antd/Pro 风格一致。
2. **需要深度定制时降级到 G2** — `@ant-design/charts` 底层基于 G2，可通过 `chartRef` 获取底层实例。
3. **G2 v5 严格用 Spec Mode** — 不混用 v4 链式 API。
4. **图表配色用 `style.palette` 或 G2 theme** — 不硬编码颜色值。
5. **响应式图表** — G2 用 `autoFit: true`；Ant Design Charts 默认自适应容器。
6. **MCP 工具用于快速预览/报告** — 生成图片 URL 用于文档和即时反馈；正式产品代码用 React 组件。
7. **X6 画布交互** — 需要显式注册 `interactions` / `behaviors`，不会自动启用拖拽缩放。

## 按需文档检索（Layer 2）

| 库 | 文档 URL |
|----|----------|
| G2 v5 | `https://g2.antv.antgroup.com/manual/extra-topics/overview` |
| G2 v5 API | `https://g2.antv.antgroup.com/api/overview` |
| G2 v5 示例 | `https://g2.antv.antgroup.com/examples` |
| G6 v5 | `https://g6.antv.antgroup.com/manual/introduction` |
| G6 v5 示例 | `https://g6.antv.antgroup.com/examples` |
| X6 | `https://x6.antv.antgroup.com/tutorial/about` |
| X6 API | `https://x6.antv.antgroup.com/api/graph` |
| Ant Design Charts | `https://charts.ant.design/docs/en` |
| Ant Design Charts 示例 | `https://charts.ant.design/demos` |
| MCP Server 源码 | GitHub: `antvis/mcp-server-chart` |

使用 `WebFetch` 获取文档内容；使用 `zai-open-source-repository-mcp` 读取 GitHub 源码：
- `get_repo_structure("antvis/G2", "site")` — G2 文档与示例
- `get_repo_structure("ant-design/ant-design-charts", "src")` — Charts 组件源码
