// controllers/seatsCalculator.dart
import 'electionCalc.dart';

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
    final seatsDict = {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
    };

    if (seatsNum <= 0) {
      return {
        "recivedVotes": seatsDict,
        "differencesNxt": <String>{},
        "differencesPrev": <String>{},
      };
    }

    final voteDict = <String, double>{
      "PiS": PiS,
      "KO": KO,
      "Trzecia Droga": TD,
      "Lewica": Lewica,
      "Konfederacja": Konf,
    };

    Map<String, int> recivedVotes = {};
    Map<String, int> nextSeat = {};
    Map<String, int> prevSeat = {};

    Map<String, int> _freshSeats() => {
          "PiS": 0,
          "KO": 0,
          "Trzecia Droga": 0,
          "Lewica": 0,
          "Konfederacja": 0,
        };

    switch (method) {
      case "d'Hondta":
        recivedVotes = dhont(Map.from(seatsDict), voteDict, seatsNum);
        nextSeat = dhont(_freshSeats(), voteDict, seatsNum + 1);
        if (seatsNum - 1 > 0) {
          prevSeat = dhont(_freshSeats(), voteDict, seatsNum - 1);
        }
        break;

      case "Sainte-Laguë":
        recivedVotes = sainteLague(Map.from(seatsDict), voteDict, seatsNum);
        nextSeat = sainteLague(_freshSeats(), voteDict, seatsNum + 1);
        if (seatsNum - 1 > 0) {
          prevSeat = sainteLague(_freshSeats(), voteDict, seatsNum - 1);
        }
        break;

      case "Kwota Hare’a (metoda największych reszt)":
        recivedVotes = hareDrop(
          Map.from(seatsDict),
          voteDict,
          seatsNum,
          Freq,
          biggest: true,
        );
        nextSeat = hareDrop(_freshSeats(), voteDict, seatsNum + 1, Freq,
            biggest: true);
        if (seatsNum - 1 > 0) {
          prevSeat = hareDrop(_freshSeats(), voteDict, seatsNum - 1, Freq,
              biggest: true);
        }
        break;

      case "Kwota Hare’a (metoda najmniejszych reszt)":
        recivedVotes = hareDrop(
          Map.from(seatsDict),
          voteDict,
          seatsNum,
          Freq,
          biggest: false,
        );
        nextSeat = hareDrop(_freshSeats(), voteDict, seatsNum + 1, Freq,
            biggest: false);
        if (seatsNum - 1 > 0) {
          prevSeat = hareDrop(_freshSeats(), voteDict, seatsNum - 1, Freq,
              biggest: false);
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

    // Sprawdzamy, kto się zmienia przy +1 i -1
    final differencesNxt = <String>{};
    nextSeat.forEach((key, value) {
      if (recivedVotes[key] != value) {
        differencesNxt.add(key);
      }
    });

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
