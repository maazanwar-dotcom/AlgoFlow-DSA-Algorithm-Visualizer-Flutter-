Plan: Detailed 17-Day Flutter Algo Visualizer Learning Plan
This plan is tailored to your current project state (you already have splash, home, sorting list, and detail visualizer scaffolding). It focuses on learning deeply while building in controlled increments, with daily time boxes and concrete deliverables.

I also saved this plan to /memories/session/plan.md for ongoing refinement.

Execution Steps

Stabilize existing app foundations before adding more features.
Build a clean visualization engine (state + steps + playback) in small milestones.
Add algorithms and settings only after playback behavior is robust.
Polish UX and edge cases.
Optionally add a code-line highlight learning mode.
Day 0 (2-3h): Setup + Baseline Architecture
0:00-0:15 Audit current file structure and screen flow.
0:15-0:35 Map app journey: splash -> home -> sorting list -> visualizer.
0:35-1:05 Audit Material 3 dark theme and color tokens.
1:05-1:35 Define folder ownership (screens, widgets, models, states, algos).
1:35-2:05 Write one-page architecture notes.
2:05-2:30 Prepare cleanup backlog (naming/enum consistency).
Deliverable: architecture note + cleanup checklist.

Day 1 (4-5h): Splash + Startup Reliability
0:00-0:30 Learn startup lifecycle and async init.
0:30-1:15 Review current splash behavior and startup dependencies.
1:15-2:15 Define deterministic startup sequence (load prefs, then route).
2:15-3:00 Add safe fallback behavior if startup load fails.
3:00-3:45 Refine loading-dot timing/motion.
3:45-4:30 Run startup test matrix (cold start, warm start, missing prefs).
Deliverable: stable splash-to-home flow.

Day 2 (4-5h): Home / Entry UX
0:00-0:40 Learn card composition and reusable widget boundaries.
0:40-1:40 Refine card states (enabled, locked, coming soon).
1:40-2:20 Validate bottom-nav behavior and state.
2:20-3:30 Harden route handoff to sorting list.
3:30-4:30 Polish typography, spacing, tap feedback.
Deliverable: clean, intuitive entry screen behavior.

Day 3 (4-5h): Sorting List + Model Correctness
0:00-0:45 Review ListView.builder and model-driven rendering.
0:45-1:45 Audit and fix enum/model mismatches.
1:45-2:45 Improve list metadata display (complexity, stability, category).
2:45-3:30 Validate argument passing to detail screen.
3:30-4:30 Add edge handling for unsupported algorithms.
Deliverable: correct metadata + reliable navigation.

Day 4 (4-5h): State Architecture Day (No heavy UI)
0:00-0:45 Learn immutable state basics.
0:45-1:30 Choose state approach (recommended Riverpod; Provider acceptable).
1:30-2:30 Define VisualizerState fields.
2:30-3:30 Define VisualizerController actions.
3:30-4:30 Write transition table (event -> state changes).
Deliverable: architecture blueprint for visualizer logic.

Day 5 (4-5h): Bar Visualization UI
0:00-0:40 Learn chart sizing via LayoutBuilder.
0:40-1:40 Define bar geometry and scaling rules.
1:40-2:40 Add smooth height/color animation behavior.
2:40-3:20 Apply highlight states (normal, compare, swap).
3:20-4:30 Validate responsiveness on narrow and wide screens.
Deliverable: responsive chart area with clear state colors.

Day 6 (4-5h): Bubble Sort Step Engine
0:00-0:45 Dry run bubble sort manually.
0:45-1:30 Define step model types and payload rules.
1:30-2:45 Implement step generation as pure logic.
2:45-3:30 Standardize explanation text per step type.
3:30-4:30 Validate output with known sample arrays.
Deliverable: deterministic bubble step pipeline.

Day 7 (4-5h): Manual Playback (Next/Prev/Reset)
0:00-0:35 Define exact boundary behavior.
0:35-1:45 Implement Next (one step only).
1:45-2:30 Implement Prev strategy safely.
2:30-3:15 Add Reset from any state.
3:15-4:30 Disable/enable controls correctly by state.
Deliverable: predictable manual stepping UX.

Day 8 (4-5h): Play/Pause + Speed Slider
0:00-0:45 Learn timer lifecycle and disposal safety.
0:45-1:45 Implement autoplay loop with clean stop at end.
1:45-2:30 Define pause/resume semantics.
2:30-3:15 Wire speed slider to timer interval.
3:15-4:30 Stress-test rapid play/pause and route changes.
Deliverable: stable auto playback with speed control.

Day 9 (4-5h): Stats + Explanation Panel
0:00-0:45 Decide derived vs stored metrics.
0:45-1:45 Update comparisons/swaps/step count consistently.
1:45-2:45 Improve operation explanation wording.
2:45-3:30 Refine panel hierarchy and readability.
3:30-4:30 Add empty/loading message states.
Deliverable: educational feedback panel that updates correctly.

Day 10 (4-5h): Insertion Sort Integration
0:00-0:50 Dry run insertion sort thoroughly.
0:50-1:40 Define insertion-specific step semantics.
1:40-2:50 Implement insertion step generator.
2:50-3:30 Connect algorithm selector to same engine.
3:30-4:30 Verify parity with existing playback controls.
Deliverable: insertion sort running in same visualizer flow.

Day 11 (4-5h): Merge Sort (Optional but Strong)
0:00-1:00 Study merge recursion and overwrite behavior.
1:00-2:00 Add overwrite step concept.
2:00-3:15 Implement merge step generation baseline.
3:15-4:00 Validate highlight semantics for overwrite.
4:00-4:30 Simplify if cognitive load is too high.
Deliverable: merge baseline visualization.

Day 12 (4-5h): Settings Screen + Persistence
0:00-0:45 Learn settings screen composition.
0:45-1:45 Build toggles/sliders for defaults.
1:45-2:45 Persist settings locally.
2:45-3:30 Apply defaults during visualizer initialization.
3:30-4:30 Verify behavior after app restart.
Deliverable: user settings that persist and apply correctly.

Day 13 (4-5h): Polish + Edge Cases
0:00-0:45 Build edge-case checklist.
0:45-1:45 Ensure all control states are accurate.
1:45-2:30 Handle reset/switch during autoplay.
2:30-3:30 Refine animation timing and spacing.
3:30-4:30 Optimize rebuilds and constants.
Deliverable: robust, polished UX under rapid interaction.

Day 14-16 (Optional WOW): Code View Learning Screen
Day 14: Build static code panel with monospace styling.
Day 15: Map step types to pseudocode line highlights.
Day 16: Sync line highlight with playback and polish interactions.
Deliverable: educational code-follow mode.

Relevant Files to Use as Anchors
theme.dart
routes.dart
splash_screen.dart
home_screen.dart
sorting_list_data.dart
algorithm_detail_screen.dart
miniChart.dart
algorithms.dart
algo_step.dart
algorithms_data.dart
bubble_sort.dart
app_settings.dart
Verification Rhythm (Daily)
App boots and routes correctly.
No crashes under fast tapping.
Playback state, icon state, and timer state stay in sync.
Progress/stats/explanation reflect the same step index.
End each day with a short reflection note: what clicked, what was unclear, what to revisit.

This was my initial plan 