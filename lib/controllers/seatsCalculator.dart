// controllers/seatsCalculator.dart
import 'package:flutter/foundation.dart';
import 'electionCalc.dart';

/// Klasa do kalkulacji mandatów w JEDNYM okręgu na podstawie 5 partii (PiS, KO, Trzecia Droga, Lewica, Konf).
///
/// Zwraca obiekt zawierający:
/// - "recivedVotes": finalny przydział mandatów (Map<String, int>)
/// - "differencesNxt": zbiór partii, u których przy zwiększeniu puli mandatów o 1
///   wynik różni się od `recivedVotes`
/// - "differencesPrev": zbiór partii, u których przy zmniejszeniu puli mandatów o 1
///   wynik różni się od `recivedVotes`
class SeatsCalculatorSingleDistrict {
  static Map<String, dynamic> chooseMethods({
    required double PiS,
    required double KO,
    required double TD,
    required double Lewica,
    required double Konf,
    required double Freq,
    required String method,
    required int seatsNum,
  }) {
    // Słownik z głosami
    final voteDict = <String, double>{
      "PiS": PiS,
      "KO": KO,
      "Trzecia Droga": TD,
      "Lewica": Lewica,
      "Konfederacja": Konf,
    };

    // Wynik
    Map<String, int> recivedVotes = {};
    Map<String, int> nextSeat = {};
    Map<String, int> prevSeat = {};

    // Startowe 0 mandatów
    Map<String, int> seatsDict = {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
    };

    // Pomocnicza funkcja do tworzenia świeżego (zerowego) słownika
    Map<String, int> _freshSeats() => {
          "PiS": 0,
          "KO": 0,
          "Trzecia Droga": 0,
          "Lewica": 0,
          "Konfederacja": 0,
        };

    // Na wypadek, gdyby seatsNum był <= 0
    if (seatsNum <= 0) {
      return {
        "recivedVotes": seatsDict,
        "differencesNxt": <String>{},
        "differencesPrev": <String>{},
      };
    }

    // Wybór metody:
    switch (method) {
      case "d'Hondta":
        recivedVotes = dhont(
          Map<String, int>.from(seatsDict),
          voteDict,
          seatsNum,
        );
        nextSeat = dhont(_freshSeats(), voteDict, seatsNum + 1);
        if (seatsNum - 1 > 0) {
          prevSeat = dhont(_freshSeats(), voteDict, seatsNum - 1);
        }
        break;

      case "Sainte-Laguë":
        recivedVotes = sainteLague(
          Map<String, int>.from(seatsDict),
          voteDict,
          seatsNum,
        );
        nextSeat = sainteLague(_freshSeats(), voteDict, seatsNum + 1);
        if (seatsNum - 1 > 0) {
          prevSeat = sainteLague(_freshSeats(), voteDict, seatsNum - 1);
        }
        break;

      case "Kwota Hare’a (metoda największych reszt)":
        recivedVotes = hareDrop(
          Map<String, int>.from(seatsDict),
          voteDict,
          seatsNum,
          Freq,
          biggest: true,
        );
        nextSeat = hareDrop(
          _freshSeats(),
          voteDict,
          seatsNum + 1,
          Freq,
          biggest: true,
        );
        if (seatsNum - 1 > 0) {
          prevSeat = hareDrop(
            _freshSeats(),
            voteDict,
            seatsNum - 1,
            Freq,
            biggest: true,
          );
        }
        break;

      case "Kwota Hare’a (metoda najmniejszych reszt)":
        recivedVotes = hareDrop(
          Map<String, int>.from(seatsDict),
          voteDict,
          seatsNum,
          Freq,
          biggest: false,
        );
        nextSeat = hareDrop(
          _freshSeats(),
          voteDict,
          seatsNum + 1,
          Freq,
          biggest: false,
        );
        if (seatsNum - 1 > 0) {
          prevSeat = hareDrop(
            _freshSeats(),
            voteDict,
            seatsNum - 1,
            Freq,
            biggest: false,
          );
        }
        break;

      default:
        // Nieznana metoda
        return {
          "recivedVotes": seatsDict,
          "differencesNxt": <String>{},
          "differencesPrev": <String>{},
        };
    }

    // Oblicz, kto się zmienia przy +1
    final differencesNxt = <String>{};
    nextSeat.forEach((key, value) {
      if (recivedVotes[key] != value) {
        differencesNxt.add(key);
      }
    });

    // Oblicz, kto się zmienia przy -1
    final differencesPrev = <String>{};
    prevSeat.forEach((key, value) {
      if (recivedVotes[key] != value) {
        differencesPrev.add(key);
      }
    });

    return {
      "recivedVotes": recivedVotes,
      "differencesNxt": differencesNxt,
      "differencesPrev": differencesPrev,
    };
  }
}
