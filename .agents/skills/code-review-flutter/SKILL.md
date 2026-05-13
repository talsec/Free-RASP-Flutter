---
name: code-review-flutter
description: Performs strict code reviews on Flutter projects covering Dart, Pigeon, and the Kotlin (Android) and Swift (iOS) native bridges. Focuses on optimal code, readability, maintainability, deduplication, single-responsibility, straightforward control flow, Flutter best practices, the rule that native layers must not invent hardcoded fallbacks for values the Dart layer or platform SDK already owns, alignment of identifiers and API surface across Dart/Kotlin/Swift, and explicit documentation of platform-specific features. Use when the user asks to "review PR", "do a code review", "review this code", "code review for PR#N", or otherwise requests review of changes in a Flutter plugin, package, or app — including its generated files (`*.g.dart`, `*.freezed.dart`, Pigeon output) and native source under `android/` and `ios/`.
---

# Code Review (Flutter)

Strict, opinionated code review for Flutter codebases (apps, packages, and especially plugins with Kotlin + Swift bridges). Optimised for catching the kinds of issues that survive linters and tests but degrade a codebase over time.

## Review priorities, in order

1. **Correctness & contract** — bugs, breaking changes, public-API violations, SemVer; identifiers and API surface aligned across Dart, Kotlin, and Swift.
2. **Native-layer cleanliness** — no hardcoded fallbacks for values owned by Dart or the platform SDK; no behaviour duplicated across language boundaries; platform-specific features explicitly documented.
3. **Single responsibility** — each function, class, and file does one thing.
4. **Deduplication (DRY)** — repeated parsing, serialisation, and validation patterns get extracted.
5. **Readability** — naming, argument styles, generated-vs-handwritten boundaries, no surprises.
6. **Maintainability** — generated files untouched, defaults documented in one place, tests for new public surface.
7. **Flutter / Dart best practices** — `const`, `@Deprecated` discipline, `null` vs empty, `analysis_options.yaml` honoured.
8. **Polish** — dartdoc style, example brevity, changelog accuracy, PR description present.

## Workflow

### 1. Gather context

If the user references a GitHub PR by number:

```bash
gh pr view <N> --json title,body,author,state,baseRefName,headRefName,additions,deletions,changedFiles,files,url
gh pr diff <N>
git log <base>..<head> --oneline
```

If the changes are local:

```bash
git diff <base>..HEAD --stat
git diff <base>..HEAD
```

Always read the full file (not only the diff) for any non-trivial change so you see the surrounding context the diff hides — especially around generated code, native bridges, and JSON parsing.

### 2. Classify every changed file

Each file falls into exactly one of these buckets, and the bucket determines what's acceptable:

| Bucket | Examples | Rule |
|---|---|---|
| Hand-written Dart | `lib/`, `test/` | Full review applies. |
| Generated Dart | `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `lib/src/generated/*` | **Must not be hand-edited.** Regenerate via build_runner / Pigeon. |
| Pigeon source | `pigeons/*.dart` | Changes here imply downstream regeneration of both Dart and Kotlin output. |
| Pigeon-generated native | `android/.../generated/*.kt`, `ios/.../generated/*.swift` | Same as generated Dart — never hand-edited. |
| Hand-written native | `android/src/main/kotlin/**`, `ios/Classes/**` | Full review applies, with extra scrutiny on the bridge layer. |
| Build / config | `pubspec.yaml`, `*.gradle`, `*.podspec`, `analysis_options.yaml` | Verify version bumps follow SemVer; confirm SDK/binary updates match changelog. |
| Docs / release | `CHANGELOG.md`, `README.md` | Verify claims match the diff (e.g. SDK versions, breaking-change list, public-API additions). |

### 3. Run the checklist below and produce the report

---

## Hard rules — block the merge

### 1. No hand-edits to generated files

Generated files (`*.g.dart`, `*.freezed.dart`, Pigeon output, etc.) must be touched only by their generator.

Red flags:
- A `// ignore:` directive added to a `*.g.dart` file (also typically pointless because `analysis_options.yaml` already excludes `**/*.g.dart`).
- Behaviour-changing edits inside a generated file's diff that don't match what the generator would produce.
- Pigeon-generated Kotlin/Swift edited directly instead of by re-running `dart run pigeon`.

Action: ask the author to regenerate via `dart run build_runner build --delete-conflicting-outputs` (or the project's equivalent) and commit the unmodified output.

### 2. SemVer must match the change

A breaking public-API change requires a major version bump. "Public" includes anything exported from the package's main library file (e.g. `lib/<package>.dart`) and anything that changes the wire format with the native side.

Common breaks to flag:
- Renamed or retyped fields on classes exported from the package.
- Renamed string values consumers may pattern-match against.
- Removed or repurposed enum variants.
- Changed required/optional status on constructor parameters.

If the project's `CHANGELOG.md` claims SemVer adherence and the bump doesn't match the change, call it out explicitly with the affected symbols and the recommended version.

### 3. No hardcoded fallbacks in the native layer

This is the **single most important rule** for plugin code.

The native layer (Kotlin / Swift) is a transport adapter between Dart and the platform SDK. It must not:

- **Invent default values** for fields the Dart layer marks `required`. Such defaults are unreachable but advertise an optional contract that doesn't exist; future readers of only the native side draw the wrong conclusion.
- **Substitute defaults** for fields the Dart layer leaves nullable/optional. Either the SDK has its own default (skip the call and let the SDK apply it) or the default belongs in the Dart layer where the public API lives.
- **Encode the same default in multiple places.** A default expressed as a string literal in `optString("foo", "BAR")`, then again as an enum in `getOrDefault(Foo.BAR)`, then again as a fallback object construction is three sources of truth that will drift.
- **Hardcode enum names as raw strings** (e.g. `"SIDELOADED_ONLY"`). Use the SDK's enum's `.name` property or, better, don't parse it manually at all.

Concrete pattern to flag (Kotlin):

```kotlin
val scopeStr = optString("scanScope", "SIDELOADED_ONLY")
val scope = runCatching { ScopeType.valueOf(scopeStr) }.getOrDefault(ScopeType.SIDELOADED_ONLY)
val fallback = MalwareScanScope(ScopeType.SIDELOADED_ONLY, emptyList())
```

What's wrong: three encodings of the same default in one function; the string literal isn't checked at compile time; the fallback object overrides whatever default the SDK itself would apply.

Recommended remediation in the review comment:

- For **required** Dart fields: drop the native default; let parsing throw and surface the failure through the existing error path. Malformed JSON should be loud, not silently corrected.
- For **optional** Dart fields: skip the builder/setter call entirely when the field is absent; let the platform SDK apply its own default. If a default truly must live at the bridge, define it as a single named constant and reference it everywhere.
- Document the default once — in the Dart dartdoc — so the public contract is unambiguous.

### 4. Single source of truth across language boundaries

A Dart contract and its native counterpart must agree on:

- **Required vs optional**: if Dart says `required`, the native side must not paper over a missing key.
- **Null vs empty**: pick one to mean "unset" and apply it consistently; flag any function where some branches return `null` and others return an empty collection for the same logical concept.
- **Collection semantics**: if the native side converts `List` → `Set` (silently dropping duplicates and ordering), this must be reflected in the Dart type or documented in the dartdoc.

### 5. Identifiers and API surface aligned across Dart, Kotlin, and Swift

For every cross-platform construct, verify that all three sides — Dart contract, Kotlin implementation, Swift implementation — agree on:

- **Numeric / string identifiers**: callback codes, threat IDs, channel names, error codes, JSON keys, Pigeon message IDs. A constant like `signatureValue = 1115787534` in `ios/Classes/TalsecHandlers.swift` must have an exact counterpart on the Dart and Kotlin sides. Drift is silent and only surfaces at runtime when the wrong callback fires.
- **Method / API surface**: if Dart exposes `Talsec.instance.foo(...)`, both Kotlin and Swift handlers must implement the matching native method with the same signature (parameter names, types, return type) — or the platform must be explicitly excluded (see rule 6).
- **Enum membership**: if Dart enumerates threats, scopes, or modes, both native sides must handle every variant. Kotlin `when` with no `else` and Swift `switch` with `@unknown default` should map unknown variants to a clearly-named "unknown" sentinel, not silently to the first variant.
- **JSON field keys**: keys read by `optString("scanScope", ...)` in Kotlin and `decode(forKey: .scanScope)` in Swift must match what the Dart `JsonSerializable` model emits (case-sensitive). Renaming a Dart field without updating both natives is a wire-format break.
- **Pigeon shapes**: when `pigeons/*.dart` changes, both `.kt` and `.swift` generated outputs (if iOS uses Pigeon) must be regenerated and committed together. A Pigeon source change without both sides updated is a hard block.

Audit method:

1. List every identifier defined in one layer (constants, channel names, JSON keys, enum names, method signatures).
2. Grep for the same identifier in the other layers.
3. Flag any identifier that exists in one layer without matching counterparts in the others — even if everything compiles.

### 6. Platform-specific features must be documented and gated

Not every Flutter API has both a Kotlin and a Swift implementation. Some checks are Android-only (e.g. malware / suspicious-app detection, package introspection, OEM detection), some are iOS-only (e.g. jailbreak sub-checks, missing Secure Enclave), some have asymmetric semantics (e.g. screenshot blocking on iOS vs Android). This is fine — but it must be **explicit**.

Required:

- **Dartdoc states the platform**: any class, field, enum variant, callback, or method that only does work on one platform must say so in its dartdoc — e.g. `/// Android only. Ignored on iOS.`
- **Config class isolation**: platform-specific configuration belongs on the platform-specific config class (e.g. `AndroidConfig.suspiciousAppDetectionConfig`), not on the cross-platform parent. Do not expose Android-only fields on a class consumed on iOS, and vice versa.
- **Runtime behaviour is documented**: if calling a platform-specific method on the wrong platform throws, returns `null`, or silently no-ops, the dartdoc must say which.
- **Examples reflect the asymmetry**: an example app demonstrating an Android-only feature should not imply it works on iOS (e.g. don't show `MalwareBottomSheet` in the iOS path without a note).
- **CHANGELOG calls out the platform**: bullets describing added/changed/removed features must say "(Android)" or "(iOS)" when they only apply to one platform.

Red flags:

- A `TalsecConfig`-level field that's read only by one of the two native handlers, with no platform marker.
- A callback (`onMalwareDetected`, `onScreenshot`, etc.) that fires only on one platform without a dartdoc note saying so.
- A native enum value (Kotlin `KernelSU`, Swift `missingSecureEnclave`) with no Dart-side representation, or a Dart enum value with no native producer.
- A platform-specific feature documented in the README but not in the dartdoc, or vice versa.

### 7. Tests for new public API

Every newly exported model, enum, or function needs at least:

- Construction test (defaults, required fields).
- `toJson` / `fromJson` round-trip if `JsonSerializable`.
- Enum-name stability test if the enum maps to native string values (catches drift from native renames).
- For platform-specific APIs: a test that exercises the `defaultTargetPlatform` override path so the contract is locked on both platforms.

Look at sibling test files (`test/src/models/*_test.dart`) for the project's established pattern and match it.

---

## Significant issues — should fix

### Single responsibility

- A function that parses, validates, defaults, and constructs in one body is doing four things. Split.
- A class with `parse*`, `format*`, and `send*` methods is three classes.
- An extension that mixes domain mapping (`SuspiciousAppInfo.toPigeon`) and unrelated JSON helpers (`JSONObject.toMalwareScanScope`) is two files.

### Deduplication

Flag verbatim or near-verbatim repetition, especially:

- The same `(0 until arr.length()).map { arr.getString(it) }` pattern repeated for every JSON array field. Extract a helper.
- The same `if (json['x'] == null) defaultX else json['x']` pattern repeated. Use `??` or a helper.
- Multiple `runCatching { Enum.valueOf(s) }.getOrDefault(...)` calls. Extract a generic `parseEnumOr(default)` helper.

### Argument style for many-parameter constructors

Constructors with **3+ parameters of similar type** should be called with named arguments. Positional calls are swap-bug magnets. If named args don't compile (e.g. Java interop strips parameter names from a Kotlin callsite), demand a one-line comment explaining why and consider wrapping the construction in a small typed factory.

### Old API still wired up alongside the new one

When deprecating an API path, ensure the new path doesn't quietly run *both* code paths (e.g. always calling `.blacklistedPackageNames(emptyArray())` on the SDK builder even when the consumer uses the new config). Either short-circuit the deprecated path when the new one is provided, or document the precedence explicitly.

### Defaults silently chosen for the consumer

If an optional field is left unset by the consumer and the dartdoc doesn't say what value they get, the API is under-documented. Either document the default in the dartdoc or stop applying one.

---

## Style & polish — call out, don't block

- **Trailing newlines, formatting churn**: separate from the feature; mention but don't argue.
- **Verbose examples**: example code that explicitly sets parameters to their defaults teaches nothing. Either drop the assignment to demonstrate the default, or assign a non-default to demonstrate customisation.
- **Inconsistent terminology**: `MalwareConfig` vs `SuspiciousAppDetectionConfig` vs `MalwareScanScope` in one feature is one term too many. Pin it before release.
- **Dartdoc consistency**: full sentences, end with a period, match the project's existing style.
- **`@Deprecated` discipline**: deprecating a field is fine; deprecating only some fields of a class while the constructor still accepts them with no warning is inconsistent.
- **PR description**: an empty PR body for a release PR is a defect of its own. Aggregate the conventional commits in the branch into a short summary.
- **Changelog accuracy**: every bullet in `CHANGELOG.md` should be verifiable from `git diff <base>..HEAD`.

---

## Output format

Structure the review as:

```markdown
## Summary

<2–3 sentences: what the PR does, overall verdict>

## Blockers / Major issues

### 1. <short title — one line>

<context, citing file:line; show the offending snippet using a code reference>

<concrete remediation>

### 2. ...

## Significant issues

(same shape, less severe)

## Minor / polish

(numbered list, one to three lines each)

## Recommended action

<numbered, ordered list of what must change before merge>
```

Rules for the report:

- Cite specific files and line numbers for every issue. When showing existing code, use the `startLine:endLine:filepath` reference form so the user can click through.
- Prefer one detailed example over a vague generality; if a pattern repeats, mention it once and list the other locations.
- Distinguish between "this is wrong" and "I'd prefer this." Flag the first as Major, the second as Polish.
- Never assert facts about a closed-source SDK without verifying. If the SDK isn't readable from the repo, phrase findings as "verify whether the SDK provides X; if so, do not duplicate it" instead of asserting that it does.
- End with a short, ordered "Recommended action" list — not a wishlist, the actual gating items.
