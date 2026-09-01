import 'dart:math';

/// Holds the results of a password generation, including the main master
/// password, the list of alternative passwords generated during the process,
/// and the indices of the characters chosen from each alternative password.
class PasswordResult {
  PasswordResult({
    required this.masterPassword,
    required this.alternativePasswords,
    required this.chosenIndices,
  });

  final String masterPassword;
  final List<String> alternativePasswords;
  final List<int> chosenIndices;
}

/// A cryptographically secure password generator based on the custom algorithm.
class PasswordGenerator {
  PasswordGenerator._();

  // Excludes ambiguous characters to prevent confusion (e.g. 'I', 'O', 'l', '0', '1')
  static const String uppercaseChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String lowercaseChars = 'abcdefghijkmnopqrstuvwxyz';
  static const String digitChars = '23456789';
  static const String symbolChars = r"!@#$%^&*()-_=+[]{};:',.<>?/~";

  /// Generates a [PasswordResult] containing a master password of length [length]
  /// and [length] intermediate/alternative passwords of length [length].
  ///
  /// The algorithm:
  /// 1. Determines active pools based on options.
  /// 2. Generates [length] intermediate passwords. For each:
  ///    - Guarantees at least one character from each active pool (if length allows).
  ///    - Fills the rest of the length from all active pools combined.
  ///    - Shuffles the characters using a secure random number generator.
  /// 3. Generates the master password by picking one random character from each
  ///    of the [length] intermediate passwords.
  static PasswordResult generate({
    required int length,
    required bool useUppercase,
    required bool useLowercase,
    required bool useDigits,
    required bool useSymbols,
  }) {
    if (length <= 0) {
      throw ArgumentError('Length must be greater than zero.');
    }

    final activePools = <String>[];
    if (useUppercase) {
      activePools.add(uppercaseChars);
    }
    if (useLowercase) {
      activePools.add(lowercaseChars);
    }
    if (useDigits) {
      activePools.add(digitChars);
    }
    if (useSymbols) {
      activePools.add(symbolChars);
    }

    // If no option is selected, return empty results
    if (activePools.isEmpty) {
      return PasswordResult(
        masterPassword: '',
        alternativePasswords: [],
        chosenIndices: [],
      );
    }

    final String allChars = activePools.join();
    final random = Random.secure();

    final List<String> p = [];

    // Generate 'length' alternative passwords
    for (var i = 0; i < length; i++) {
      final List<String> w = [];

      if (length < activePools.length) {
        // Edge case: if length is smaller than the number of active pools,
        // we randomly select a subset of the pools to ensure variety.
        final List<int> shuffledIndices = List.generate(
          activePools.length,
          (index) => index,
        )..shuffle(random);
        for (var j = 0; j < length; j++) {
          final String pool = activePools[shuffledIndices[j]];
          w.add(pool[random.nextInt(pool.length)]);
        }
      } else {
        // Normal case: ensure at least one character from each active pool is present.
        for (final pool in activePools) {
          w.add(pool[random.nextInt(pool.length)]);
        }
        // Fill the remaining spots with random characters from the combined active pool.
        final int remaining = length - activePools.length;
        for (var j = 0; j < remaining; j++) {
          w.add(allChars[random.nextInt(allChars.length)]);
        }
      }

      // Shuffle the characters securely
      w.shuffle(random);
      p.add(w.join());
    }

    // Generate master password by taking 1 random character from each of the 'length' passwords
    // in a way that guarantees that every active pool is represented in the master password.
    final List<int> chosenIndices = List.filled(length, -1);
    final List<String> mChars = List.filled(length, '');

    if (length >= activePools.length) {
      // Normal case: We can guarantee that EVERY active pool is represented in the master password.
      final List<String> shuffledPools = List.from(activePools)
        ..shuffle(random);
      final List<int> rowIndices = List.generate(length, (index) => index)
        ..shuffle(random);
      final List<int> assignedRows = rowIndices.sublist(0, activePools.length);

      for (var j = 0; j < activePools.length; j++) {
        final int row = assignedRows[j];
        final String pool = shuffledPools[j];

        final List<int> matchingIndices = [];
        for (var charIdx = 0; charIdx < p[row].length; charIdx++) {
          if (pool.contains(p[row][charIdx])) {
            matchingIndices.add(charIdx);
          }
        }

        // Under normal case (length >= activePools.length), matchingIndices is guaranteed to be non-empty.
        final int selectedCharIdx =
            matchingIndices[random.nextInt(matchingIndices.length)];
        chosenIndices[row] = selectedCharIdx;
        mChars[row] = p[row][selectedCharIdx];
      }

      // Fill other rows randomly
      for (var i = 0; i < length; i++) {
        if (chosenIndices[i] == -1) {
          final int selectedCharIdx = random.nextInt(p[i].length);
          chosenIndices[i] = selectedCharIdx;
          mChars[i] = p[i][selectedCharIdx];
        }
      }
    } else {
      // Edge case: length < activePools.length.
      // We cannot represent all active pools. We will find a selection of indices that
      // maximizes the number of unique active pools represented in the master password.
      List<int> bestIndices = [];
      var bestUniqueCount = -1;

      // Since length is very small (length < 4), a randomized search with 100 trials is extremely fast and effective.
      for (var retry = 0; retry < 100; retry++) {
        final List<int> candidateIndices = [];
        final Set<String> representedPools = {};
        for (var i = 0; i < length; i++) {
          final int idx = random.nextInt(p[i].length);
          candidateIndices.add(idx);
          final String char = p[i][idx];
          for (final pool in activePools) {
            if (pool.contains(char)) {
              representedPools.add(pool);
              break;
            }
          }
        }
        final int uniqueCount = representedPools.length;
        if (uniqueCount == length) {
          // Reached maximum possible unique pools (one for each character of the master key)
          bestIndices = candidateIndices;
          break;
        }
        if (uniqueCount > bestUniqueCount) {
          bestIndices = candidateIndices;
          bestUniqueCount = uniqueCount;
        }
      }

      for (var i = 0; i < length; i++) {
        chosenIndices[i] = bestIndices[i];
        mChars[i] = p[i][bestIndices[i]];
      }
    }

    final String masterPassword = mChars.join();

    return PasswordResult(
      masterPassword: masterPassword,
      alternativePasswords: p,
      chosenIndices: chosenIndices,
    );
  }
}
