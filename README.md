# CipherForge: Secure Keysmith

CipherForge: Secure Keysmith is a modern, responsive, and visually stunning password generation utility built with
Flutter. It utilizes a **customized matrix algorithm** with cryptographically secure random number generation to
construct extremely secure passwords. The application offers users interactive configuration controls, real-time
security strength estimation (including Shannon entropy and estimated crack times), and a unique live interactive
visualizer that reveals the inner workings of the underlying matrix generation algorithm.

---

## 🚀 Key Features

* **Interactive Settings:**
    * Adjust password length from **6 to 32 characters**.
    * Dynamic toggle switches for **Uppercase letters**, **Lowercase letters**, **Digits**, and **Symbols**.
* **Cryptographically Secure & Highly Readable:**
    * Uses `Random.secure()` under the hood to ensure strong randomness.
    * Systematically excludes ambiguous characters (such as `I`, `O`, `l`, `0`, and `1`) to avoid readability confusion.
* **Algorithm Insights Visualizer:**
    * Displays an interactive matrix showing the intermediate alternative keys generated during the process.
    * Highlights the exact characters and their index positions picked from each row to form the final Master Password.
* **Real-time Security Metrics:**
    * Calculates Shannon entropy in bits dynamically.
    * Displays a human-readable strength indicator (Very Weak, Weak, Medium, Strong, Extremely Secure).
    * Estimates crack time based on a simulated supercomputer array executing **10 billion attempts per second**.
* **Modern UI:**
    * Beautifully designed dark-themed interface built with Material 3 Design (MD3).
    * Seamless responsiveness adapting to both desktop (>900px wide) and mobile layouts.
    * Animated feedback on password regeneration and copy-to-clipboard actions.

## 🛠️ The Custom Password Generation Algorithm

The generator uses a unique matrix/alternative-key approach to construct the final master password. The step-by-step
process is as follows:

```
+--------------------------------------------------------------+
|                      Configuration                           |
|  - Length (L)                                                |
|  - Active Pools (Uppercase, Lowercase, Numbers, Symbols)     |
+------------------------------+-------------------------------+
                               |
                               v
+------------------------------+-------------------------------+
|                1. Generate L Intermediate Keys               |
|  - Each key has length L.                                    |
|  - Ensure at least one character from each active pool.      |
|  - Fill remaining slots from combined active character pool. |
|  - Shuffle characters in each intermediate key using         |
|    Random.secure().                                          |
+------------------------------+-------------------------------+
                               |
                               v
+------------------------------+-------------------------------+
|         Matrix (L x L) of Intermediate Passwords             |
|  Row #01:  [  K  ]  [  d  ]  [ *s* ]  [  a  ]  ...  [  9  ]  |
|  Row #02:  [ *G* ]  [  4  ]  [  !  ]  [  u  ]  ...  [  b  ]  |
|  Row #03:  [  f  ]  [  v  ]  [  8  ]  [ *T* ]  ...  [  %  ]  |
|  ...                                                         |
|  Row #L :  [  m  ]  [  3  ]  [  R  ]  [  j  ]  ...  [ *#* ]  |
+------------------------------+-------------------------------+
                               |
                               v
+------------------------------+-------------------------------+
|             2. Extract 1 Character Per Row                   |
|  - For each row i, select a random index chosen securely.    |
|  - The selected character forms the i-th character of the    |
|    final Master Password.                                    |
+------------------------------+-------------------------------+
                               |
                               v
+------------------------------+-------------------------------+
|                3. Assemble Master Password                   |
|                   e.g., "sG T...#"                           |
+--------------------------------------------------------------+
```

### Character Pools

To prevent human reading errors, the character pools exclude ambiguous characters:

| Pool          | Allowed Characters             | Excluded Ambiguous Characters | Length |
|---------------|--------------------------------|-------------------------------|--------|
| **Uppercase** | `ABCDEFGHJKLMNPQRSTUVWXYZ`     | `I`, `O`                      | 24     |
| **Lowercase** | `abcdefghijkmnopqrstuvwxyz`    | `l`                           | 25     |
| **Digits**    | `23456789`                     | `0`, `1`                      | 8      |
| **Symbols**   | `!@#$%^&*()-_=+[]{};:',.<>?/~` | None                          | 28     |

## 📊 Entropy & Security Metrics

CipherForge calculates security metrics in real time based on standard cryptographic formulas.

### 1. Shannon Entropy

Shannon entropy measures the uncertainty or unpredictability of the generated password. It is calculated in bits using
the formula:

$$E = L \times \log_2 (P)$$

Where:

* $E$ = Entropy in bits.
* $L$ = Length of the password.
* $P$ = Size of the character pool (sum of the lengths of all active character sets).

### 2. Strength Tiers

Based on the computed entropy ($E$), the password's strength is categorized into one of five tiers:

| Entropy Range ($E$ in bits) | Strength Classification | UI Color |
|-----------------------------|-------------------------|----------|
| $E < 28$                    | Very Weak               | Red      |
| $28 \le E < 50$             | Weak                    | Orange   |
| $50 \le E < 75$             | Medium                  | Amber    |
| $75 \le E < 100$            | Strong                  | Green    |
| $E \ge 100$                 | Extremely Secure        | Cyan     |

### 3. Estimated Crack Time

Estimates the duration required for an attacker to crack the password.

* **Attacker Assumption:** A high-speed supercomputer cluster performing **10 billion ($10^{10}$)** guesses/attempts per
  second.
* **Formula:**

  $$\text{Time in seconds } (T) = \frac{2^{E - 1}}{10^{10}}$$

    * Note: We divide by $2$ ($2^{E-1}$) to model the average case scenario (finding the password halfway through the
      search space).
    * The computed time in seconds is converted to human-friendly terms (e.g., Instantly, minutes, hours, days, months,
      years, thousands of years `k years`, million years, or billion years).

## 🏗️ Architectural Overview & Directory Structure

The project follows clean Flutter architecture patterns and relies on the BLoC state management pattern:

* **State Management:** Powered by `flutter_bloc` to handle user input events asynchronously, perform computations, and
  rebuild UI state reactively.
* **Presentation Layer:** Card widgets designed to support clean dark theme interfaces with flexible desktop-first &
  mobile-first layouts.

---