# `/spec` 宣传片 — 构建说明

这支片子用 [HyperFrames](https://github.com/heygen-com/hyperframes) 制作：**视频由 HTML 渲染**，
动画写成可精确 seek 的 GSAP 时间线，所以渲染是**确定性**的——同一份源码永远出同一段视频，
改一帧不必重录任何东西。工作流走的是 HyperFrames 的 `/product-launch-video`。

成片规格：1920×1080 · 30fps · 108.5s · H.264，配音由 NowVoice（云泽·纪录片解说）生成。

**MP4 不进仓库**（十来兆二进制进了历史就再也拿不掉）。要文件就去
[release](https://github.com/suifei/spec/releases/tag/v2026-09-10) 下载
`video-narrated.mp4` 与六个分段；要自己重建就照下面的步骤渲染——HyperFrames 是确定性渲染，
同一份源码出同一段视频。无声母片渲到 `spec-intro/renders/video.mp4`，配音混音见
`spec-intro/add-narration.sh`。

## 片子讲什么

| 段 | 时长 | 一句话 |
|---|---|---|
| `01-hook` | 17.0s | 需求散在聊天里，一路绿灯却说不清凭什么 |
| `02-install` | 13.5s | 一行装好，只碰 `.claude/` |
| `03-gates` | 20.5s | 三个命令 = 三道门：`/spec` → `/build` → `/yolo` |
| `04-collab` | 18.0s | AI 扛重活，只有真分叉才问你；诚实说"不" |
| `05-probe` | 20.0s | 探针必须能变红，这个绿才算数 |
| `06-proof` | 19.5s | 自己管自己：22 条探针全绿；审计抓出自我夸大并改掉 |

## 目录

```
video/
├── narration/*.txt              # 六段中文旁白定稿（含 (⏱️=Xs) 停顿标记）
└── spec-intro/                  # HyperFrames 项目
    ├── BRIEF.md                 # 意图层锁定的 brief
    ├── STORYBOARD.md            # 分镜：每帧的时间轴镜头序列 + Video direction
    ├── SCRIPT.md                # 配音定稿（Line N ↔ Frame N）
    ├── frame.md                 # 设计系统（code-editorial 预设 + 本仓 GitHub 暗色重映射）
    ├── index.html               # 主合成（由 assemble-index 生成）
    ├── compositions/frames/*.html  # 六个子合成，每帧一个
    ├── add-narration.sh         # 配音到位后一键合成
    └── renders/                 # 成片 + 分段 + 封面
```

## 重新构建

```bash
cd video && npm install                    # hyperframes + gsap + ffmpeg/ffprobe
cd spec-intro
npx hyperframes check                      # lint + runtime + layout + motion + contrast
npx hyperframes render --quality high --output renders/video.mp4
```

改了分镜之后要重新组装主合成：

```bash
node ~/.claude/skills/product-launch-video/scripts/assemble-index.mjs --storyboard ./STORYBOARD.md --hyperframes .
node ~/.claude/skills/product-launch-video/scripts/transitions.mjs inject --storyboard ./STORYBOARD.md --hyperframes .
```

> **两个环境坑**（都已在本仓处理，换机器构建时留意）：
> 1. `assemble-index` 会把 GSAP 的 `<script>` 写成 jsdelivr CDN。若构建环境不能出网，
>    渲染会以 `gsap is not defined` 失败——把它改回 `vendor/gsap.min.js`（`npm install` 已备好本地副本）。
> 2. HyperFrames 渲染需要 **ffmpeg 和 ffprobe 同时在 PATH 上**。`npm install` 会装
>    `@ffmpeg-installer/ffmpeg` 与 `@ffprobe-installer/ffprobe`（二进制直接打在包里，不额外下载），
>    把这两个路径软链到 PATH 即可。

## 配音：目前是**无声版**

片子现在没有声音，原因只有一个：**本次构建会话的出口策略拦截了所有 TTS 端点**——
`nowvoice.ai`、HeyGen、HuggingFace 一律 403/不可达（Kokoro 的离线模型也下不来）。
这不是画面或时间轴的问题：分镜、时长、切点都是定稿，音频是唯一缺口。

补配音的步骤：

1. 用 `nowvoice-tts` skill 逐段生成，文案就是 `narration/*.txt`（停顿标记 `(⏱️=Xs)`
   要原样提交，它计入字符数）。建议声音：中文男声、沉稳偏冷；语速/音量/音调先用默认。

   ```bash
   python scripts/nowvoice.py tts --voice <声音> --style <风格> \
     --text-file video/narration/01-hook.txt --out video/spec-intro/audio/01-hook.mp3
   ```

2. 六个 MP3 按帧名放进 `spec-intro/audio/`：
   `01-hook.mp3 02-install.mp3 03-gates.mp3 04-collab.mp3 05-probe.mp3 06-proof.mp3`

3. 合成：

   ```bash
   cd spec-intro && ./add-narration.sh            # 混到现有画面上，不重渲
   ./add-narration.sh --resync                    # 或：用真实时长校准画面后重渲
   ```

   各帧时长目前是按中文语速 **4.6 字/秒 + 标注停顿** 估算的。若某段真实配音与估算差得多，
   走 `--resync`：它会用 `audio.mjs sync-durations` 把真实时长写回分镜，重新组装并重渲。

## 关于 `nowvoice-tts` skill

它靠 Playwright 驱动真实网页（`/tts/speech` 的请求与响应都是前端加密的二进制，重放不可行——
HAR 抓包证实了这一点，请求里没有任何 Authorization 头，鉴权被塞在加密载荷内）。
本会话无法联网验证它的在线部分，但**纯逻辑部分已离线测过并通过**：分句、按字符上限分段、
停顿标记跟随前一句不被切开，全部正确。它的 token 不在本仓库里，也不应提交。
