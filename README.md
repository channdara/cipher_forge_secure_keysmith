# CipherForge: Secure Keysmith

CipherForge is a client-side Flutter web app that builds passwords with `Random.secure()`. Every setting change
regenerates the password in the browser. The page shows the Shannon entropy of that password, a strength tier, an
estimated crack time, a character-class breakdown, and the matrix of intermediate keys used to assemble the result.

**Live
app:** [channdara.github.io/cipher_forge_secure_keysmith](https://channdara.github.io/cipher_forge_secure_keysmith/)

Package name `password_generator`, version `1.1.0+4`.

---

## Key features

- **Length and character classes.** Length runs from 6 to 32 (default 12). Uppercase, lowercase, numbers, and symbols
  can be toggled independently. The settings panel keeps at least one class enabled and shows the combined pool size.
- **Cryptographically secure randomness.** Character picks and shuffles use `Random.secure()`. Ambiguous characters
  (`I`, `O`, `l`, `0`, `1`) are left out of the pools.
- **Pool coverage.** When the length is at least the number of active pools, the master password includes at least one
  character from each active pool. Shorter passwords retry selection to cover as many pools as the length allows.
- **Algorithm visualizer.** An `L × L` grid shows every intermediate key. Violet cells are the characters chosen for the
  master password. A row assigned to a class contributes a character from that class only. Cells are colored by
  character class.
- **Security readout.** Entropy in bits of the password this generator builds, a five-segment strength bar, a strength
  label, and one offline attack duration. With two or more classes enabled, that entropy is below a uniform draw of the
  same length, because every active class is forced into the password. A composition row counts uppercase, lowercase,
  number, and symbol characters.
- **Responsive dark UI.** Material 3, dark theme. Widths above 900px use a two-column layout (settings beside the
  password and visualizer). Narrower widths stack the password, settings, and visualizer.

Generation, metrics, and the clipboard copy all run locally. The app does not send the password to a server.

---

## Using the app

| Control           | Behavior                                                                                                                                          |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| Length stepper    | Changes length immediately and regenerates. Cancels a typed length that has not been applied yet.                                                |
| Length field      | Accepts digits only. A value inside 6–32 regenerates after a 500ms pause. Clearing the field or leaving that range cancels the pause. Leaving the field or pressing Enter clamps the value to 6–32, or restores the current length when the field is empty. |
| Class switches    | Regenerates immediately. Turning off the last remaining class is ignored.                                                                         |
| Refresh           | Builds a new password with the current settings. The icon rotates for 500ms and the password fades in.                                            |
| Copy to Clipboard | Writes the master password to the clipboard and shows **Copied!** for 2 seconds. If the write fails, the button shows **Copy failed** and why: the page is not a secure context, the browser denied permission, or the clipboard is unsupported. Disabled when there is no password. |

Defaults on first load: length **12**, all four classes on (pool size **85**). That configuration is **76.0 bits**
and is labeled **Strong**. A uniform 12-character string from the same pool would be **76.9 bits**.

Character colors are shared by the password, the composition counts, and the matrix:

| Class              | Color                                          |
|--------------------|------------------------------------------------|
| Uppercase          | Blue `#3B82F6`                                 |
| Lowercase          | Green `#10B981`                                |
| Numbers            | Amber `#FBBF24`                                |
| Symbols            | Pink `#EC4899`                                 |
| Chosen matrix cell | Violet fill `#8B5CF6`, violet border `#A78BFA` |

---

## Password generation

`PasswordGenerator.generate` builds `L` intermediate keys of length `L`, then takes one character from each key. `L` is
the requested length. Active pools are the character sets whose switches are on. If no pool is active, the generator
returns an empty password; the settings UI does not allow that state.

```
Configuration
  length L, active pools
        |
        v
1. Build L intermediate keys
        |
        v
2. Pick one character from each key
   (pool coverage when L allows it)
        |
        v
3. Join the picks into the master password
```

### 1. Intermediate keys

Each key is filled, then shuffled with `Random.secure()`.

**When `L` is at least the number of active pools**

1. Place one random character from each active pool.
2. Fill the remaining `L - pools` positions from the combined pool.
3. Shuffle the key.

**When `L` is smaller than the number of active pools**

A key cannot hold every pool. For each key the generator shuffles the pools, takes the first `L` of them, draws one
character from each, and shuffles the result.

### 2. Choosing the master password

**When `L` is at least the number of active pools**

The master password is guaranteed to contain every active pool:

1. Shuffle the active pools and shuffle the row indexes.
2. Assign each pool to a distinct row.
3. On that row, collect indexes whose character belongs to the assigned pool and pick one with `Random.secure()`.
4. On every row that was not assigned a pool, pick an index uniformly at random.

**When `L` is smaller than the number of active pools**

Full coverage is impossible. The generator tries up to 100 random selections (one index per row) and keeps the candidate
that represents the most distinct pools. It stops early when the selected characters already cover `L` different pools,
which is the maximum a password of that length can cover.

### Character pools

| Pool      | Allowed characters                 | Excluded | Size |
|-----------|------------------------------------|----------|------|
| Uppercase | `ABCDEFGHJKLMNPQRSTUVWXYZ`         | `I`, `O` | 24   |
| Lowercase | `abcdefghijkmnopqrstuvwxyz`        | `l`      | 25   |
| Numbers   | `23456789`                         | `0`, `1` | 8    |
| Symbols   | `` !@#$%^&*()-_=+[]{};:',.<>?/~ `` | —        | 28   |

All four pools together contain **85** characters. The pools are disjoint, so each character belongs to one class.

---

## Entropy and strength

Metrics come from `EntropyHelper.calculateEntropy`. The number is the Shannon entropy, in bits, of the master password
under this generator's distribution. The strength label, the five-segment bar, and the crack-time estimate all use it.
The UI shows it to one decimal place (`Entropy: ~N.N bits`).

The matrix does not add entropy. It records which `Random.secure()` draws were assembled into the password.

An empty length or an empty pool yields `0`. The UI keeps length in 6–32 and at most four classes on, so the length is
always at least the number of active pools. `calculateEntropy` throws if it is asked for a shorter length, which is the
generator's other construction.

### One active pool

Every character is an independent uniform draw from that pool of size `n`:

$$E = L \times \log_2(n)$$

### Two or more active pools

The password follows the mixture described under "Choosing the master password":

- Each active pool is assigned to its own uniformly chosen position.
- An assigned position is a uniform character from its pool.
- Every other position is an independent draw from a random character of an intermediate key.

Given the pool a position landed in, the character is uniform inside that pool. If `S` is the sequence of pools along
the password, then

$$E = H(S) + \sum_{j=1}^{L} \mathrm{E}[\log_2(n_{S_j})]$$

`H(S)` is the Shannon entropy of that pool sequence. Sequences that miss a pool have probability zero, and the remaining
sequences are not equally likely, so `E` is below `L × log₂(P)`.

Let the pool sizes be `n₁ … nₖ`, `P = n₁ + … + nₖ`, and

$$u_i = \frac{1}{L} + \frac{L - k}{L} \cdot \frac{n_i}{P}$$

`uᵢ` is the probability that a random character of an intermediate key belongs to pool `i`. A count vector
`c = (c₁, …, cₖ)` with each `cᵢ ≥ 1` and `c₁ + … + cₖ = L` covers

$$M(c) = \frac{L!}{c_1! \cdots c_k!}$$

sequences, and each of those sequences has probability

$$p(c) = \frac{(L - k)!}{L!} \cdot \left(\prod_i \frac{c_i}{u_i}\right) \cdot \left(\prod_i u_i^{c_i}\right)$$

$$H(S) = - \sum_c M(c) \, p(c) \, \log_2 p(c)$$

The chance that any fixed position belongs to pool `i` is `1/L + ((L − k)/L) · uᵢ`, which is what the sum over
positions uses. The code groups sequences by these count vectors. At length 32 with four pools there are a few thousand
vectors.

At the default (length 12, all four pools) `E` is **75.97 bits**, shown as **76.0** and labeled **Strong**. The uniform
figure `12 × log₂(85)` is **76.91 bits**. At length 6 with all four pools, `E` is **36.31 bits**, against **38.46** for
a uniform draw. Length 8 with all four pools is **49.80 bits**, shown as **49.8** and labeled **Weak**. The uniform
figure **51.28** would have been labeled **Medium**.

### Strength tiers

| Entropy (bits) | Label            | Bar segments | Color  |
|----------------|------------------|--------------|--------|
| `E = 0`        | No Password      | 0            | Grey   |
| `E < 28`       | Very Weak        | 1            | Red    |
| `28 ≤ E < 50`  | Weak             | 2            | Orange |
| `50 ≤ E < 75`  | Medium           | 3            | Amber  |
| `75 ≤ E < 100` | Strong           | 4            | Green  |
| `E ≥ 100`      | Extremely Secure | 5            | Cyan   |

### Estimated crack time

The duration is one offline model, shown as **Offline attack**. It is not a property of the password. The card states
the assumptions underneath the number:

- the attacker already knows the length and the active character classes
- the attacker tests **10 billion** (`10^10`) guesses per second
- the search stops halfway through a keyspace of entropy `E`

$$T = \frac{2^{E - 1}}{10^{10}}$$

`E` is the entropy from the section above. A rate-limited login is much slower. A fast hash on a large cluster can be
faster. A slow hash such as bcrypt or Argon2 is much slower still. Those models are not given their own numbers.

In code, `log2(T) = E - 1 - log2(10^10)`. Less than one second is **Instantly**. Larger values are seconds (one
decimal), minutes, hours, days, months (`days / 30.437`), years (`days / 365.25`), then `k years`, million years,
billion years, trillion years, quadrillion years, and quintillion years. Past that, the line is a power of ten such as
`2 × 10^30 years`, so a huge estimate does not fall through to Dart's `2e+21` notation. Entropy at or below zero is
**N/A**. The duration is prefixed with `~`.

---

## Architecture

State is a single `PasswordGeneratorBloc`. Widgets send events; the bloc regenerates a `PasswordResult` and
`PasswordGeneratorState.create` derives pool size, entropy, strength, and crack time. `BlocBuilder` widgets rebuild only
when the fields they display change.

| Path                                      | Role                                                                  |
|-------------------------------------------|-----------------------------------------------------------------------|
| `lib/main.dart`                           | Dark Material 3 app, responsive screen, generate/fade animations      |
| `lib/bloc/password_generator.dart`        | Matrix generator and character pools                                  |
| `lib/bloc/password_generator_bloc.dart`   | Events: generate, length, toggles, copy, copy failure, copy-reset     |
| `lib/bloc/copy_failure.dart`              | Clipboard failure text and the secure-context check                   |
| `lib/bloc/password_generator_event.dart`  | Event types (`part` of the bloc file)                                 |
| `lib/bloc/password_generator_state.dart`  | Immutable state and `initial()` (length 12, all pools on)             |
| `lib/bloc/entropy_helper.dart`            | Pool size, entropy, strength, crack time, character colors            |
| `lib/constants/app_colors.dart`           | Theme and character-class colors                                      |
| `lib/constants/app_text_styles.dart`      | Text styles                                                           |
| `lib/widgets/header_panel.dart`           | Title and description                                                 |
| `lib/widgets/settings_panel.dart`         | Length control, switches, pool size, last-class guard, 500ms debounce |
| `lib/widgets/password_panel.dart`         | Password, copy, refresh, entropy, crack time                          |
| `lib/widgets/password_panel_bar.dart`     | Five-segment strength bar                                             |
| `lib/widgets/password_panel_counter.dart` | Per-class character counts                                            |
| `lib/widgets/visualizer_panel.dart`       | Algorithm Insights card; hidden when there are no keys                |
| `lib/widgets/visualizer_panel_grid.dart`  | Matrix cells                                                          |
| `lib/widgets/custom_card.dart`            | Shared card chrome                                                    |
| `web/`                                    | Flutter web host, manifest, icons                                     |
| `.github/workflows/deploy.yml`            | GitHub Pages build                                                    |

Dependencies: Flutter SDK, `flutter_bloc` `^9.1.1`. Dev dependency: `flutter_lints` `^6.0.0`. Dart SDK constraint:
`^3.13.1`. This repository contains the web target only.

---

## Run locally

Use Flutter stable. Continuous deployment pins Flutter **3.47.1**.

```bash
flutter pub get
flutter run -d chrome
```

Release build (same flags as CI, without the GitHub Pages base path):

```bash
flutter build web --wasm --release
```

Output is written to `build/web`.

---

## Deployment

Pushes to the `deploy` branch run `.github/workflows/deploy.yml`:

1. Check out the repo.
2. Install Flutter `3.47.1` (stable) via `subosito/flutter-action`.
3. Run `flutter pub get`.
4. Build with `flutter build web --wasm --release --base-href "/cipher_forge_secure_keysmith/"`.
5. Publish `build/web` to the `gh-pages` branch with `JamesIves/github-pages-deploy-action`.

The workflow needs **contents: write**. GitHub Pages should serve the `gh-pages` branch from `/`. The base href must
match the repository path and must start and end with `/`. A custom domain or a user/organization site served from the
domain root uses `"/"`.

Published
site: [https://channdara.github.io/cipher_forge_secure_keysmith/](https://channdara.github.io/cipher_forge_secure_keysmith/)
