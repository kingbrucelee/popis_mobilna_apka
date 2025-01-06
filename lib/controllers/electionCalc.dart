// controllers/electionCalc.dart
import 'dart:math' as math;

/// Model jednego wiersza z CSV (np. dane o jednym okręgu)
class CsvRow {
  final Map<String, double> data;
  CsvRow(this.data);
}

/// Przykładowe proste funkcje do metod podziału
Map<String, int> dhont(
  Map<String, int> seatsDict,
  Map<String, double> voteDict,
  int seatsNum,
) {
  final copy = Map<String, double>.from(voteDict);

  for (int i = 0; i < seatsNum; i++) {
    final maxParty = copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
    seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
    copy[maxParty] = voteDict[maxParty]! / (seatsDict[maxParty]! + 1);
  }

  return seatsDict;
}

Map<String, int> sainteLague(
  Map<String, int> seatsDict,
  Map<String, double> voteDict,
  int seatsNum,
) {
  final copy = Map<String, double>.from(voteDict);

  for (int i = 0; i < seatsNum; i++) {
    final maxParty = copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
    seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
    // dzielnik 2n + 1
    copy[maxParty] = voteDict[maxParty]! / (2.0 * seatsDict[maxParty]! + 1.0);
  }

  return seatsDict;
}

Map<String, int> hareDrop(
  Map<String, int> seatsDict,
  Map<String, double> voteDict,
  int seatsNum,
  double freq, {
  required bool biggest,
}) {
  final copy = Map<String, double>.from(voteDict);
  int remaining = seatsNum;

  // krok 1: przydział "bazowy"
  copy.forEach((party, votes) {
    final value = (votes * seatsNum) / freq;
    final baseSeats = value.floor();
    seatsDict[party] = baseSeats;
    copy[party] = value - baseSeats; // reszta
    remaining -= baseSeats;
  });

  // krok 2: rozdział według reszt największych / najmniejszych
  for (int i = 0; i < remaining; i++) {
    if (biggest) {
      final maxParty = copy.keys.reduce((a, b) => copy[a]! > copy[b]! ? a : b);
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
      copy[maxParty] = 0;
    } else {
      final minParty = copy.keys.reduce((a, b) => copy[a]! < copy[b]! ? a : b);
      seatsDict[minParty] = (seatsDict[minParty] ?? 0) + 1;
      copy[minParty] = double.infinity;
    }
  }

  return seatsDict;
}

/// Prosty przykład liczenia, które partie przekroczyły progi (np. 4% / 9%)
Map<String, dynamic> calculateVotesFromCsv({
  required List<CsvRow> csvData,
  required double threshold,
  required double coalitionThreshold,
  required List<String> exemptedParties, // partie zwolnione z progu
}) {
  // Zsumuj głosy w całym CSV
  final Map<String, double> totalVotes = {};
  double allVotes = 0;

  for (var row in csvData) {
    row.data.forEach((party, votes) {
      totalVotes[party] = (totalVotes[party] ?? 0) + votes;
      allVotes += votes;
    });
  }

  // Sprawdzamy próg
  final qualifiedParties = <String>[];
  totalVotes.forEach((party, votes) {
    if (exemptedParties.contains(party)) {
      // Zwolniona z progu
      qualifiedParties.add(party);
    } else {
      final percent = (votes / (allVotes == 0 ? 1 : allVotes)) * 100.0;
      if (percent >= threshold) {
        // jeśli to koalicja, może mieć inny próg
        if (party.toUpperCase().contains("KOALICYJNY")) {
          if (percent >= coalitionThreshold) {
            qualifiedParties.add(party);
          }
        } else {
          qualifiedParties.add(party);
        }
      }
    }
  });

  return {
    "allVotes": allVotes,
    "totalVotes": totalVotes,
    "qualifiedParties": qualifiedParties,
  };
}
