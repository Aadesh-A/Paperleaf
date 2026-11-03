# Paperleaf

A handwriting-first notebook app for **iPad, iPhone, and Mac**. Paperleaf combines Apple Pencil ink, PDFs, typed content, images, recordings, study tools, and local-first sync in one native SwiftUI codebase.

Paperleaf is a redesign and feature fork of [Cecilia's Notes](https://github.com/TheProductArchitect/cecilias-notes), used under its MIT license. The upstream copyright and license are preserved in [`LICENSE`](LICENSE). Internal `CeciliasNotes` module and archive names intentionally remain in this first fork revision so existing documents and migrations continue to work.

<sub>iPad is the source of truth: full canvas + Apple Pencil. iPhone drops handwriting but keeps everything else. Mac gets a Google-Docs-style **Doc Mode** so you can type, dictate, and use AI seamlessly — and a **Canvas Mode** to open notebooks exactly as they look on iPad.</sub>

---

## Fork status

- **iPad:** primary Paperleaf experience; requires an iOS simulator runtime or a provisioned device to run locally.
- **iPhone:** companion library and editor; handwriting remains iPad-only.
- **Mac:** builds successfully with Xcode 26.6; Doc Mode and Canvas Mode are available.
- **Paperleaf additions:** original forest-and-paper visual system, new app icon and wordmark, Favorites rail, and persistent recent-search suggestions.

For the full per-device flow inventory (155 flows across 25 domains, per-device status), see [`Documentation/USER_FLOWS.md`](Documentation/USER_FLOWS.md).

## Design principles

1. **Handwriting-first on iPad.** Apple Pencil is the primary input; typed text, PDFs, images, and audio are equal citizens.
2. **Paperleaf voice.** Warm paper surfaces, forest-green accents, rounded typography, and quiet chrome keep attention on the page.
3. **Local-first.** No network calls, no backend, no analytics. Sync goes through the user's own iCloud account. Foundation Models inference runs on-device. Crash/hang diagnostics are OS-collected via MetricKit and written to the app's own Documents folder — the app transmits nothing.
4. **One codebase.** Two Xcode targets share the design system, models, and services via `PBXFileSystemSynchronizedRootGroup`. Cross-platform code guards with `#if canImport(UIKit)` / `#if canImport(AppKit)`.
5. **Zero third-party dependencies.** Everything is an Apple framework: SwiftUI, PencilKit, SwiftData, CloudKit, Vision, Speech, Foundation Models, WidgetKit, MultipeerConnectivity.

## Repo tour

Start here in this order — every file in the list is aimed at someone opening the repo cold:

| File | What it is |
|---|---|
| [`Documentation/PROJECT_STATE.md`](Documentation/PROJECT_STATE.md) | Current phase, wire diagram, "where things live" cheat sheet, debug playbook. **Read this first.** |
| [`Documentation/ARCHITECTURE.md`](Documentation/ARCHITECTURE.md) | Deep dive: data layer, service layer, sync, editor pipeline. |
| [`Documentation/ROBUSTNESS.md`](Documentation/ROBUSTNESS.md) | Threading map: which thread owns each process, main-thread rules, the ANR/crash postmortems, and the reliability instruments (hang watchdog, MetricKit). |
| [`Documentation/OPEN_ISSUES.md`](Documentation/OPEN_ISSUES.md) | Live tracker for known-but-unfixed bugs, each with what's been tried and the next concrete step. Resolved entries are deleted, not struck through. |
| [`Documentation/CODE_GRAPH.md`](Documentation/CODE_GRAPH.md) | Auto-generated map of every file, type, protocol, and `NotificationCenter` symbol with its posters + observers. Regenerate with `python3 Documentation/tools/build_code_graph.py`. |
| [`Documentation/USER_FLOWS.md`](Documentation/USER_FLOWS.md) | 155 user flows × 3 devices with per-device status, UX notes, and Granola benchmarks for the Mac. |
| [`Documentation/USER_FLOWS.yaml`](Documentation/USER_FLOWS.yaml) | Machine-queryable version of the flows — grep / `yq` / feed to an LLM. |
| [`Documentation/MAC_APP_PRD.md`](Documentation/MAC_APP_PRD.md) | Mac companion PRD (architecture, UX, rollout M0–M6). |
| [`Documentation/prompts/verify_user_flows.md`](Documentation/prompts/verify_user_flows.md) | Cold-start LLM prompt: verify every flow, fix gaps, report. |

### Source layout

```
CeciliasNotes/                     Xcode project root
├── CeciliasNotes/                 iOS + iPadOS target (also compiled for Mac via synced folders)
│   ├── App/                       @main, RootView, environment wiring
│   ├── Core/                      Capabilities, Models (V6 schema), Services, Utilities
│   ├── DesignSystem/              Theme, Colors, Typography, BrandWordmark
│   ├── Features/                  Library, Editor, Onboarding, Quiz, Settings, Sync
│   └── Resources/                 Assets, Info.plist, entitlements, Greetings.swift
└── CeciliasNotesMac/              Mac target
    ├── CeciliasNotesMacApp.swift  @main + MultipeerSyncService bootstrap
    ├── MacRootView.swift          full-plane masthead + sidebar + content
    ├── Editor/DocMode/            Google-Docs-style linear writing surface
    ├── Editor/                    MacEditorView (Canvas Mode), MacRichTextEditor, transforms
    ├── Capture/                   Menu-bar quick capture, command palette, hotkey
    ├── Onboarding/                Name entry + iCloud reminder
    └── …                          Settings, Export, Search, Library, Services
```

## Building

Requirements:

- **Xcode 16.4+** (uses Swift 6 strict concurrency and `PBXFileSystemSynchronizedRootGroup`).
- **macOS 15.0+** to build the Mac target; **iOS 18.4+** to build the iOS target.
- Apple Silicon strongly recommended (Foundation Models is Apple Silicon only).
- No package manager. No Cocoapods, no SPM externals, no npm.

Then:

```bash
git clone <your-paperleaf-fork-url>
cd <your-paperleaf-folder>
open CeciliasNotes/CeciliasNotes.xcodeproj
```

Pick a scheme:

| Scheme | Runs on |
|---|---|
| `CeciliasNotes` | iPad + iPhone (simulator or device) |
| `CeciliasNotesMac` | Mac (Apple Silicon) |

Or from the command line:

```bash
xcodebuild -scheme CeciliasNotes    -destination 'generic/platform=iOS'   build
xcodebuild -scheme CeciliasNotesMac -destination 'generic/platform=macOS' build
```

You can build for the simulator without an Apple Developer account. On-device runs need provisioning.

## Contributing

Read [`CONTRIBUTING.md`](CONTRIBUTING.md) end-to-end before you write code — it covers the workflow, the review bar, and the design constraints that come up in every review.

Two-line version:

- **Open an issue first** for anything larger than a typo, so scope gets aligned before either of us invests time.
- **PRs must be focused, tested, and match the codebase's voice.** One approver ([@TheProductArchitect](https://github.com/TheProductArchitect)) merges to `main`; branch protection enforces this.

For AI assistants working on the repo, the fastest orientation is `PROJECT_STATE.md` → `USER_FLOWS.yaml` → `CODE_GRAPH.md`, then the cold-start prompt at [`Documentation/prompts/verify_user_flows.md`](Documentation/prompts/verify_user_flows.md).

## Security

Never file a security report as a public issue. Follow the private disclosure process in [`SECURITY.md`](SECURITY.md).

## License

MIT — see [`LICENSE`](LICENSE). Copyright © 2026 Venu Gopinath.

The MIT license is intentionally permissive. If you build something on top of Paperleaf, we'd love to hear about it — but you don't owe us anything.
