# 数据卡（Data Card · 中文版）

> **说明**：本文件是 [`DATA_CARD.md`](DATA_CARD.md) 的中文译本，供中文读者阅读参考。英文原版由数据生产流水线产出，为权威记录（canonical）；如两版存在出入，以英文版为准。
>
> **Note**: This file is a Chinese translation of [`DATA_CARD.md`](DATA_CARD.md) for reference. The English original is the pipeline-generated canonical record; in case of discrepancy, the English version prevails.

## 数据集概览

- 规模：9 个实例，覆盖 C、C++、Go、Java、TypeScript。
- 来源：公开的 GitHub issue / PR 及其对应仓库代码。
- 轨迹：由调用 kimi-k3 的 mini-swe-agent 生成，并经真实 Docker 评分验证。
- 环境：9 个版本钉定的 `linux/amd64` Docker 镜像。
- 质量门禁：gold 补丁可干净应用并通过全部声明的 F2P / P2P；智能体补丁解决全部 F2P 且零 P2P 回归；训练价值分 ≥ 6。逐实例分数与明细记录于 task、environment 与 INDEX 中。
- 轨迹可学习性：`trajectory_quality` 额外记录思考质量、机械过渡比、失败恢复、行为类别与会话时长。该证据不与任务可解性分数混用，也不作为发布硬门禁。

## 筛选标准

9 个实例选自 kimi-k3 mini-swe-agent 运行结果。全部通过 ship_gates、F2P/P2P 评分验证为 resolved、MIT 许可、validation_version=5。语言分布：C（2）、C++（2）、Go（2）、Java（2）、TypeScript（1）。入选实例：c-ares__c-ares-1137、lvgl__lvgl-10308、jbeder__yaml-cpp-1373、jarro2783__cxxopts-314、urfave__cli-2275、gin-gonic__gin-4622、jhy__jsoup-2476、jhy__jsoup-2483、typescript-eslint__typescript-eslint-12003。

## 评测协议边界

- SWE-bench 官方协议对每个候选补丁执行单次 `run_instance`：runner 通过回退链应用候选补丁，随后评测脚本恢复基线测试文件、应用 `test_patch` 并执行该仓库/版本的测试命令。gold 补丁作为候选补丁单独评测，绝不与模型补丁在同一次运行中合并。本协议钉定于上游 commit `f7bbbb2ccdf479001d6467c9e34af59e44a840f9`。
- 本包中保存的 `gold_pre` 是发布方的健全性预检，用于证明 F2P 在基线上确实失败；它不属于 SWE-bench 官方评测阶段。
- 内置评测器按官方顺序尝试 `git apply --verbose`、`git apply --verbose --reject`、`patch --batch --fuzz=5 -p1 -i <patch-file>`。生产发布门禁更严格：gold/model 补丁在生产评分中必须通过一级 `git apply` 干净应用。
- `resolution_status` 采用官方三级 `FULL` / `PARTIAL` / `NO`；仅 `FULL` 置 `graded_resolved=true`。`PARTIAL` 原样记录，且不得进入本完整发布包。
- `evaluation_type` 按仓库具体情况选择 `PASS_AND_FAIL` 或 `FAIL_ONLY`。PASS_AND_FAIL 模式下，缺失的测试按失败处理；FAIL_ONLY 模式下 P2P 可以为空。两种模式均仅将显式 `FAILED` 视为失败（本流水线额外将 `ERROR` 按失败保守处理）。按官方语义，pytest 的 `XFAIL`（别名 `XFAILED`）计为通过。
- `test_command_source` 标示命令来源。当前的 2026 扩展任务使用 `claudedata_registry_scoped` 并经反复虚拟机实跑验证；在引入带逐仓库/版本/命令核验的固定官方规格快照之前，打包器会拒绝 `official_map_repo_version_specs`，以防止自定义命令冒充官方规格。`test_command_sha256` 将实际评分命令绑定，防止验证后被篡改。

## 发布证据

每个实例的 `task.jsonl`、`environment.json`、`swe_bench_instance` 与 `INDEX.jsonl` 在全部四个位置一致地持久化以下审计字段，供独立第三方核验：

- **污染**：`contamination_level` / `contamination_factors`（高污染直接拒绝；中污染仅在因素完全披露时允许）
- **已验证评分细则**：`verified_rubric_version` / `verified_rubric_model` / `verified_ps_severity` / `verified_tv_severity` / `verified_issues` / `verified_rubric_raw` / `rubric_evidence_key`（由大模型在四个维度上对 problem_statement 的规范性与测试有效性打分，0-3 分）
- **评分**：`graded_resolved` / `gold_sanity_valid` / `gold_applies` / `applies_cleanly` / `gold_f2p_count` / `gold_p2p_count` / `agent_f2p_passed` / `agent_p2p_regressed` / `resolution_status` / `evaluation_type` / `test_command_source` / `test_command_sha256` / `grading_environment` / `environment_image` / `environment_image_id` / `environment_plan_fingerprint` / `environment_backend_id` / `environment_platform`
- **验证来源**：`validation_version` / `validator_fingerprint`，打包时必须与当前校验器匹配
- **原始日志**：`grading_logs` 含 `gold_pre` / `gold_post` / `agent_post` 完整测试输出，可直接核验 F2P 由败转成与 P2P 无回归
- **测试可复现性**：`test_command` 为基于属性的测试（如 hypothesis）钉定随机种子，确保评分确定性

### 非阻断性评分细则披露

以下 severity=1 的观察不阻断发布，仅记录问题陈述或测试范围的轻微偏差：

- `jhy__jsoup-2476`：ps=0，tv=1；`preservesMatchingSourceNofollowWhenEnforcementSuppressed` 测试用例未在 issue 中描述，略微扩大了范围；narrow=0 wide=1 low_coverage=0 misleading=0；对抗性评估：该测试覆盖了问题陈述之外的内链场景，但属轻微回归测试。
- `jhy__jsoup-2483`：ps=0，tv=1；ConnectTest 与 DataUtilTest 用例覆盖了超出核心 issue 范围的字符集检测边界情况；narrow=0 wide=1 low_coverage=0 misleading=0。
- `typescript-eslint__typescript-eslint-12003`：ps=0，tv=1；测试范围包含额外的 no-unused-vars 边界用例。

## 轨迹规格

- `trajectory.canonical.jsonl`：唯一一份用于训练或人工阅读的规范对话。累计 API 历史已去重；采集时生成的中文任务包裹行已转换为英文，生成式的中文项目描述已移除；issue 正文与其后的交互保持原样。
- `trajectory.full.jsonl`：完整的调用级 API 记录。每个请求包含截至该时点的累计历史；适合审计与协议研究，不适合直接逐行训练。
- 两种轨迹格式均经过完整脱敏，清理用户路径、邮箱与凭据；`redact_mode` 固定为 `full`。

### 轨迹训练价值规格

`environment.json` 与 `INDEX.jsonl` 中的 `trajectory_quality` 使用 `2026-08` 版本：

- `trajectory_thinking_quality` / `substantive_thinking_ratio` / `mechanical_transition_ratio` 描述思考深度；
- `failure_recovery_present` 仅记录是否出现真实的「失败后恢复」；绝不人为注入失败；无失败的干净执行视为中性证据；
- `behavior_categories` 统计源码检查、编辑、测试、diff 检查与提交等真实行为；
- `trajectory_quality_score` 是透明的辅助分：思考 0/1/3/5 分，行为类别每类 0.6 分（上限 3 分），同时具备测试与 diff 检查 +1 分，失败恢复 +1 分；无失败加中性 0.5 分。该分数不替代评分，也不决定发布。

## 字段与泄漏边界

`model_input.json` 是唯一建议输入模型的文件。`task.jsonl` 中以下字段仅作标签或评测使用：

- `swe_bench_instance.patch`
- 顶层 `test_patch`、`swe_bench_instance.test_patch`
- `swe_bench_instance.model_patch`
- `FAIL_TO_PASS`、`PASS_TO_PASS`
- `gold_*`、`agent_*`、`graded_resolved` 及环境证据

## 复现环境

镜像归档由 `docker save` 生成并以 zstd 压缩。`images/images.jsonl` 记录 tag、镜像 ID、平台与解压后大小；`CHECKSUMS.sha256` 覆盖包内全部文件。每个实例附带独立的 `Dockerfile`、`setup_repo.sh` 与 `setup_env.sh`；它们派生自生产任务的 `prep_script`，哈希绑定于 `environment.json.environment_recipe`。加载镜像后可直接使用钉定环境，或在具备上游仓库与依赖源访问权限时重新构建。

## 污染披露

全部 9 个实例在 INDEX.jsonl、task.jsonl 与 environment.json 中披露 `contamination_level` 与 `contamination_factors`：

- **low**（8/9）：c-ares、lvgl、yaml-cpp、urfave/cli、gin、jsoup#2476、jsoup#2483、typescript-eslint
- **medium**（1/9）：jarro2783__cxxopts-314

### MAJOR #3：jarro2783__cxxopts-314 污染等级为 medium

- **实例**：jarro2783__cxxopts-314
- **因素**：issue 年龄（issue 创建于 2021-10-29，修复提交于 2026-06-03；长间隔提升了模型训练语料覆盖该 issue 的概率）。
- **可训练性结论**：该轨迹已通过 ship_gates 的上游答案记忆筛查，未检测到未加防护的上游修复引用。medium 评级仅反映 issue 年龄带来的统计风险，并非轨迹中存在记忆的证据。在披露污染等级的前提下，该实例适用于训练。
- **处置**：无需修复。未来面向严格低污染发布的数据包可将该实例排除。

## 观察项（非阻断）

以下三项经评估确认为观察项。它们不影响数据质量或发布门禁，出于透明度予以披露。

### MINOR #4：lvgl gold 补丁指纹巧合

- **实例**：lvgl__lvgl-10308
- **观察**：智能体独立生成的补丁与 gold 补丁具有相同的 git blob index 行（`817e0c1..86e6932`），即智能体对 `lv_slider.c` 的修复与官方修复逐字节一致。
- **评估**：轨迹中不存在读取 gold 文件的命令；判定为等价实现收敛（简单修复的自然趋同），而非真实泄漏。
- **处置**：无需修复。如需严格零巧合，可在构建时引入注释变体，但这会损害训练数据纯度，不推荐。

### MINOR #5：C/C++ 实例的 F2P 标识符不在官方 log_parsers 格式中

- **实例**：jarro2783__cxxopts-314（F2P：CTest 测试名 `options` / `options_no_regex`）、lvgl__lvgl-10308（F2P：Unity 测试目标名 `test_slider` / `test_bar`）
- **观察**：标识符不在官方八语言 log_parsers 映射中。C/C++ 在官方设计中没有解析器。
- **评估**：已按标准适配方法评估并通过——健全性检查精确失败、gold/model 精确通过。
- **处置**：无需修复。C/C++ 实例的下游解析器应将 F2P/P2P 条目解释为 CTest 测试名或 Unity 测试目标名，而非 JUnit/pytest 风格的全限定类名。

### MINOR #6：失败恢复样本稀缺

- **观察**：9 条轨迹中，仅 urfave__cli-2275（failed_tool_result_count=1）与 typescript-eslint__typescript-eslint-12003（failed_tool_result_count=4）包含真实的失败后恢复路径，其余 7 条为干净执行。
- **评估**：干净执行反映模型能力；不得人为注入失败。
- **处置**：无需修复。若以失败恢复为特定训练目标，建议按 `failure_recovery_present` 分层采样，或后续补充失败恢复轨迹。

## 已知局限

- 本包仅提供 `linux/amd64` 镜像；其他架构依赖模拟执行，可能出现明显性能下降。
- 本数据是高质量 demo / 验证集，不足以代表真实软件工程任务的完整分布。
- 离线镜像中预装的依赖复用了构建缓存；简单修复可能在 1-3 分钟内完成；`duration_seconds` 是录制环境的墙上时间，不代表任务难度或轨迹完整性。
- 成功轨迹不一定包含失败恢复路径；专门训练纠错能力时，应按 `failure_recovery_present` 分层采样，而非向轨迹人为注入失败。
- 数据与镜像包含多个上游开源项目；使用与再分发必须遵守各实例目录中的上游许可。
- 轨迹虽已完整脱敏，按地区与组织政策，公开发布前仍建议进行独立的隐私与许可审查。
