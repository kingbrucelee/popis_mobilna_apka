import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart' as csv;
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';

import '../controllers/seatsCalculator.dart';
import '../controllers/electionCalc.dart';
import '../api_wrappers/clubs.dart';

/// Główny widget ekranu z zakładkami
class View3 extends StatefulWidget {
  const View3({Key? key}) : super(key: key);

  @override
  _View3State createState() => _View3State();
}

class _View3State extends State<View3> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int termNumber = 10;
  List<dynamic> coalitions = [];

  Widget _buildPotentialCoalitionTab() {
    if (coalitions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        const Text(
          'Potencjalne Koalicje',
          style: TextStyle(fontSize: 24),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: coalitions.length,
            itemBuilder: (context, index) {
              var coalition = coalitions[index];
              var totalMPs =
                  coalition.fold(0, (sum, club) => sum + club['membersCount']);
              var clubs = coalition.map((club) => club['id']).join(', ');
              return ListTile(
                title: Text('Koalicja ${index + 1}'),
                subtitle:
                    Text('Łączna liczba posłów: $totalMPs\nKluby: $clubs'),
                onTap: () => _showCoalitionDetails(context, coalition),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCoalitionDetails(BuildContext context, List<dynamic> coalition) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Szczegóły Koalicji'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: coalition.map((club) {
              return ListTile(
                title: Text(club['id']),
                subtitle: Text('Posłów: ${club['membersCount']}'),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zamknij'),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------
  // Dane testowe "dataJson" i "votesJson" (dla zakładki "Własne")
  // -------------------------------------------------------
  Map<String, dynamic> dataJson = {
    "Legnica": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Wałbrzych": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 8,
      "Uzupełniono": false,
    },
    "Wrocław": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 14,
      "Uzupełniono": false,
    },
    "Bydgoszcz": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Toruń": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 13,
      "Uzupełniono": false,
    },
    "Lublin": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 15,
      "Uzupełniono": false,
    },
    "Chełm": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Zielona Góra": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Łódź": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Piotrków Trybunalski": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Sieradz": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Chrzanów": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 8,
      "Uzupełniono": false,
    },
    "Kraków": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 14,
      "Uzupełniono": false,
    },
    "Nowy Sącz": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Tarnów": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Płock": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Radom": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Siedlce": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Warszawa": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 20,
      "Uzupełniono": false,
    },
    "Warszawa 2": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Opole": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Krosno": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 11,
      "Uzupełniono": false,
    },
    "Rzeszów": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 15,
      "Uzupełniono": false,
    },
    "Białystok": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 14,
      "Uzupełniono": false,
    },
    "Gdańsk": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Słupsk": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 14,
      "Uzupełniono": false,
    },
    "Bielsko-Biała": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Częstochowa": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 7,
      "Uzupełniono": false,
    },
    "Gliwice": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Rybnik": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Katowice": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Sosnowiec": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Kielce": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 16,
      "Uzupełniono": false,
    },
    "Elbląg": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 8,
      "Uzupełniono": false,
    },
    "Olsztyn": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Kalisz": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Konin": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Piła": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Poznań": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Koszalin": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 8,
      "Uzupełniono": false,
    },
    "Szczecin": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
  };

  // votesJson
  Map<String, dynamic> votesJson = {
    "Legnica": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Wałbrzych": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Wrocław": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Bydgoszcz": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Toruń": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Lublin": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Chełm": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Zielona Góra": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Łódź": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Piotrków Trybunalski": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Sieradz": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Chrzanów": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Kraków": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Nowy Sącz": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Tarnów": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Płock": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Radom": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Siedlce": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Warszawa": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Warszawa 2": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Opole": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Krosno": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Rzeszów": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Białystok": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Gdańsk": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Słupsk": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Bielsko-Biała": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Częstochowa": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Gliwice": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Rybnik": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Katowice": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Sosnowiec": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Kielce": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Elbląg": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Olsztyn": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Kalisz": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Konin": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Piła": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Poznań": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Koszalin": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Szczecin": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCoalitions();
  }

  void _loadCoalitions() async {
    List<dynamic> fetchedCoalitions = await findMinimalCoalitions(termNumber);
    setState(() {
      coalitions = fetchedCoalitions;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Przykładowa funkcja budująca zawartość nieużywanych jeszcze zakładek
  Widget _buildTabContent(String title) {
    return Center(
      child: Text('$title content here', style: const TextStyle(fontSize: 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bar_chart, size: 32),
              SizedBox(width: 8),
              Text(
                'Analiza Polityczna',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(
              child: Text(
                'Potencjalne Koalicje',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Tab(
              child: Text(
                'Kalkulator Wyborczy',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Tab(
              child: Text(
                'Korelacje Wyborcze',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Tab(
              child: Text(
                'Prawo Benforda',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPotentialCoalitionTab(),
          _buildElectionCalculatorTab(),
          _buildTabContent('Korelacje Wyborcze'),
          _buildTabContent('Prawo Benforda'),
        ],
      ),
    );
  }

  /// Zakładka "Kalkulator Wyborczy" z dwoma podzakładkami: "Własne" i "Rzeczywiste"
  Widget _buildElectionCalculatorTab() {
    return DefaultTabController(
      length: 2, // Dwie podzakładki
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.red,
            tabs: [
              Tab(text: "Własne"),
              Tab(text: "Rzeczywiste"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // 1) WŁASNE – nasz dotychczasowy widget
                ElectionCalculatorTab(
                  dataJson: dataJson,
                  votesJson: votesJson,
                  onDataJsonChanged: (updated) {
                    setState(() {
                      dataJson = updated;
                    });
                  },
                  onVotesJsonChanged: (updated) {
                    setState(() {
                      votesJson = updated;
                    });
                  },
                ),

                // 2) RZECZYWISTE – wczytuje dane z CSV i wyświetla
                const RealElectionCalculatorTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------------
/// Widget `ElectionCalculatorTab` ("Własne" dane użytkownika)
/// ----------------------------------------------------------
class ElectionCalculatorTab extends StatefulWidget {
  final Map<String, dynamic> dataJson;
  final Map<String, dynamic> votesJson;
  final ValueChanged<Map<String, dynamic>> onDataJsonChanged;
  final ValueChanged<Map<String, dynamic>> onVotesJsonChanged;

  const ElectionCalculatorTab({
    Key? key,
    required this.dataJson,
    required this.votesJson,
    required this.onDataJsonChanged,
    required this.onVotesJsonChanged,
  }) : super(key: key);

  @override
  _ElectionCalculatorTabState createState() => _ElectionCalculatorTabState();
}

class _ElectionCalculatorTabState extends State<ElectionCalculatorTab> {
  String _type = "ilościowy"; // "ilościowy" lub "procentowy"
  String _method = "d'Hondt";
  late String _selectedDistrict;

  double _pis = 0.0;
  double _ko = 0.0;
  double _td = 0.0;
  double _lewica = 0.0;
  double _konfederacja = 0.0;
  double _frequency = 0.0;
  int _seatsNum = 0;

  Map<String, int> _resultSeats = {};

  late TextEditingController _pisController;
  late TextEditingController _koController;
  late TextEditingController _tdController;
  late TextEditingController _lewicaController;
  late TextEditingController _konfController;
  late TextEditingController _frequencyController;
  late TextEditingController _seatsController;

  @override
  void initState() {
    super.initState();
    _selectedDistrict = widget.dataJson.keys.first;
    _loadDistrictValues(_selectedDistrict);

    _pisController = TextEditingController();
    _koController = TextEditingController();
    _tdController = TextEditingController();
    _lewicaController = TextEditingController();
    _konfController = TextEditingController();
    _frequencyController = TextEditingController();
    _seatsController = TextEditingController();

    _setControllersValues();
  }

  @override
  void dispose() {
    _pisController.dispose();
    _koController.dispose();
    _tdController.dispose();
    _lewicaController.dispose();
    _konfController.dispose();
    _frequencyController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  void _loadDistrictValues(String district) {
    final distData = widget.dataJson[district];
    final distVotes = widget.votesJson[district];
    if (distData != null && distVotes != null) {
      _pis = (distVotes["PiS"] as num?)?.toDouble() ?? 0.0;
      _ko = (distVotes["KO"] as num?)?.toDouble() ?? 0.0;
      _td = (distVotes["Trzecia Droga"] as num?)?.toDouble() ?? 0.0;
      _lewica = (distVotes["Lewica"] as num?)?.toDouble() ?? 0.0;
      _konfederacja = (distVotes["Konfederacja"] as num?)?.toDouble() ?? 0.0;

      _frequency = (distData["Frekwencja"] as num?)?.toDouble() ?? 0.0;
      _seatsNum = distData["Miejsca do zdobycia"] ?? 0;
    }
  }

  void _setControllersValues() {
    _pisController.text = _pis == 0.0 ? '' : _pis.toString();
    _koController.text = _ko == 0.0 ? '' : _ko.toString();
    _tdController.text = _td == 0.0 ? '' : _td.toString();
    _lewicaController.text = _lewica == 0.0 ? '' : _lewica.toString();
    _konfController.text = _konfederacja == 0.0 ? '' : _konfederacja.toString();
    _frequencyController.text = _frequency == 0.0 ? '' : _frequency.toString();
    _seatsController.text = _seatsNum == 0 ? '' : _seatsNum.toString();
  }

  void _updateTempValuesFromControllers() {
    _pis = _parseDouble(_pisController.text);
    _ko = _parseDouble(_koController.text);
    _td = _parseDouble(_tdController.text);
    _lewica = _parseDouble(_lewicaController.text);
    _konfederacja = _parseDouble(_konfController.text);
    _frequency = _parseDouble(_frequencyController.text);
    _seatsNum = int.tryParse(_seatsController.text) ?? 0;
  }

  double _parseDouble(String val) {
    return double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
  }

  void _calculateSeats() {
    _updateTempValuesFromControllers();

    if (_seatsNum <= 0) {
      _showErrorDialog("Liczba mandatów musi być większa niż 0.");
      return;
    }

    final sumVotes = _pis + _ko + _td + _lewica + _konfederacja;
    if (sumVotes == 0) {
      _showErrorDialog("Wprowadź co najmniej jedną partię z głosami > 0.");
      return;
    }

    if (_type == "procentowy" && (sumVotes - 100.0).abs() > 0.0001) {
      _showErrorDialog(
          "Suma procentów musi wynosić dokładnie 100% (obecnie: $sumVotes).");
      return;
    }

    double totalVotes = _frequency;
    double actualPis = _type == "procentowy" ? (_pis / 100) * totalVotes : _pis;
    double actualKo = _type == "procentowy" ? (_ko / 100) * totalVotes : _ko;
    double actualTd = _type == "procentowy" ? (_td / 100) * totalVotes : _td;
    double actualLewica =
        _type == "procentowy" ? (_lewica / 100) * totalVotes : _lewica;
    double actualKonf = _type == "procentowy"
        ? (_konfederacja / 100) * totalVotes
        : _konfederacja;

    widget.votesJson[_selectedDistrict]["PiS"] = actualPis;
    widget.votesJson[_selectedDistrict]["KO"] = actualKo;
    widget.votesJson[_selectedDistrict]["Trzecia Droga"] = actualTd;
    widget.votesJson[_selectedDistrict]["Lewica"] = actualLewica;
    widget.votesJson[_selectedDistrict]["Konfederacja"] = actualKonf;

    widget.dataJson[_selectedDistrict]["Frekwencja"] = _frequency;
    widget.dataJson[_selectedDistrict]["Miejsca do zdobycia"] = _seatsNum;

    widget.onVotesJsonChanged(widget.votesJson);
    widget.onDataJsonChanged(widget.dataJson);

    final result = SeatsCalculator.chooseMethods(
      PiS: actualPis,
      KO: actualKo,
      TD: actualTd,
      Lewica: actualLewica,
      Konfederacja: actualKonf,
      Freq: totalVotes,
      seatsNum: _seatsNum,
      method: _method,
    );

    final seatsMap = result[0] as Map<String, int>;

    setState(() {
      _resultSeats = seatsMap;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Błąd"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      controller: controller,
    );
  }

  Widget _buildResultsTable() {
    if (_resultSeats.isEmpty) {
      return const Text(
        "",
        style: TextStyle(color: Colors.grey),
      );
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Komitet')),
        DataColumn(label: Text('Mandaty')),
      ],
      rows: _resultSeats.entries.map((entry) {
        return DataRow(
          cells: [
            DataCell(Text(entry.key)),
            DataCell(Text(entry.value.toString())),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wybierz okręg:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedDistrict,
            items: widget.dataJson.keys.map<DropdownMenuItem<String>>((dist) {
              return DropdownMenuItem<String>(
                value: dist,
                child: Text(dist),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedDistrict = value;
                  _loadDistrictValues(value);
                  _setControllersValues();
                });
              }
            },
          ),
          const Divider(),
          const Text('Rodzaj głosów:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _type,
            items: const [
              DropdownMenuItem(value: "ilościowy", child: Text("Ilościowy")),
              DropdownMenuItem(value: "procentowy", child: Text("Procentowy")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _type = value;
                });
              }
            },
          ),
          const Divider(),
          _buildNumberField(label: 'PiS', controller: _pisController),
          _buildNumberField(label: 'KO', controller: _koController),
          _buildNumberField(label: 'Trzecia Droga', controller: _tdController),
          _buildNumberField(label: 'Lewica', controller: _lewicaController),
          _buildNumberField(label: 'Konfederacja', controller: _konfController),
          _buildNumberField(
              label: 'Frekwencja (%)', controller: _frequencyController),
          TextField(
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Liczba mandatów w okręgu'),
            controller: _seatsController,
          ),
          const SizedBox(height: 16),
          const Text('Wybierz metodę:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _method,
            items: [
              "d'Hondt",
              "Sainte-Laguë",
              "Kwota Hare’a (metoda największych reszt)",
              "Kwota Hare’a (metoda najmniejszych reszt)",
            ].map((m) {
              return DropdownMenuItem<String>(value: m, child: Text(m));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _method = val;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculateSeats,
            child: const Text('Oblicz podział mandatów'),
          ),
          const SizedBox(height: 16),
          const Text('Wynik podziału mandatów:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildResultsTable(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------------
/// Widget "Rzeczywiste" – wczytuje dane z CSV
/// ----------------------------------------------------------
class RealElectionCalculatorTab extends StatefulWidget {
  const RealElectionCalculatorTab({Key? key}) : super(key: key);

  @override
  _RealElectionCalculatorTabState createState() =>
      _RealElectionCalculatorTabState();
}

class _RealElectionCalculatorTabState extends State<RealElectionCalculatorTab> {
  final List<int> _availableYears = [2001, 2005, 2007, 2011, 2015, 2019];
  int? _selectedYear;

  double _threshold = 5.0; // zwykły próg
  double _thresholdCoalition = 8.0; // próg dla koalicji

  // Nazwy partii znalezione w CSV (kolumny)
  List<String> _possibleParties = [];
  // Partie zwolnione z progu
  List<String> _exemptedParties = [];

  // Surowe dane CSV
  List<List<dynamic>> _csvRaw = [];

  // Wynik: okręg -> metoda -> partia -> mandaty
  Map<String, Map<String, Map<String, int>>> _results = {};

  /// Mapa: "1" -> 12, "2" -> 8, itd.
  final Map<String, int> seatsPerDistrict = {
    "1": 12,
    "2": 8,
    "3": 14,
    "4": 12,
    "5": 13,
    "6": 15,
    "7": 12,
    "8": 12,
    "9": 10,
    "10": 9,
    "11": 12,
    "12": 8,
    "13": 14,
    "14": 10,
    "15": 9,
    "16": 10,
    "17": 9,
    "18": 12,
    "19": 20,
    "20": 12,
    "21": 12,
    "22": 11,
    "23": 15,
    "24": 14,
    "25": 12,
    "26": 14,
    "27": 9,
    "28": 7,
    "29": 9,
    "30": 9,
    "31": 12,
    "32": 9,
    "33": 16,
    "34": 8,
    "35": 10,
    "36": 12,
    "37": 9,
    "38": 9,
    "39": 10,
    "40": 8,
    "41": 12
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Wybierz rok:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<int>(
            value: _selectedYear,
            hint: const Text("Rok"),
            items: _availableYears.map((y) {
              return DropdownMenuItem<int>(
                value: y,
                child: Text(y.toString()),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedYear = val;
                if (val != null) {
                  _loadCsv();
                }
              });
            },
          ),
          const SizedBox(height: 16),
          const Text("Próg wyborczy (%)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: ""),
            onChanged: (val) {
              final d = double.tryParse(val.replaceAll(',', '.'));
              if (d != null) setState(() => _threshold = d);
            },
          ),
          const SizedBox(height: 16),
          const Text("Próg dla koalicji (%)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: ""),
            onChanged: (val) {
              final d = double.tryParse(val.replaceAll(',', '.'));
              if (d != null) setState(() => _thresholdCoalition = d);
            },
          ),
          const SizedBox(height: 16),
          const Text("Partie zwolnione z progu (opcjonalne):",
              style: TextStyle(fontWeight: FontWeight.bold)),
          _buildExemptedPartiesWidget(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _calculateResults,
            child: const Text("Oblicz"),
          ),
          const SizedBox(height: 20),
          _buildResultsTable(),
        ],
      ),
    );
  }

  /// Wczytuje plik CSV
  Future<void> _loadCsv() async {
    if (_selectedYear == null) return;

    try {
      final filename =
          'wyniki_gl_na_listy_po_okregach_sejm_utf8_$_selectedYear.csv';
      final rawString = await rootBundle.loadString('Data/$filename');

      // Starsze lata często ','; nowsze – ';'
      final separator = (_selectedYear! < 2015) ? ',' : ';';

      final listData = const csv.CsvToListConverter().convert(
        rawString,
        fieldDelimiter: separator,
      );

      setState(() {
        _csvRaw = listData;
        _possibleParties = _extractPartyHeaders(listData);
        _exemptedParties.clear();
      });
    } catch (e) {
      debugPrint("Błąd wczytywania pliku CSV: $e");
      _csvRaw = [];
    }
  }

  /// Szuka kolumn, które zawierają "Komitet Wyborczy" lub "Koalicyjny" (nieważne wielkość liter).
  List<String> _extractPartyHeaders(List<List<dynamic>> data) {
    if (data.isEmpty) return [];
    final headers = data.first.map((e) => e.toString()).toList();

    return headers.where((colName) {
      final lower = colName.toLowerCase();
      return lower.contains("komitet wyborczy") || lower.contains("koalicyjny");
    }).toList();
  }

  /// Główna logika obliczeń
  void _calculateResults() {
    if (_csvRaw.isEmpty) return;

    final headerRow = _csvRaw.first.map((e) => e.toString()).toList();
    // Znajdź kolumnę z "Okręg"
    final districtIndex = headerRow.indexWhere(
      (col) => col.toLowerCase() == "okręg",
    );
    if (districtIndex < 0) {
      debugPrint("Nie znaleziono kolumny 'Okręg' w nagłówku CSV.");
      return;
    }

    // Mapa: "1" -> { "partiaX": 123, "partiaY": 456 }
    final Map<String, Map<String, double>> votesPerDistrict = {};

    for (var row in _csvRaw.skip(1)) {
      if (row.length <= districtIndex) continue;

      final districtNumber = row[districtIndex].toString();
      // Np. "1", "2", "3"...

      if (!votesPerDistrict.containsKey(districtNumber)) {
        votesPerDistrict[districtNumber] = {};
      }

      // Idź po nazwach partii
      for (var partyHeader in _possibleParties) {
        final colIndex = headerRow.indexOf(partyHeader);
        if (colIndex < 0 || colIndex >= row.length) continue;

        final value = row[colIndex]?.toString().trim() ?? '';
        final parsed = double.tryParse(value);
        final votes = parsed ?? 0.0;

        votesPerDistrict[districtNumber]![partyHeader] =
            (votesPerDistrict[districtNumber]![partyHeader] ?? 0) + votes;
      }
    }

    // Czyścimy stare wyniki
    _results.clear();

    // Pętla po okręgach
    votesPerDistrict.forEach((dist, partiesMap) {
      final seatsNum = seatsPerDistrict[dist] ?? 0;
      if (seatsNum <= 0) {
        debugPrint(
            "Ostrzeżenie: brak liczby mandatów w seatsPerDistrict dla okręgu $dist");
        return;
      }

      final totalVotes = partiesMap.values.fold(0.0, (a, b) => a + b);

      // Wyfiltrowane (przekroczyły próg)
      final Map<String, double> filtered = {};
      partiesMap.forEach((partyName, count) {
        final p = (totalVotes == 0) ? 0 : (count / totalVotes) * 100.0;
        final isCoalition = partyName.toLowerCase().contains("koalicyjny");

        final neededThreshold = isCoalition ? _thresholdCoalition : _threshold;

        if (_exemptedParties.contains(partyName) || p >= neededThreshold) {
          filtered[partyName] = count;
        }
      });

      if (filtered.isEmpty) {
        debugPrint("Okręg $dist: wszystkie partie poniżej progu.");
        return;
      }

      final qualifiedParties = filtered.keys.toList();
      final qualifiedVotes = filtered.values.toList();

      // Liczymy 4-5 metod na raz
      final districtResult = ElectionCalc.chooseMethod(
        qualifiedDictionary: qualifiedParties,
        numberOfVotes: qualifiedVotes,
        year: _selectedYear.toString(),
        seatsNum: seatsNum,
      );

      _results[dist] = districtResult;
    });

    setState(() {
      // odśwież UI
    });
  }

  /// Render tabeli z wynikami
  Widget _buildResultsTable() {
    if (_results.isEmpty) {
      return const Text(
        "",
        style: TextStyle(color: Colors.grey),
      );
    }

    // Zbierz wszystkie partie, które wystąpiły
    final allParties = <String>{};
    _results.values.forEach((methodMap) {
      methodMap.values.forEach((mapParties) {
        allParties.addAll(mapParties.keys);
      });
    });
    final allPartiesList = allParties.toList()..sort();

    // Budujemy wiersze:
    final rows = <DataRow>[];
    _results.forEach((dist, methodsMap) {
      methodsMap.forEach((methodName, seatsMap) {
        final cells = <DataCell>[];
        cells.add(DataCell(Text(dist))); // np. "1"
        cells.add(DataCell(Text(methodName))); // np. "d'Hondt"

        for (final p in allPartiesList) {
          final s = seatsMap[p] ?? 0;
          cells.add(DataCell(Text(s.toString())));
        }

        rows.add(DataRow(cells: cells));
      });
    });

    // Nagłówki:
    final columns = [
      const DataColumn(label: Text("Okręg")),
      const DataColumn(label: Text("Metoda")),
      ...allPartiesList.map((p) => DataColumn(label: Text(p))),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(columns: columns, rows: rows),
    );
  }

  /// Checkboxy do zwolnienia partii z progu
  Widget _buildExemptedPartiesWidget() {
    if (_possibleParties.isEmpty) {
      return const Text("");
    }

    return Column(
      children: _possibleParties.map((party) {
        return Row(
          children: [
            Checkbox(
              value: _exemptedParties.contains(party),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _exemptedParties.add(party);
                  } else {
                    _exemptedParties.remove(party);
                  }
                });
              },
            ),
            Expanded(child: Text(party)),
          ],
        );
      }).toList(),
    );
  }
}
