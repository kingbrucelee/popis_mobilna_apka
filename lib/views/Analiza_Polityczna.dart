import 'package:flutter/material.dart';
// Upewnij się, że import jest zgodny z Twoją strukturą katalogów:
import '../controllers/seatsCalculator.dart';

class View3 extends StatefulWidget {
  @override
  _View3State createState() => _View3State();
}

class _View3State extends State<View3> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Przykładowe dane okręgów
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
  };

  // Głosy w procentach bądź w ilości (w zależności od trybu)
  Map<String, dynamic> votesJson = {
    "Legnica": {
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
            children: [
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
          tabs: [
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
          _buildTabContent('Korelacje Wyborcze'),
          _buildTabContent('Prawo Benforda'),
        ],
      ),
    );
  }

  Widget _buildTabContent(String title) {
    return Center(
      child: Text('$title content here', style: TextStyle(fontSize: 14)),
    );
  }
}

/// Zakładka z kalkulatorem wyborczym
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
  String _type = "ilościowy"; // np. "ilościowy" albo "procentowy"
  String _method = "d'Hondta";
  late String _selectedDistrict;

  // Tymczasowe pola do UI, uzupełniane w _loadDistrictValues:
  double _pis = 0.0,
      _ko = 0.0,
      _td = 0.0,
      _lewica = 0.0,
      _konf = 0.0,
      _frequency = 0.0;
  int _seatsNum = 0;

  // Przechowujemy wynik kalkulacji
  Map<String, int> _resultSeats = {};

  @override
  void initState() {
    super.initState();
    // Domyślnie wybieramy pierwszy okręg z mapy:
    _selectedDistrict = widget.dataJson.keys.first;
    _loadDistrictValues(_selectedDistrict);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown z wyborem okręgu
          Text('Wybierz okręg:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                });
              }
            },
          ),
          Divider(),

          // Pola do wprowadzania liczby głosów:
          _buildNumberField('PiS', _pis, (val) {
            setState(() => _pis = val);
          }),
          _buildNumberField('KO', _ko, (val) {
            setState(() => _ko = val);
          }),
          _buildNumberField('Trzecia Droga', _td, (val) {
            setState(() => _td = val);
          }),
          _buildNumberField('Lewica', _lewica, (val) {
            setState(() => _lewica = val);
          }),
          _buildNumberField('Konfederacja', _konf, (val) {
            setState(() => _konf = val);
          }),

          // Frekwencja
          _buildNumberField('Frekwencja (np. 100000 głosów)', _frequency,
              (val) {
            setState(() => _frequency = val);
          }),

          // Liczba miejsc
          _buildSeatsField(),

          SizedBox(height: 16),

          // Metoda podziału:
          Text('Wybierz metodę:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _method,
            items: [
              "d'Hondta",
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

          SizedBox(height: 16),

          // Przycisk obliczania
          ElevatedButton(
            onPressed: _calculateSeats,
            child: Text('Oblicz podział mandatów'),
          ),

          SizedBox(height: 16),

          // Wyświetlanie wyniku
          Text(
            'Wynik podziału mandatów:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (_resultSeats.isNotEmpty)
            ..._resultSeats.entries.map((e) => Text('${e.key}: ${e.value}')),

          SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Ładuje wartości z widget.dataJson i widget.votesJson do pól tymczasowych
  void _loadDistrictValues(String district) {
    final distData = widget.dataJson[district];
    final distVotes = widget.votesJson[district];
    if (distData != null && distVotes != null) {
      setState(() {
        _pis = distVotes["PiS"]?.toDouble() ?? 0.0;
        _ko = distVotes["KO"]?.toDouble() ?? 0.0;
        _td = distVotes["Trzecia Droga"]?.toDouble() ?? 0.0;
        _lewica = distVotes["Lewica"]?.toDouble() ?? 0.0;
        _konf = distVotes["Konfederacja"]?.toDouble() ?? 0.0;
        _frequency = distData["Frekwencja"]?.toDouble() ?? 0.0;
        _seatsNum = distData["Miejsca do zdobycia"] ?? 0;
      });
    }
  }

  /// Zapisuje wprowadzone wartości z pól do widget.dataJson i widget.votesJson,
  /// a następnie wywołuje SeatsCalculatorSingleDistrict
  void _calculateSeats() {
    // Zaktualizuj głosy i frekwencję
    widget.votesJson[_selectedDistrict]["PiS"] = _pis;
    widget.votesJson[_selectedDistrict]["KO"] = _ko;
    widget.votesJson[_selectedDistrict]["Trzecia Droga"] = _td;
    widget.votesJson[_selectedDistrict]["Lewica"] = _lewica;
    widget.votesJson[_selectedDistrict]["Konfederacja"] = _konf;

    widget.dataJson[_selectedDistrict]["Frekwencja"] = _frequency;
    widget.dataJson[_selectedDistrict]["Miejsca do zdobycia"] = _seatsNum;

    // Wywołaj callbacki, aby przekazać zmiany wyżej (np. do View3)
    widget.onVotesJsonChanged(widget.votesJson);
    widget.onDataJsonChanged(widget.dataJson);

    // Oblicz mandaty
    final result = SeatsCalculatorSingleDistrict.chooseMethods(
      PiS: _pis,
      KO: _ko,
      TD: _td,
      Lewica: _lewica,
      Konf: _konf,
      Freq: _frequency,
      method: _method,
      seatsNum: _seatsNum,
    );

    setState(() {
      _resultSeats = {};
      if (result.containsKey("recivedVotes")) {
        // Wyświetlamy co zwrócił kalkulator
        _resultSeats = Map<String, int>.from(result["recivedVotes"]);
      }
    });
  }

  Widget _buildNumberField(
    String label,
    double initialValue,
    ValueChanged<double> onChanged,
  ) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      controller: TextEditingController(text: initialValue.toString()),
      onChanged: (val) {
        final parsed = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
        onChanged(parsed);
      },
    );
  }

  Widget _buildSeatsField() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Liczba mandatów w okręgu'),
      controller: TextEditingController(text: _seatsNum.toString()),
      onChanged: (val) {
        final parsed = int.tryParse(val) ?? 0;
        setState(() {
          _seatsNum = parsed;
        });
      },
    );
  }
}
