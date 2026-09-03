import 'dart:math';

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

class PasswordGenerator {
  PasswordGenerator._();

  static const String uppercaseChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String lowercaseChars = 'abcdefghijkmnopqrstuvwxyz';
  static const String digitChars = '23456789';
  static const String symbolChars = r"!@#$%^&*()-_=+[]{};:',.<>?/~";

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

    for (var i = 0; i < length; i++) {
      final List<String> w = [];

      if (length < activePools.length) {
        final List<int> shuffledIndices = List.generate(
          activePools.length,
          (index) => index,
        )..shuffle(random);
        for (var j = 0; j < length; j++) {
          final String pool = activePools[shuffledIndices[j]];
          w.add(pool[random.nextInt(pool.length)]);
        }
      } else {
        for (final pool in activePools) {
          w.add(pool[random.nextInt(pool.length)]);
        }
        final int remaining = length - activePools.length;
        for (var j = 0; j < remaining; j++) {
          w.add(allChars[random.nextInt(allChars.length)]);
        }
      }

      w.shuffle(random);
      p.add(w.join());
    }

    final List<int> chosenIndices = List.filled(length, -1);
    final List<String> mChars = List.filled(length, '');

    if (length >= activePools.length) {
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

        final int selectedCharIdx =
            matchingIndices[random.nextInt(matchingIndices.length)];
        chosenIndices[row] = selectedCharIdx;
        mChars[row] = p[row][selectedCharIdx];
      }

      for (var i = 0; i < length; i++) {
        if (chosenIndices[i] == -1) {
          final int selectedCharIdx = random.nextInt(p[i].length);
          chosenIndices[i] = selectedCharIdx;
          mChars[i] = p[i][selectedCharIdx];
        }
      }
    } else {
      List<int> bestIndices = [];
      var bestUniqueCount = -1;

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
