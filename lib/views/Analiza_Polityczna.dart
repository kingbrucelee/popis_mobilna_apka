// views/Analiza_Polityczna.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart' as csv;
import 'dart:math' as math;

import '../controllers/seatsCalculator.dart';
import '../controllers/electionCalc.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

/// Główny widget ekranu z zakładkami
class View3 extends StatefulWidget {
  const View3({Key? key}) : super(key: key);

  @override
  _View3State createState() => _View3State();
}

class _View3State extends State<View3> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  Map<String, dynamic> votesJson = {
    // Struktura równoległa do dataJson,
    // tutaj wstępnie 0.0 (mogą być procenty albo wartości)
    // ...
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
    // ... tu powinny być pozostałe okręgi analogicznie
    // (zachowując strukturę).
    // Dla uproszczenia skracam, ale w praktyce wypełnij całość:
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
          _buildTabContent('Potencjalne Koalicje'),
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
    // Wczytujemy najpierw wartości z pól
    _updateTempValuesFromControllers();

    if (_seatsNum <= 0) {
      _showErrorDialog("Liczba mandatów musi być większa niż 0.");
      return;
    }

    // sprawdzamy, czy łączne głosy > 0
    final sumVotes = _pis + _ko + _td + _lewica + _konfederacja;
    if (sumVotes == 0) {
      _showErrorDialog("Wprowadź co najmniej jedną partię z głosami > 0.");
      return;
    }

    // jeśli tryb procentowy, to suma procentów powinna = 100
    if (_type == "procentowy") {
      if ((sumVotes - 100.0).abs() > 0.0001) {
        _showErrorDialog(
            "Suma procentów musi wynosić dokładnie 100% (obecnie: $sumVotes).");
        return;
      }
    }

    // Obliczamy rzeczywistą liczbę głosów
    double totalVotes = _frequency; // w trybie procentowym = to, co wpisał user
    double actualPis = _type == "procentowy" ? (_pis / 100) * totalVotes : _pis;
    double actualKo = _type == "procentowy" ? (_ko / 100) * totalVotes : _ko;
    double actualTd = _type == "procentowy" ? (_td / 100) * totalVotes : _td;
    double actualLewica =
        _type == "procentowy" ? (_lewica / 100) * totalVotes : _lewica;
    double actualKonf = _type == "procentowy"
        ? (_konfederacja / 100) * totalVotes
        : _konfederacja;

    // Zapisz do map
    widget.votesJson[_selectedDistrict]["PiS"] = actualPis;
    widget.votesJson[_selectedDistrict]["KO"] = actualKo;
    widget.votesJson[_selectedDistrict]["Trzecia Droga"] = actualTd;
    widget.votesJson[_selectedDistrict]["Lewica"] = actualLewica;
    widget.votesJson[_selectedDistrict]["Konfederacja"] = actualKonf;

    widget.dataJson[_selectedDistrict]["Frekwencja"] = _frequency;
    widget.dataJson[_selectedDistrict]["Miejsca do zdobycia"] = _seatsNum;

    widget.onVotesJsonChanged(widget.votesJson);
    widget.onDataJsonChanged(widget.dataJson);

    // WOŁAMY METODĘ seatsCalculator (z pliku seatsCalculator.dart)
    final result = SeatsCalculator.chooseMethods(
      PiS: actualPis,
      KO: actualKo,
      TD: actualTd,
      Lewica: actualLewica,
      Konfederacja: actualKonf,
      Freq: actualPis + actualKo + actualTd + actualLewica + actualKonf,
      seatsNum: _seatsNum,
      method: _method,
    );

    // result to lista 3 elementów: [Map<String,int>, Set<String>, Set<String>]
    final seatsMap = result[0] as Map<String, int>;
    final differencesNext = result[1] as Set<String>;
    final differencesPrev = result[2] as Set<String>;

    setState(() {
      _resultSeats = seatsMap;
    });

    // Wyświetl w dialogu
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Wynik podziału mandatów"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in seatsMap.entries)
                  Text("${e.key}: ${e.value} mandatów"),
                if (differencesNext.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Przy (+1) mandacie zmieniłby się przydział dla: ${differencesNext.join(", ")}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                if (differencesPrev.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Przy (-1) mandacie zmieniłby się przydział dla: ${differencesPrev.join(", ")}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
              DropdownMenuItem(
                value: "ilościowy",
                child: Text("Ilościowy"),
              ),
              DropdownMenuItem(
                value: "procentowy",
                child: Text("Procentowy"),
              ),
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
          _buildNumberField(
            label: 'PiS (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _pisController,
          ),
          _buildNumberField(
            label: 'KO (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _koController,
          ),
          _buildNumberField(
            label: 'Trzecia Droga (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _tdController,
          ),
          _buildNumberField(
            label: 'Lewica (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _lewicaController,
          ),
          _buildNumberField(
            label: 'Konfederacja (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _konfController,
          ),
          _buildNumberField(
            label: 'Frekwencja (%)',
            controller: _frequencyController,
          ),
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
              return DropdownMenuItem<String>(
                value: m,
                child: Text(m),
              );
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
          if (_resultSeats.isNotEmpty)
            ..._resultSeats.entries.map((e) => Text('${e.key}: ${e.value}')),
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
  double _threshold = 5.0;
  double _thresholdCoalition = 8.0;

  List<String> _possibleParties = [];
  List<String> _exemptedParties = [];
  List<List<dynamic>> _csvRaw = [];
  Map<String, Map<String, int>> _results = {};

  /// Wczytuje plik CSV dla wybranego roku
  Future<void> _loadCsv() async {
    if (_selectedYear == null) return;

    String filename =
        'wyniki_gl_na_listy_po_okregach_sejm_utf8_$_selectedYear.csv';

    try {
      final rawString = await rootBundle.loadString('Data/$filename');
      List<List<dynamic>> listData = const csv.CsvToListConverter().convert(
        rawString,
        fieldDelimiter: _selectedYear! < 2015 ? ',' : ';',
      );

      setState(() {
        _csvRaw = listData;
        _possibleParties = _csvRaw.isNotEmpty
            ? _csvRaw.first
                .map((e) => e.toString())
                .where((header) =>
                    header.contains("Komitet") || header.contains("KOMITET"))
                .toList()
            : [];
        _exemptedParties.clear();
      });
    } catch (e) {
      print("Błąd wczytywania CSV: $e");
    }
  }

  void _calculateResults() {
    if (_csvRaw.isEmpty || _selectedYear == null) return;

    // Przekształcamy wiersze CSV na listę obiektów CsvRow z pliku electionCalc.dart
    final csvData = _csvRaw
        .skip(1) // pomijamy nagłówek
        .map((row) {
      final rowMap = <String, double>{};
      for (int i = 0; i < _csvRaw.first.length; i++) {
        final header = _csvRaw.first[i].toString();
        if (row.length > i && double.tryParse(row[i].toString()) != null) {
          rowMap[header] = double.parse(row[i].toString());
        }
      }
      return CsvRow(rowMap);
    }).toList();

    final calculation = ElectionCalc.calculateVotesFromCsv(
      csvData: csvData,
      threshold: _threshold,
      coalitionThreshold: _thresholdCoalition,
      exemptedParties: _exemptedParties,
    );

    final allVotes = calculation["allVotes"] as double;
    final qualifiedParties = calculation["qualifiedParties"] as List<String>;
    final receivedVotes = calculation["receivedVotes"] as List<double>;

    // Liczymy 460 mandatów
    final seatsResults = ElectionCalc.chooseMethod(
      qualifiedDictionary: qualifiedParties,
      numberOfVotes: receivedVotes,
      year: _selectedYear.toString(),
      seatsNum: 460,
    );

    setState(() {
      _results = seatsResults;
    });
  }

  Widget _buildResultsTable() {
    if (_results.isEmpty) {
      return const Text(
        "Brak wyników. Wypełnij dane i kliknij 'Oblicz'.",
        style: TextStyle(color: Colors.grey),
      );
    }

    final List<String> methods = _results.keys.toList();
    final List<String> parties = _results[methods.first]!.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text("Metoda")),
          ...parties.map((party) => DataColumn(label: Text(party))),
        ],
        rows: methods.map((method) {
          return DataRow(cells: [
            DataCell(Text(method)),
            ...parties.map((party) {
              return DataCell(Text(_results[method]![party].toString()));
            }).toList(),
          ]);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Wybierz rok:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<int>(
            value: _selectedYear,
            hint: const Text("Wybierz rok"),
            items: _availableYears.map((y) {
              return DropdownMenuItem<int>(
                value: y,
                child: Text(y.toString()),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedYear = val;
                if (val != null) _loadCsv();
              });
            },
          ),
          const SizedBox(height: 16),
          const Text("Próg wyborczy (%)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: "np. 5.0"),
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
            decoration: const InputDecoration(hintText: "np. 8.0"),
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

  Widget _buildExemptedPartiesWidget() {
    if (_possibleParties.isEmpty) {
      return const Text("Brak dostępnych partii. Wczytaj plik CSV.");
    }

    return Column(
      children: _possibleParties.map((partyName) {
        return Row(
          children: [
            Checkbox(
              value: _exemptedParties.contains(partyName),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _exemptedParties.add(partyName);
                  } else {
                    _exemptedParties.remove(partyName);
                  }
                });
              },
            ),
            Expanded(child: Text(partyName)),
          ],
        );
      }).toList(),
    );
  }
}

/// -----------------------------------------
///   Zakładka / pod-widok: DhontAllPolandTab
///   (przykład, jak zsumować wyniki z CSV)
/// -----------------------------------------
class DhontAllPolandTab extends StatefulWidget {
  const DhontAllPolandTab({Key? key}) : super(key: key);

  @override
  State<DhontAllPolandTab> createState() => _DhontAllPolandTabState();
}

class _DhontAllPolandTabState extends State<DhontAllPolandTab> {
  /// Przykładowa lista mandatów (dla 41 okręgów)
  final List<int> initialSeats = [
    12,
    8,
    14,
    12,
    13,
    15,
    12,
    12,
    10,
    9,
    12,
    8,
    14,
    10,
    9,
    10,
    9,
    12,
    20,
    12,
    12,
    11,
    15,
    14,
    12,
    14,
    9,
    7,
    9,
    9,
    12,
    9,
    16,
    8,
    10,
    12,
    9,
    9,
    10,
    8,
    12
  ];

  List<List<int>> votes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  /// Ładowanie pliku CSV z assets (przykład)
  Future<void> _loadCsvData() async {
    try {
      final data = await rootBundle.loadString(
        'Data/wyniki_gl_na_listy_po_okregach_sejm_utf8_2001.csv',
      );

      final List<List<dynamic>> csvData =
          const csv.CsvToListConverter().convert(data);

      // Przykładowe przetworzenie: pomijamy pierwszy wiersz i pierwszą kolumnę
      votes = csvData
          .skip(1) // Pomijamy nagłówek
          .map((row) => row
              .skip(1) // Pomijamy pierwszą kolumnę
              .map((val) => int.tryParse(val.toString()) ?? 0)
              .toList())
          .toList();
    } catch (e) {
      debugPrint("Błąd wczytywania CSV: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  /// Przykładowa modyfikacja liczby mandatów w zależności od roku
  List<int> _adjustSeats(List<int> seats, int year) {
    if (year <= 2007) {
      seats[12] -= 1;
      seats[13] -= 1;
      seats[18] -= 1;
      seats[19] -= 1;
      seats[20] += 1;
      seats[23] += 1;
      seats[28] += 1;
      seats[40] += 1;

      if (year <= 2001) {
        seats[1] += 1;
        seats[8] += 1;
        seats[11] -= 1;
        seats[12] -= 1;
        seats[14] += 1;
        seats[19] -= 1;
        seats[30] += 1;
        seats[34] -= 1;
      }
    }
    return seats;
  }

  /// Prosty algorytm d’Hondta na łącznych głosach ze wszystkich okręgów
  List<int> _calculateDhontForAllRegions(
      List<List<int>> votes, int totalSeats) {
    if (votes.isEmpty) return [];

    // Suma głosów dla każdej partii (załóżmy kolumny = partie)
    List<int> totalVotes = List.filled(votes[0].length, 0);
    for (List<int> regionVotes in votes) {
      for (int i = 0; i < regionVotes.length; i++) {
        totalVotes[i] += regionVotes[i];
      }
    }

    // Sama metoda d’Hondta
    List<int> seatDistribution = List.filled(totalVotes.length, 0);

    for (int s = 0; s < totalSeats; s++) {
      // Szukamy indeksu partii z najwyższą wartością “głosy/(zdobyte+1)”
      int maxIndex = 0;
      double maxValue = 0;

      for (int i = 0; i < totalVotes.length; i++) {
        double current = totalVotes[i] / (seatDistribution[i] + 1).toDouble();
        if (current > maxValue) {
          maxValue = current;
          maxIndex = i;
        }
      }

      seatDistribution[maxIndex]++;
    }

    return seatDistribution;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    int year = 2001;
    // Kopiujemy listę, by nie modyfikować oryginału w locie
    List<int> seats = _adjustSeats(List.from(initialSeats), year);
    int totalSeats = seats.reduce((a, b) => a + b);

    // Wywołanie metody d’Hondta
    List<int> results = _calculateDhontForAllRegions(votes, totalSeats);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Metoda d’Hondta – Wyniki ogólnokrajowe (2001)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          DataTable(
            columns: List.generate(
              results.length,
              (index) => DataColumn(
                label: Text('Partia ${index + 1}'),
              ),
            ),
            rows: [
              DataRow(
                cells: results
                    .map((mandaty) => DataCell(Text('$mandaty')))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ----------------------------------------------------------------------
///                DODANY KOD Z DRUGIEGO PLIKU ("VoteCalculator")
/// ----------------------------------------------------------------------
/// Jeśli wolisz, możesz przenieść tę klasę do osobnego pliku w folderze
/// `controllers/` i stamtąd zaimportować (`import 'voteCalculator.dart';`).
/// ----------------------------------------------------------------------

class VoteCalculator {
  Future<Map<String, dynamic>> calculateVotes(
    int votesNeeded,
    int votesNeededForCoalition,
    String year,
  ) async {
    String sep = ";";
    if (["2011", "2007", "2005", "2001"].contains(year)) {
      sep = ",";
    }
    String yearSuffix = "_$year";
    if (year == "_2023") {
      yearSuffix = "";
    }

    String filePath =
        'assets/Data/wyniki_gl_na_listy_po_okregach_sejm_utf8$yearSuffix.csv';
    String csvData = await rootBundle.loadString(filePath);
    List<List<dynamic>> csvTable = csv.CsvToListConverter(
      fieldDelimiter: sep,
      eol: '\n',
    ).convert(csvData);

    // Zakładamy, że pierwszy wiersz to nagłówki
    List<String> headers =
        csvTable.first.map((header) => header.toString()).toList();
    List<Map<String, dynamic>> data =
        csvTable.skip(1).map((row) => Map.fromIterables(headers, row)).toList();

    Map<String, double> votes = {"Frekwencja": 0.0};
    List<String> clubsWithSeats = [];
    List<int> receivedVotes = [];

    // Inicjalizacja partii
    for (var key in headers) {
      if (key.toUpperCase().contains("KOMITET")) {
        votes[key] = 0.0;
      }
    }

    // Sumowanie głosów
    for (var district in data) {
      for (var key in headers) {
        if (key.toUpperCase().contains("KOMITET")) {
          votes[key] = (votes[key] ?? 0.0) + (district[key] ?? 0.0);
        }
      }
      int totalVotes = district[
              "Liczba głosów ważnych oddanych łącznie na wszystkie listy kandydatów"] ??
          0;
      receivedVotes.add(totalVotes);
      votes["Frekwencja"] =
          (votes["Frekwencja"] ?? 0.0) + totalVotes.toDouble();
    }

    // Obliczanie procentów
    votes.forEach((key, value) {
      if (key != "Frekwencja") {
        double percentage = (value * 100) / (votes["Frekwencja"] ?? 1);
        // Warunek: >= próg dla partii, a jeśli w nazwie "koalicyjny" – to >= próg dla koalicji
        bool isCoalition = key.toUpperCase().contains("KOALICYJNY");
        if (percentage >= votesNeeded &&
            (!isCoalition || percentage >= votesNeededForCoalition)) {
          clubsWithSeats.add(key);
        }
      }
    });

    return {
      "ClubsWithSeats": clubsWithSeats,
      "Votes": votes,
      "ReceivedVotes": receivedVotes,
    };
  }

  Future<Map<String, Map<String, int>>> chooseMethod(
    List<String> qualifiedDictionary,
    List<int> numberOfVotes,
    String year,
  ) async {
    Map<String, int> seatDict = {};
    Map<String, int> voteDict = {};
    Map<String, int> seatDictAll = {};

    if (qualifiedDictionary.isEmpty) {
      return {};
    }

    // Ustalenie separatora
    String sep = ";";
    if (["2011", "2007", "2005", "2001"].contains(year)) {
      sep = ",";
    }
    String yearSuffix = "_$year";
    if (year == "_2023") {
      yearSuffix = "";
    }

    String filePath =
        'Data/wyniki_gl_na_listy_po_okregach_sejm_utf8$yearSuffix.csv';
    String csvData = await rootBundle.loadString(filePath);
    List<List<dynamic>> csvTable = csv.CsvToListConverter(
      fieldDelimiter: sep,
      eol: '\n',
    ).convert(csvData);

    List<String> headers =
        csvTable.first.map((header) => header.toString()).toList();
    List<Map<String, dynamic>> data =
        csvTable.skip(1).map((row) => Map.fromIterables(headers, row)).toList();

    for (var element in qualifiedDictionary) {
      seatDict[element] = 0;
      voteDict[element] = 0;
      seatDictAll[element] = 0;
    }

    // Przygotowujemy mapę metod
    Map<String, Map<String, int>> methodDict = {
      "dhont": {},
      "Zmodyfikowany Sainte-Laguë": {},
      "Sainte-Laguë": {},
      "Kwota Kwota Hare’a (metoda największych reszt)": {},
      "Kwota Hare’a (metoda najmniejszych reszt)": {},
    };

    // Lista mandatów (41 okręgów)
    List<int> seats = [
      12,
      8,
      14,
      12,
      13,
      15,
      12,
      12,
      10,
      9,
      12,
      8,
      14,
      10,
      9,
      10,
      9,
      12,
      20,
      12,
      12,
      11,
      15,
      14,
      12,
      14,
      9,
      7,
      9,
      9,
      12,
      9,
      16,
      8,
      10,
      12,
      9,
      9,
      10,
      8,
      12
    ];

    // Dostosowanie liczby mandatów w zależności od roku
    int yearInt = int.tryParse(year) ?? 0;
    if (yearInt <= 2007) {
      seats[12] -= 1;
      seats[13] -= 1;
      seats[18] -= 1;
      seats[19] -= 1;
      seats[20] += 1;
      seats[23] += 1;
      seats[28] += 1;
      seats[40] += 1;
      if (yearInt <= 2001) {
        seats[1] += 1;
        seats[8] += 1;
        seats[11] -= 1;
        seats[12] -= 1;
        seats[14] += 1;
        seats[19] -= 1;
        seats[30] += 1;
        seats[34] -= 1;
      }
    }

    int district = 0;

    // Iteracja po wierszach (okręgach)
    for (var row in data) {
      // Wypełniamy voteDict tylko partiami z qualifiedDictionary
      for (var key in voteDict.keys) {
        voteDict[key] = (row[key] ?? 0).toInt();
      }

      // 1) d’Hondt
      Map<String, int> tempDictDhont = Map.from(seatDict);
      Map<String, int> receivedSeatsDhont =
          dhont(tempDictDhont, voteDict, seats[district]);
      receivedSeatsDhont.forEach((key, value) {
        methodDict["dhont"]![key] = (methodDict["dhont"]![key] ?? 0) + value;
      });

      // 2) Sainte-Laguë
      Map<String, int> tempDictSainte = Map.from(seatDict);
      Map<String, int> receivedSeatsSainte =
          sainteLague(tempDictSainte, voteDict, seats[district]);
      receivedSeatsSainte.forEach((key, value) {
        methodDict["Sainte-Laguë"]![key] =
            (methodDict["Sainte-Laguë"]![key] ?? 0) + value;
      });

      // 3) Kwota Hare’a (największe reszty)
      Map<String, int> tempDictHareDrop = Map.from(seatDict);
      Map<String, int> receivedSeatsHareDrop = hareDrop(
        tempDictHareDrop,
        voteDict,
        seats[district],
        numberOfVotes[district],
        true,
      );
      receivedSeatsHareDrop.forEach((key, value) {
        methodDict["Kwota Kwota Hare’a (metoda największych reszt)"]![key] =
            (methodDict["Kwota Kwota Hare’a (metoda największych reszt)"]![
                        key] ??
                    0) +
                value;
      });

      // 4) Kwota Hare’a (najmniejsze reszty)
      Map<String, int> tempDictHareMin = Map.from(seatDict);
      Map<String, int> receivedSeatsHareMin = hareDrop(
        tempDictHareMin,
        voteDict,
        seats[district],
        numberOfVotes[district],
        false,
      );
      receivedSeatsHareMin.forEach((key, value) {
        methodDict["Kwota Hare’a (metoda najmniejszych reszt)"]![key] =
            (methodDict["Kwota Hare’a (metoda najmniejszych reszt)"]![key] ??
                    0) +
                value;
      });

      // 5) Zmodyfikowany Sainte-Laguë
      Map<String, int> tempDictModifiedSainte = Map.from(seatDict);
      Map<String, int> receivedSeatsModifiedSainte = modifiedSainteLague(
        tempDictModifiedSainte,
        voteDict,
        seats[district],
      );
      receivedSeatsModifiedSainte.forEach((key, value) {
        methodDict["Zmodyfikowany Sainte-Laguë"]![key] =
            (methodDict["Zmodyfikowany Sainte-Laguë"]![key] ?? 0) + value;
      });

      district++;
    }

    return methodDict;
  }

  Map<String, int> modifiedSainteLague(
    Map<String, int> seatsDict,
    Map<String, int> voteDict,
    int seatsNum,
  ) {
    Map<String, double> voteDict2 =
        voteDict.map((k, v) => MapEntry(k, v.toDouble()));
    for (int i = 0; i < seatsNum; i++) {
      String maxParty =
          voteDict2.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;

      if (seatsDict[maxParty] == 1) {
        voteDict2[maxParty] = voteDict[maxParty]! / 1.4;
      } else {
        voteDict2[maxParty] = voteDict[maxParty]! /
            (2 * (seatsDict[maxParty]! - 1) + 1).toDouble();
      }
    }
    return seatsDict;
  }

  Map<String, int> sainteLague(
    Map<String, int> seatsDict,
    Map<String, int> voteDict,
    int seatsNum,
  ) {
    Map<String, double> voteDict2 =
        voteDict.map((k, v) => MapEntry(k, v.toDouble()));
    for (int i = 0; i < seatsNum; i++) {
      String maxParty =
          voteDict2.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;

      voteDict2[maxParty] =
          voteDict[maxParty]! / (2 * seatsDict[maxParty]! + 1).toDouble();
    }
    return seatsDict;
  }

  Map<String, int> dhont(
    Map<String, int> seatsDict,
    Map<String, int> voteDict,
    int seatsNum,
  ) {
    Map<String, double> voteDict2 =
        voteDict.map((k, v) => MapEntry(k, v.toDouble()));
    for (int i = 0; i < seatsNum; i++) {
      String maxParty =
          voteDict2.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
      voteDict2[maxParty] =
          voteDict[maxParty]! / (seatsDict[maxParty]! + 1).toDouble();
    }
    return seatsDict;
  }

  Map<String, int> hareDrop(
    Map<String, int> seatsDict,
    Map<String, int> voteDict,
    int seatsNum,
    int freq, [
    bool biggest = true,
  ]) {
    Map<String, double> voteDict2 = voteDict.map(
        (k, v) => MapEntry(k, (v.toDouble() * seatsNum) / (freq.toDouble())));

    // Przydzielanie mandatów na podstawie kwoty Hare'a
    voteDict2.forEach((key, value) {
      seatsDict[key] = value.floor();
    });

    int remainingSeats = seatsNum -
        seatsDict.values.fold(0, (previous, current) => previous + current);

    if (remainingSeats == 0) {
      return seatsDict;
    }

    // Przydzielanie pozostałych mandatów
    if (biggest) {
      for (int i = 0; i < remainingSeats; i++) {
        String maxParty =
            voteDict2.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        seatsDict[maxParty] = (seatsDict[maxParty] ?? 0) + 1;
        // Wyłącz tę partię z dalszego przydziału
        voteDict2[maxParty] = 0.0;
      }
    } else {
      for (int i = 0; i < remainingSeats; i++) {
        String minParty =
            voteDict2.entries.reduce((a, b) => a.value < b.value ? a : b).key;
        seatsDict[minParty] = (seatsDict[minParty] ?? 0) + 1;
        // Wyłącz tę partię z dalszego przydziału
        voteDict2[minParty] = double.infinity;
      }
    }
    return seatsDict;
  }
}
