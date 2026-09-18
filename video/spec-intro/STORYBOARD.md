---
format: 1920x1080
duration: 108s
message: "规格不是文档，是契约——先把该定的定下来，再动工"
arc: "问题 → 上手 → 三道门 → 人机分工 → 证据机制 → 自证收尾"
audience: "用 Claude Code 写代码、吃过“AI 写得快但回头对不上”苦头的开发者"
mode: autonomous
music: none
language: zh
---

# STORYBOARD — spec-intro

六帧，每帧只讲一个点，可单独成片也可连播。视觉语汇沿用仓库自身的 GitHub 暗色
（`frame.md` 已把品牌 token 映射进 code-editorial 预设）：`canvas` 深底、`ink` 亮字、
绿=门通过、红=探针变红、蓝/紫=命令标识。全部图形原生构建，无外部素材。

## Frame 1 — 问题：说不清的那句"完成了"

- status: animated
- src: compositions/frames/01-hook.html
- duration: 17s
- transition_in: cut
- scene: 聊天碎片四散漂浮、逐条湮灭，`/spec` 从残骸中立起
- voiceover: "AI 写代码不慢。慢的是回头确认——它做的到底是不是你要的。需求散在聊天里，一路绿灯，却说不清凭什么。动工之前，先把该定的定下来。"
- type: pain_point
- persuasion: Pain agitation → promise
- beat: 焦虑 → 定心
- asset_candidates: none — 全部原生 HTML/CSS 图形，无外部素材文件
- blueprint: overwhelm-surround (Adapt)
- focal: `/spec` 字标
- roles: 聊天碎片 = supporting（环绕、低对比）· 网格底 = background（dim ~85%）· `/spec` 字标 = cutout
- poster: 14

Adapt：保留"碎片环绕主体并制造压迫感"的签名动作；不做 360° 包围，改为**碎片向上飘散并湮灭**——
漂移即是本片的论点（需求会变形），湮灭让出中心给字标。

Scene 1 (0.0–3.0s): 纯深底 + 细网格（dim ~85%）。五片聊天气泡在画面四周依次淡入并轻微旋斜，
  错峰入场；每片只是一句改口的需求。满幅散布，3 层景深。此刻无标题——VO 还在说"不慢"。
Scene 2 (3.0–7.0s): VO 转到"回头确认"时，碎片开始整体上浮、透明度衰减，边缘先散；
  中心空出。碎片湮灭的节奏踩在"确认"二字上。
Scene 3 (7.0–11.0s): VO 念"散在聊天里、说不清凭什么"——两行红色短句从左错峰滑入，
  贴在下三分之一；同时最后两片碎片消失。左对齐，密度低。
Scene 4 (11.0–14.0s): `/spec` 字标从中心偏左由下浮起并定住，绿色，等宽字体，占约 30% 画宽；
  其上方 kicker "CLAUDE CODE · GATE 1" 先行 0.3s 淡入。
Scene 5 (14.0–17.0s): VO 落"先把该定的定下来"——该句以亮字在字标下方浮出并**静止保持**；
  全帧无其他运动，静读到底（对抗前四段的躁动）。

## Frame 2 — 安装：一行，且只碰 .claude

- status: animated
- src: compositions/frames/02-install.html
- duration: 13.5s
- transition_in: crossfade
- scene: 终端中逐字敲出安装命令，回显三个命令；左右两栏对照"只写/不碰"
- voiceover: "安装只有一行。在你的项目里跑一句，三个命令就位。它只写 .claude 目录，你的代码和规格，一个都不碰。"
- type: onboarding
- persuasion: Friction removal（低门槛 + 不侵入）
- beat: 轻快、利落
- asset_candidates: none — 全部原生 HTML/CSS 图形，无外部素材文件
- blueprint: typewriter-reveal (Reproduce)
- focal: 终端窗口
- roles: 终端窗口 = cutout · 文件清单两栏 = supporting · 网格底 = background（dim ~85%）
- poster: 11

Scene 1 (0.0–2.0s): 标题"安装 · 一行"左上入场；终端窗口从下浮起并定位于上半幅，
  居中偏上，占约 78% 画宽。窗口内只有提示符与光标。
Scene 2 (2.0–5.5s): VO 说"跑一句"——命令逐字敲出（等宽、单行不换行），光标随字前移；
  签名动作：打字揭示本身就是这一帧的主运动。
Scene 3 (5.5–7.5s): 回车后一行绿色回显淡入：`✓ installed /spec /build /yolo`，
  三个命令名各自带色（绿/蓝/紫），与后一帧的三道门建立颜色伏笔。
Scene 4 (7.5–11.0s): VO 念"只写 .claude 目录"——左栏三行绿勾从左错峰滑入（写入的路径）；
  紧接"一个都不碰"——右栏四行灰点从右错峰滑入（不碰的文件）。左右 55/45 分栏，密度中等。
Scene 5 (11.0–13.5s): 底部一行亮字浮出"打开 Claude Code，敲 /spec 就能开始"，随后**静止保持**。

## Frame 3 — 三个命令，是三道门

- status: animated
- src: compositions/frames/03-gates.html
- duration: 20.5s
- transition_in: crossfade
- scene: 三张门卡依次点亮，箭头串联成一条流水线
- voiceover: "三个命令，是三道门。spec 把模糊的想法，变成能落地的规格。build 按规格写码——计划每次重生成、从不留存，没有中间层，就没有漂移。yolo 是同一套规则的自动挡。"
- type: mechanism
- persuasion: Mechanism clarity（把产品拆成可理解的三段）
- beat: 递进、稳
- asset_candidates: none — 全部原生 HTML/CSS 图形，无外部素材文件
- blueprint: grid-card-assemble (Adapt)
- focal: 三张门卡
- roles: 门卡 ×3 = cutout · 连接箭头 = supporting · 网格底 = background（dim ~85%）
- poster: 17

Adapt：保留"卡片依次就位拼成整体"的签名动作；不做网格矩阵，改为**横向三段流水线**——
顺序即是语义（门必须按序过），所以卡片按 VO 点名逐张点亮，而非一次铺开。

Scene 1 (0.0–2.5s): 标题"三个命令，是三道门"入场，"三道门"以绿字强调。画面其余为空。
Scene 2 (2.5–7.0s): VO 念 spec——第一张卡从下弹入并定住，顶边绿色高亮条先行绘出；
  卡内依次落"/spec / Gate 1 / 想法 → 契约"。左起三分之一，卡片占约 30% 画宽。
Scene 3 (7.0–13.0s): VO 念 build——箭头由左向右描出，第二张卡弹入（蓝色顶条）；
  卡内"从不留存"以红字落位，随后"= 没有漂移"补上。三卡等宽横排，2 层景深。
Scene 4 (13.0–17.5s): VO 念 yolo——第二支箭头描出，第三张卡弹入（紫色顶条），
  卡内"自循环 · 自评审 · 完事自删定时器"错峰落位。至此三卡齐备。
Scene 5 (17.5–20.5s): 底部居中浮出一行"改变的是节奏，从不改变规则"，
  "节奏"与"规则"以绿字点出；三卡**静止保持**，无漂移无呼吸。

## Frame 4 — 人机协同：只有真分叉才问你

- status: animated
- src: compositions/frames/04-collab.html
- duration: 18s
- transition_in: crossfade
- scene: 左栏 AI 扛的重活逐条落定，右栏只有三件事亮起；底部一条"说不"的红边引述
- voiceover: "它不是听话的记录员。能查的自己查，能定的自己定，理由写进决策日志。只有取舍、优先级、风险才来问你，一次问清。想法被证据否掉，它会直接说不行。"
- type: differentiation
- persuasion: Contrast（与"顺从的 AI 助手"划清界限）
- beat: 冷静、有主张
- asset_candidates: none — 全部原生 HTML/CSS 图形，无外部素材文件
- blueprint: comparison-split (Reproduce)
- focal: 左右两栏对照
- roles: 左栏（AI 重活）= cutout · 右栏（你的分叉）= cutout · 底部引述 = supporting
- poster: 15

Scene 1 (0.0–2.5s): 标题"它不是听话的记录员"入场，"听话的记录员"压暗处理。画面其余为空。
Scene 2 (2.5–8.0s): VO 念"能查的自己查…"——左栏面板浮起，栏内五行逐条从左滑入，
  错峰落位，每行前置绿色箭标。左右 55/45，左栏先建立密度。
Scene 3 (8.0–13.0s): VO 念"只有取舍、优先级、风险"——右栏面板弹入（琥珀色描边），
  三个词以大号字依次弹出，一词一拍，对齐 VO 的三次点名；右栏刻意留白，与左栏的密集形成反差。
Scene 4 (13.0–16.0s): 右栏底部补一行小字"一次问清 · 不做填表式骚扰"，淡入。
Scene 5 (16.0–18.0s): VO 落"它会直接说不行"——底部红色左边条的引述块整体浮起，
  "诚实，包括说不"以红字等宽落位，随后**静止保持**。

## Frame 5 — 核心能力：能变红，这个绿才算数

- status: animated
- src: compositions/frames/05-probe.html
- duration: 20s
- transition_in: crossfade
- scene: 终端里真实跑一次探针自测——两次变红、一次变绿，再落三张能力卡
- voiceover: "底线只有一条：证据不能是空话。每道承重的门，背后是一个能真的变红的探针。变不红的检查，本身就不算数。生成类成果还要过独立评审——全新上下文，不许自己审自己。"
- type: proof_mechanism
- persuasion: Falsifiability（可证伪 = 可信）
- beat: 克制、锋利
- asset_candidates: none — 全部原生 HTML/CSS 图形，无外部素材文件
- blueprint: agent-progress-theater (Adapt)
- focal: 终端窗口（探针自测）
- roles: 终端窗口 = cutout · 三张能力卡 = supporting · 红色闪光 = background（瞬时）
- poster: 17

Adapt：保留"进度在终端里逐行推进、观众读着结果走"的签名动作；把"任务完成"换成
**负控先红、正控后绿**——本片最核心的一次演示：证据的可信来自它能失败。

Scene 1 (0.0–3.0s): 标题"底线只有一条：证据不能是空话"入场，后半句绿字。
  终端窗口随即从下浮起并定位上半幅，标题栏显示 `--selftest` 命令，窗体内为空。
Scene 2 (3.0–7.0s): VO 念"能真的变红"——第一行 `RED` 落入，同时整窗一次极短的红色泛光
  （瞬时，不留残留）；紧接第二行 `RED` 落入，再泛一次。两次变红是本帧的情绪高点。
Scene 3 (7.0–10.0s): 第三行 `GREEN` 落入，颜色转绿；下方补一行"自测通过 —— 能变红，这个绿才算数"，
  其中后半句以琥珀色点出。终端至此读完，保持静止。
Scene 4 (10.0–16.0s): VO 念"三样东西 / 独立评审"——下半幅三张能力卡自左向右错峰浮起：
  `Intent / Acceptance / Method`（蓝）、`独立评审`（紫）、`文件系统即记忆`（琥珀）。
  三卡等宽横排，密度中等，2 层景深。
Scene 5 (16.0–20.0s): 卡片全部就位后**静止保持**；仅"不许自己审自己"一行在紫卡内
  延后 0.4s 淡入作为落点，此后全帧无运动。

## Frame 6 — 效果：它自己管着自己

- status: animated
- src: compositions/frames/06-proof.html
- duration: 19.5s
- transition_in: crossfade
- scene: 22 个绿勾逐个落位成阵，审计引述浮起，收束到片尾字标与仓库地址
- voiceover: "它自己管着自己。这个仓库的规格和探针，就是它跑出来的——二十二条探针，全绿。一次独立审计抓出了它的自我夸大，然后逐条改掉。规格不是文档。是契约。"
- type: proof_outcome
- persuasion: Self-evidence（产品以自身为证据）+ 诚实（承认并修正自我夸大）
- beat: 收拢、落定
- asset_candidates: none — 全部原生 HTML/CSS 图形，无外部素材文件
- blueprint: dataviz-countup (Adapt)
- focal: 22 格绿勾阵列 → 片尾字标
- roles: 勾阵 = cutout · 审计引述 = supporting · 片尾字标 = cutout
- poster: 17

Adapt：保留"数字随视觉一起长出来"的签名动作；把计数环换成**22 格勾阵逐格点亮**，
计数字随之递增——阵列本身就是回归套件的形状，比抽象圆环更贴事实。

Scene 1 (0.0–3.0s): 标题"它自己管着自己"入场，"自己管着自己"绿字；下方一行说明淡入。
Scene 2 (3.0–8.0s): VO 念"就是它跑出来的"——22 个绿勾以波浪次序逐格点亮，
  每格轻微弹入；满幅偏左铺开，约占 60% 画宽。节奏密而不乱。
Scene 3 (8.0–11.0s): 勾阵下方落一行"22 条探针 · 真跑 + 负控 · 全绿"，
  其中"22"以大号绿字随勾阵收尾同拍落定。
Scene 4 (11.0–15.5s): VO 念审计——琥珀色左边条的引述块浮起，
  "干净上下文的独立审计"以琥珀点出，"逐条改掉"以绿字点出。此处是全片诚实度的落点。
Scene 5 (15.5–19.5s): 引述块淡出让位；片尾两行居中浮起：
  "规格不是文档。是契约。"（后半句绿字，字号最大），其下 `github.com/suifei/spec` 蓝色等宽。
  最终**静止保持**至片尾，无退场动画。

## Video direction

- **一句话**：这支片子要像它介绍的工具——克制、讲证据、不靠形容词。凡是能"演"的（探针变红、
  勾阵全绿、命令逐字敲出），一律演出来，不用文字断言代替。
- **调色**：`frame.md` 的品牌映射为准。深底恒定，颜色只在语义处出现——绿=通过/确定，
  红=探针变红/问题，蓝=`/build` 与链接，紫=`/yolo`，琥珀=需要人拍板 / 诚实提醒。禁止装饰性用色。
- **排版**：中文正文用 body ramp，命令/路径/探针输出一律等宽。中文标点全角，
  代码与路径逐字保真（`.claude/`、`/spec` 不得改写）。
- **运动**：统一长尾缓动（power3 族），入场以浮起与错峰为主，绝不弹跳。
  每帧末尾必须**静止保持**——本片的节奏对比来自"动过之后的定"，不靠持续漂移。
  禁止任何呼吸/缓慢推镜填充后半段。
- **节奏分配**：Frame 1 与 Frame 5 是两个情绪高点（前者躁动收束，后者红绿反差），
  Frame 2 与 Frame 6 相对安静，Frame 3、4 为中速推进。避免全片均匀忙碌。
- **过渡**：首帧 `cut` 直入，其余 `crossfade`。每帧自身不写退场，交给 harness。
- **音频**：`music: none`（本会话出口策略拦截音乐库）。旁白为唯一音轨，
  各帧时长为按语速的估算值；配音到位后由 `audio.mjs sync-durations` 覆盖。
- **不做的事**：不编造性能数字；不出现未经本仓验证的效果承诺；
  "22 条探针全绿"是真实回归结果，可用且仅此一处量化主张。
