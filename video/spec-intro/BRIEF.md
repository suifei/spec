---
workflow: product-launch-video
flow: automation
storyboard: no
message: "规格不是文档，是契约——先把该定的定下来，再动工"
destination: github-readme
aspect: 1920x1080
language: zh
audience: "用 Claude Code 写代码的开发者"
length: 75s
angle: product
style_preset: code-editorial
---

## Intent

给 `github.com/suifei/spec` 的 `/spec` skill 做一支可嵌进 README 的宣传片。观众是已经在用
Claude Code、但吃过"AI 写得快、回头对不上"苦头的开发者。调性要像这个工具本身：克制、讲证据、
不吹牛——它自己的文档里连"能变红的探针"都要做负控，片子也不能靠形容词堆。

六段，每段只讲一个点，可单独成片也可连播：

1. `01-hook` — 问题：需求散在聊天里、一路绿灯却说不清凭什么
2. `02-install` — 一行命令装好，只碰 `.claude/`
3. `03-gates` — 三个命令是三道门：`/spec` → `/build` → `/yolo`
4. `04-collab` — 人机协同：AI 扛重活，只有真分叉才问你；诚实说"不"
5. `05-probe` — 核心能力：探针必须能变红、Intent/Acceptance/Method、独立评审、文件系统即记忆
6. `06-proof` — 效果：自己管自己，22 条探针全绿；独立审计抓出自我夸大并逐条改掉

## Assets

- ../narration/01-hook.txt … ../narration/06-proof.txt — 六段中文旁白定稿，已按 NowVoice
  停顿标记规则插好 `(⏱️=Xs)`，逐段对应上面的 frame id。
- 源材料是本仓库自身（SPEC.md、.spec/probes/、README.md），不抓站。

## Customizations

- 视觉沿用仓库自己的 GitHub 暗色语汇（#0d1117 底、#3fb950 绿门、#f85149 红探针），
  让片子看起来就是这个工具的栖息地。
- `05-probe` 必须真实演一次"探针变红再变绿"——这是整个产品的核心主张，不能只用文字说。
- 片尾落 `github.com/suifei/spec`。

## Notes

- **配音链路受限**：本会话出口策略拦截 nowvoice.ai / HeyGen / HuggingFace，容器内无可用 TTS
  （Kokoro 模型也下不来）。用户已决定先放行域名再补配音。故先按估算时长出无声成片，
  配音到位后用 `audio.mjs sync-durations` 校准并重渲。
- 片子发布在 GitHub README，需自动播放友好：控制体积，优先 H.264 + faststart。
- 不要出现未经证实的性能/效果数字；"22 条探针全绿"是本仓真实回归结果，可用。
