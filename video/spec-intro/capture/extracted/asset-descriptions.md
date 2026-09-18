# Asset inventory

不抓站（no-capture path）：源材料是仓库自身，视觉全部为原生构建的动态图形，无需外部素材。

| Asset | 来源 | 用在哪 |
|---|---|---|
| 安装命令文本 | README.md 的 Install 段，逐字引用 | `01-install` 终端窗口 |
| `/spec` `/build` `/yolo` 三命令语义 | README.md「How it works」+ 各 SKILL.md | `02-usage` 三门卡片 |
| 探针自测输出形态 | `.spec/probes/G13-archive-pointers.sh --selftest` 真实输出 | `04-capabilities` 终端窗口 |
| 22 条探针全绿 | 本会话真实回归结果（仓库 G2–G13 + eval 探针） | `05-proof` 勾选阵列 |
| 仓库地址 | github.com/suifei/spec | `05-proof` 片尾 |

无位图/图标/logo 需要下载；全部用 HTML/CSS 生成。
