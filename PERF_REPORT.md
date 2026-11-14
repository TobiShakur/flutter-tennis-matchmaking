# Performance Engineering Report — `tenis_app` (SetPoint)

**Debug HUD URL Query:** `?perf=1`  
**Keyboard Shortcut:** `Ctrl + Shift + P` or `Alt + P` (toggles `PerfDebugOverlay` anytime; zero runtime overhead when hidden)

---

## 1. Telemetry & Debug Tooling Implemented

### 1.1 Browser-Level Boot & Resource Instrumentation (`window.__portfolioPerf`)
- **Files:** `web/index.html`, `web/flutter_bootstrap.js`
- **Native Pre-Flutter Curtain (`#initial-loader`):**
  - Renders immediately on HTML first paint over `#0E1311` (matching `AppTheme.backgroundColor`) with a wireframe-only Flutter SVG logo (`#9AA4B2` stroke) and a `120×2px` minimalist gliding bar below (replacing Flutter's default loader).
  - Preconnects and loads `Poppins` (weights `400..900`) early from `fonts.googleapis.com` / `fonts.gstatic.com`.
  - Dismisses cleanly on the `app-ready` DOM event (dispatched by Dart's `notifyAppReady()` after first frame, `GoogleFonts.pendingFonts()`, and `precacheImage()` settle, guarded by a `1500ms` Dart warmup timeout and a `2000ms` JS fallback timeout) with an upward translate (`-56px`), scale (`0.96`), opacity, and `backdrop-filter` blur transition.
- **Captured Timeline Marks & Stage Durations (`performance.now()` + `PerformanceObserver`):**
  - `htmlFirstPaintMs` (`first-contentful-paint` / `first-paint`)
  - `engineLoadMs` (`loaderStartMs` -> `engineInitEndMs`)
  - `dartBootMs` (`runAppStartMs` -> `runAppEndMs`)
  - `assetsAndFontsMs` (`runAppEndMs` -> `readyEventMs`)
  - `totalReadyMs` (`readyEventMs`, with `readySource`: `'flutter'` vs `'fallback-timeout'`)
- **Network & Memory Breakdown:**
  - Resource entries bucketed by `wasm`, `js`, `images`, `fonts`, and `other` (`transferSizeKb` and `decodedBodySizeKb`), plus cache-hit / opaque CDN detection and `performance.memory` (`jsHeapUsedMb` / `jsHeapTotalMb`).

### 1.2 In-App DevTools HUD (`PerfDebugOverlay`)
- **Files:**
  - `lib/core/services/perf_telemetry_models.dart`
  - `lib/core/services/perf_telemetry_service.dart` / `_platform.dart` / `_web.dart` / `_stub.dart`
  - `lib/core/services/app_ready_notifier.dart` / `_web.dart` / `_stub.dart`
  - `lib/core/widgets/perf_debug_overlay.dart`
  - `lib/main.dart` (`TenisApp` `MaterialApp.builder` `Stack` above `DesktopShowcaseWrapper`)
- **Features:**
  - Zero runtime overhead when hidden (`SizedBox.shrink()`, `addTimingsCallback` only registered while visible).
  - Live boot timeline proportion bar, JS Heap & Flutter `PaintingBinding.instance.imageCache` (`Raster Cache`) readouts, network payload breakdown, rolling 60-frame FPS / UI Build / GPU Raster / Jank (`>16.6ms`) metrics, and `localStorage` baseline comparator (`setpoint_perf_baseline_v1` via `Save as Baseline`, `Clear`, `Refresh`).

---

## 2. Optimizations Applied

### 2.1 Asset Compression & `ImageCache` Unification
Converted all 6 stock court assets to WebP and updated `MatchDetailScreen._getCourtAsset()` (`lib/features/matches/presentation/screens/match_detail_screen.dart`):

| Asset | Format & Dimensions | Optimized Size |
|---|---|---:|
| `tennis_0.webp` | WebP `640×640` | `96.6 KB` (`98,900 B`) |
| `tennis_1.webp` | WebP `640×640` | `104.3 KB` (`106,842 B`) |
| `tennis_2.webp` | WebP `640×640` | `59.1 KB` (`60,538 B`) |
| `tennis_3.webp` | WebP `640×640` | `68.0 KB` (`69,584 B`) |
| `tennis_4.webp` | WebP `600×400` | `31.8 KB` (`32,514 B`) |
| `tennis_5.webp` | WebP `640×427` | `53.3 KB` (`54,594 B`) |
| **Total `assets/images/stock/` (6 files)** | **WebP** | **`413.1 KB`** *(was `4,471.1 KB`, **-90.8%**)* |

- **Startup `precacheImage` & `ImageCache` key alignment:** `_TenisAppState` precaches the 3 court surfaces (`tennis_1.webp`, `tennis_2.webp`, `tennis_4.webp` — `195.2 KB` combined) during boot warmup without `cacheWidth`/`cacheHeight`, matching `Image.asset` in `MatchDetailScreen` so `ImageCache` keys match identically.
- **Unified `cacheWidth: 160` on small `Image.network` thumbnails/avatars:** Applied `cacheWidth: 160` across `partido_card.dart`, `match_detail_sheet.dart`, `player_slot_widget.dart`, `player_profile_card.dart`, `chat_partido_screen.dart`, and `edit_profile_screen.dart` to avoid decoding full-resolution bitmaps into Flutter's Raster Cache and share decode keys across screens.

### 2.2 `RepaintBoundary` & Rebuild Isolation
- **`DesktopShowcaseWrapper` (`lib/core/widgets/desktop_showcase_wrapper.dart`):** Wrapped the phone frame container in `RepaintBoundary` to isolate app repaints from the desktop showcase sidebar.
- **`MatchDetailScreen` (`lib/features/matches/presentation/screens/match_detail_screen.dart`):**
  - Wrapped the full-screen court `Image.asset` background in `RepaintBoundary`.
  - Hoisted the inner glass panel tree out of `AnimatedBuilder.builder` into `AnimatedBuilder.child` and wrapped the blur panel in `RepaintBoundary` so `_blurAnimation` ticks do not reconstruct the inner widget tree.
- **`HomeShellScreen` (`lib/features/matches/presentation/screens/home_shell_screen.dart`):** Wrapped the bottom `BackdropFilter` floating navbar (`SlideTransition`) in `RepaintBoundary`.
- **`MapFeedScreen` & `LocationPickerMapScreen`:** Wrapped `FlutterMap` in `RepaintBoundary`.
- **`WelcomeScreen` (`lib/features/onboarding/presentation/screens/welcome_screen.dart`):** Wrapped decorative `CustomPaint` (`_TennisOrganicShapePainter`) in `RepaintBoundary`.

---

## 3. Web Build & Automated Verification

- **`flutter analyze`:** **0 issues** (`No issues found!`).
- **`flutter test`:** **30/30 passed** (including `perf_telemetry_models_test.dart` and `perf_debug_overlay_test.dart`).
- **`flutter build web --release --wasm`:** **exit code 0** (`√ Built build\web`).
  - `main.dart.wasm`: `3,023.8 KB` (`3,096,398 B`)
  - `main.dart.js` (JS fallback): `3,448.3 KB` (`3,531,037 B`)
  - `Font-Awesome-7-Brands-Regular-400.otf` tree-shaken `-99.3%` (`1,596 B`), `CupertinoIcons.ttf` tree-shaken `-99.4%` (`1,472 B`), `MaterialIcons-Regular.otf` tree-shaken `-99.0%` (`17,208 B`).
