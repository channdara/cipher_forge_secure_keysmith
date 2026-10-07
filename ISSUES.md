# Issues

Findings from a pass over the generator, the UI, and the GitHub Pages workflow. Severity is about user impact: a wrong
length or a misleading strength label matters more than dead code.

`Random.secure()` is a sound source of randomness. The problems below are in what the app does with that randomness, and
in how the page explains it.

---

## High

### 1. Resolved — the strength meter matches the generator

`EntropyHelper.calculateEntropy` reports the Shannon entropy of the coverage mixture `PasswordGenerator.generate`
actually samples. The label, the five-segment bar, and the crack time use that number. The header, `web/manifest.json`,
and `web/index.html` describe the matrix as the selection scheme. Algorithm Insights says a class-assigned key
contributes a character from that class only.

### 2. Resolved — crack time is labeled as one offline model

The duration is shown as **Offline attack**, with the assumptions on the card: 10 billion guesses per second, stopping
halfway, by an attacker who knows the length and character classes. The same sentence says a rate-limited login is much
slower and a fast hash on a large cluster can be faster. Huge estimates are worded (`2 × 10^30 years`) instead of
Dart's `2e+21 billion years`.

### 3. Resolved — the length field stays with the password

The stepper cancels a pending typed length. Editing the field out of 6–32, or clearing it, cancels that pause too.
Leaving the field clamps an out-of-range value and restores the current length when the field is empty. If the bloc
length changes, `didUpdateWidget` writes it back into the field.

---

## Medium

### 4. Resolved — the copy button explains a clipboard failure

`CopyPassword` catches a `Clipboard.setData` error. The button switches to **Copy failed** and a line under it
says why: the page is not a secure context, the browser has no clipboard API, or the browser denied permission.
A new password or a later successful copy clears that line. The success timer does not.

### 5. Any control change destroys the current password

Length edits, class toggles, and Refresh all call `PasswordGenerator.generate` and drop the previous `PasswordResult`.
There is no history, no undo, and no "copy this first" prompt. A mistaken toggle cannot be reversed. Reloading the page
does the same, because nothing is stored.

That is consistent with keeping secrets out of `localStorage`. It also means the only durable copy is the clipboard,
which issue 4 leaves in place indefinitely.

### 6. The whole matrix sits in the page

The master password and all `L` intermediate keys are plain text in the DOM. Chosen cells are highlighted. A screen
share, a screenshot, a browser extension, or someone looking over the shoulder sees the password and `L` other strings
built from the same pools. The app never sends this to a server. The exposure is local, and the visualizer multiplies
it.

### 7. The short-password branch cannot run, and nothing tests either branch

The UI and the bloc both clamp length to 6–32. At most four pools can be active. `length < activePools.length` is
therefore unreachable, but `PasswordGenerator.generate` still contains a second construction and a 100-try selection
loop for that case.

There is no `test/` directory. `.github/workflows/deploy.yml` runs `flutter pub get` and `flutter build web`. It does
not run `flutter analyze` or `flutter test`. A broken generator still deploys on a push to `deploy`.

If `matchingIndices` is ever empty, `matchingIndices[_random.nextInt(matchingIndices.length)]` throws. Today each row
still contains every active pool, so the list is non-empty. The two steps are only kept consistent by convention. An
exception here escapes the bloc handler and the screen keeps the previous password with no error shown.

### 8. Zoom is disabled, and the charset labels are hard to read

`web/index.html` sets `maximum-scale=1.0` and `user-scalable=no`. A phone user cannot pinch-zoom the password or the
matrix.

Class switches render the raw alphabet as a 10px subtitle in `#64748B` (`AppColors.legendText`) on the translucent card
(`#162032` at about 70% opacity over `#0B0F19`). That pair is about 3.6:1, under the 4.5:1 WCAG AA contrast ratio for
normal text. Those subtitles are the actual character sets the password is drawn from.

`web/manifest.json` sets `"orientation": "portrait-primary"`. An installed PWA is locked to portrait, including on a
tablet wide enough for the desktop layout (the breakpoint is 900px).

### 9. Turning off the last class fails silently

Each switch returns without calling `onChanged` when it would leave every class off. The control does not move and the
page does not say why. The rule lives only in `SettingsPanel`. `ToggleUppercase` and the other bloc events will happily
generate an empty password if something else dispatches them. The empty state (`No Password`, pool size 0, crack time
`N/A`) is implemented and untested.

### 10. Deploy does not match the docs, and the workflow is easy to break

| What the repo says                                                              | What actually happens                                                                               |
|---------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| `DEVELOPMENT.md` deploys pushes to `main` with base href `/password_generator/` | `.github/workflows/deploy.yml` listens to branch `deploy` and uses `/cipher_forge_secure_keysmith/` |
| Default branch is `master`                                                      | A merge to `master` does not update GitHub Pages                                                    |

The Pages site
is [channdara.github.io/cipher_forge_secure_keysmith](https://channdara.github.io/cipher_forge_secure_keysmith/). A fork
or a rename 404s every asset until the hardcoded base href is edited.

`actions/checkout@v4`, `subosito/flutter-action@v2`, and `JamesIves/github-pages-deploy-action@v4` are pinned to moving
tags, and the job has `contents: write`. A rewritten tag on one of those actions can publish into `gh-pages` or push
other commits.

`flutter build web --wasm` needs cross-origin isolation headers for the Wasm renderer. GitHub Pages cannot set
`Cross-Origin-Opener-Policy` or `Cross-Origin-Embedder-Policy`. The published app falls back to the JavaScript build.
The `--wasm` flag does not change what visitors actually run.

Flutter's web build also emits a service worker that caches the app shell. After a later deploy, a returning browser can
keep running the previous `gh-pages` build until that cache expires.

`Random.secure()` and the clipboard API both require a secure context. The Pages URL is HTTPS, so the hosted app is
fine. Opening a local build from `file://` or plain HTTP can throw on startup, during the initial
`PasswordGeneratorState.initial()` call, with no fallback UI.

---

## Low

### 11. Character class is detected in three places

The pools live on `PasswordGenerator`. `EntropyHelper.characterColor` and `PasswordPanelCounter` re-implement the same
idea with code-unit ranges (`50–57` for digits, `65–90` for uppercase) and a symbol set copied from the pool. Anything
left over is treated as lowercase.

That agrees with today's pools because `0`, `1`, `I`, `O`, and `l` are excluded. Adding `0` or `1` to `digitChars` would
draw them correctly and then paint and count them as lowercase (`0` is code unit 48, outside `50–57`).

### 12. Unused and stale project files

- `AppTextStyles.visualizerRowIndex` and `AppTextStyles.visualizerLegend` have no callers.
- `analysis_options.yaml` is the Flutter framework's own options file, including excludes for `engine/`, `android/`, and
  `ios/`, none of which exist here. `deprecated_member_use` is ignored globally.
- `CHANGELOG.md` is empty. The app version is `1.1.0+4` in `pubspec.yaml` and is not shown in the UI, so the running
  site cannot be matched to a commit from the page alone.
- `BACKUP.md` and `password_generator.iml` describe an Android module the repo does not contain. The checked-in target
  is web only.
- There is no `LICENSE`. The GitHub repo does not state what others may do with the code.

### 13. Accepted limits, not defects

These are visible from the code and worth keeping in mind when judging the meter:

- Ambiguous characters `I`, `O`, `l`, `0`, and `1` are omitted. That is a readability choice. It shrinks the pool (85
  instead of 90 if those five were added to an otherwise identical set).
- Repeated characters are allowed. Nothing in the generator tries to make a string unique.
- The on-screen composition counts are a property of the string the user received, not a promise that every class was
  requested. With the coverage rule and length at least 6, every enabled class does appear.
