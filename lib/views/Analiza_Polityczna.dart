import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart' as csv;
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

// Kontrolery i klasy pomocnicze (Twoje autorskie)
import '../controllers/seatsCalculator.dart';
import '../controllers/electionCalc.dart';

// Tutaj importujemy plik z SejmAPI
import '../api_wrappers/clubs.dart'; // <-- zmień ścieżkę na właściwą

const Map<String, String> clubNameShortcuts = {
  'Klub Parlamentarny Prawo i Sprawiedliwość': 'PiS',
  'Klub Parlamentarny Koalicja Obywatelska - Platforma Obywatelska, Nowoczesna, Inicjatywa Polska, Zieloni':
      'KO',
  'Klub Parlamentarny Polskie Stronnictwo Ludowe - Trzecia Droga': 'PSL-TD',
  'Klub Parlamentarny Polska 2050 - Trzecia Droga': 'Polska2050-TD',
  'Koło Poselskie Razem': 'Razem',
  'Koalicyjny Klub Parlamentarny Lewicy (Nowa Lewica, PPS, Unia Pracy)':
      'Lewica',
  'Klub Poselski Konfederacja': 'Konfederacja',
};

/// Główny widget ekranu z zakładkami
class View3 extends StatefulWidget {
  const View3({Key? key}) : super(key: key);

  @override
  _View3State createState() => _View3State();
}

class _View3State extends State<View3> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int termNumber = 10;

  // Poprawiamy typ na List<List<Map<String, dynamic>>>
  List<List<Map<String, dynamic>>> coalitions = [];

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
    // ... pozostałe okręgi ...
  };

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
    // ... pozostałe okręgi ...
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Ładujemy koalicje na start
    _loadCoalitions();
  }

  void _loadCoalitions() async {
    // Wywołujemy SejmAPI().findMinimalCoalitions(...), jeżeli w Twoim API tak się to nazywa
    final fetchedCoalitions =
        await SejmAPI().findMinimalCoalitions(term: termNumber);
    setState(() {
      coalitions = fetchedCoalitions;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Główny build ekranu
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CHANGED: Dodaj padding w AppBar (lub użyj PreferredSize) żeby lekko "opuścić" napis
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('Analiza Polityczna'),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Wybór kadencji
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Kadencja sejmu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Nasz TermSelector
          TermSelector(
            initialTerm: termNumber,
            onTermChanged: (newTerm) {
              setState(() {
                termNumber = newTerm;
                _loadCoalitions(); // Odśwież dane dla nowej kadencji
              });
            },
          ),
          const SizedBox(height: 16),

          // --- Dodajemy TabBar tu, zamiast w bottomNavigationBar:
          TabBar(
            controller: _tabController,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Koalicje"),
              Tab(text: "Kalkulator"),
            ],
          ),

          // Rozwinięcie zakładek
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1) Zakładka "Potencjalne Koalicje"
                _buildPotentialCoalitionTab(),
                // 2) Zakładka "Kalkulator Wyborczy"
                _buildElectionCalculatorTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// -----------------------
  /// Zakładka 1: KOALICJE
  /// -----------------------
  Widget _buildPotentialCoalitionTab() {
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: SejmAPI().findMinimalCoalitions(term: termNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Błąd: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Brak danych'));
        }

        final fetchedCoalitions = snapshot.data ?? [];

        // Mapowanie danych do wyświetlenia w tabeli
        final coalitionData = fetchedCoalitions.map((coalition) {
          final totalMembers = coalition
              .map((club) => club['membersCount'] as int)
              .reduce((a, b) => a + b);

          final largestMembers = coalition
              .map((club) => club['membersCount'] as int)
              .reduce(math.max);

          final ratio =
              totalMembers > 0 ? (largestMembers / totalMembers) * 100.0 : 0.0;

          // Skracanie nazw klubów
          final clubNames = coalition.map((club) {
            final fullName = club['name'] as String;
            return clubNameShortcuts[fullName] ?? fullName;
          }).join(', ');

          return {
            'ProcentNajwiekszyKlub': ratio.toStringAsFixed(2),
            'Kluby': clubNames,
            'LacznaIloscPoslow': totalMembers,
            'IloscKlubow': coalition.length,
          };
        }).toList();

        return Column(
          children: [
            // Tabela
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: _buildDataTable(coalitionData),
                ),
              ),
            ),
            // Metryki
            _buildMetrics(coalitionData),
            // Selektor koalicji (np. do BottomSheet)
            _buildCoalitionSelector(context, fetchedCoalitions),
          ],
        );
      },
    );
  }

  /// Tabela z minimalnymi koalicjami
  Widget _buildDataTable(List<Map<String, dynamic>> coalitionData) {
    return DataTable(
      columnSpacing: 16.0,
      columns: const [
        DataColumn(
          label: Expanded(
            child: Text(
              '''Procent, jaki stanowi
największy klub''',
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Kluby',
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              '''Łączna ilość 
posłów''',
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Ilość klubów',
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
      rows: coalitionData.map((data) {
        return DataRow(cells: [
          DataCell(Center(
            child: Text(
              data['ProcentNajwiekszyKlub'],
              textAlign: TextAlign.center,
            ),
          )),
          DataCell(SizedBox(
            width: 200.0,
            child: Text(
              data['Kluby'],
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          )),
          DataCell(Center(
            child: Text(
              data['LacznaIloscPoslow'].toString(),
              textAlign: TextAlign.center,
            ),
          )),
          DataCell(Center(
            child: Text(
              data['IloscKlubow'].toString(),
              textAlign: TextAlign.center,
            ),
          )),
        ]);
      }).toList(),
    );
  }

  /// Metryki: liczba koalicji, min i max posłów
  Widget _buildMetrics(List<Map<String, dynamic>> coalitionData) {
    if (coalitionData.isEmpty) {
      return const SizedBox();
    }

    int totalCoalitions = coalitionData.length;
    int minPoslow = coalitionData
        .map((data) => data['LacznaIloscPoslow'] as int)
        .reduce(math.min);
    int maxPoslow = coalitionData
        .map((data) => data['LacznaIloscPoslow'] as int)
        .reduce(math.max);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricTile(
              'Ilość potencjalnych koalicji',
              totalCoalitions.toString(),
              fontSize: 4.0,
            ),
            _buildMetricTile(
              'Minimalna ilość posłów',
              minPoslow.toString(),
              fontSize: 4.0,
            ),
            _buildMetricTile(
              'Maksymalna ilość posłów',
              maxPoslow.toString(),
              fontSize: 4.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value,
      {required double fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  /// Dropdown do wyboru konkretnej koalicji i pokazania szczegółów (BottomSheet)
  Widget _buildCoalitionSelector(
    BuildContext context,
    List<List<Map<String, dynamic>>> potentialCoalitions,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            "Szczegóły Koalicji",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          DropdownButton<int>(
            items: List.generate(
              potentialCoalitions.length,
              (index) => DropdownMenuItem(
                value: index,
                child: Text('Koalicja nr ${index + 1}'),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                _showCoalitionDetails(context, potentialCoalitions[value]);
              }
            },
            hint: const Text("Wybierz koalicję"),
          ),
        ],
      ),
    );
  }

  /// BottomSheet z wykresem kołowym
  void _showCoalitionDetails(
    BuildContext context,
    List<Map<String, dynamic>> coalition,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(child: _buildPieChart(coalition)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> coalition) {
    final totalMembers = coalition.fold<int>(
      0,
      (sum, club) => sum + (club['membersCount'] as int),
    );

    final List<Color> expandedColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
      Colors.deepOrange,
      Colors.indigo,
      Colors.lightBlue,
      Colors.lime,
      Colors.deepPurple,
      Colors.yellowAccent,
      Colors.lightGreen,
    ];

    int colorIndex = 0;
    List<PieChartSectionData> pieData = coalition.map((club) {
      final double percentage = (club['membersCount'] / totalMembers) * 100;
      return PieChartSectionData(
        value: club['membersCount'].toDouble(),
        title: "${percentage.toStringAsFixed(1)}%",
        color: expandedColors[colorIndex++ % expandedColors.length],
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        badgePositionPercentageOffset: 1.5,
      );
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sections: pieData,
                  centerSpaceRadius: 40,
                  sectionsSpace: 3,
                  borderData: FlBorderData(show: false),
                  startDegreeOffset: 270,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: coalition.map((club) {
                final idx = coalition.indexOf(club);
                final color = expandedColors[idx % expandedColors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${club['name']} (${club['membersCount']} posłów)',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// -----------------------
  /// Zakładka 2: KALKULATOR
  /// -----------------------
  Widget _buildElectionCalculatorTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              children: [
                // 1) WŁASNE
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
                // 2) RZECZYWISTE
                const Center(child: Text("Tu będzie logika rzeczywista...")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget do wyboru kadencji (plus i minus)
class TermSelector extends StatefulWidget {
  final int initialTerm;
  final ValueChanged<int> onTermChanged;

  const TermSelector({
    Key? key,
    required this.initialTerm,
    required this.onTermChanged,
  }) : super(key: key);

  @override
  _TermSelectorState createState() => _TermSelectorState();
}

class _TermSelectorState extends State<TermSelector> {
  late int _currentTerm;

  @override
  void initState() {
    super.initState();
    _currentTerm = widget.initialTerm;
  }

  void _incrementTerm() {
    setState(() {
      _currentTerm++;
      widget.onTermChanged(_currentTerm);
    });
  }

  void _decrementTerm() {
    if (_currentTerm > 1) {
      setState(() {
        _currentTerm--;
        widget.onTermChanged(_currentTerm);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // CHANGED: Dodaj alignment: Alignment.center aby wyśrodkować tekst
        Container(
          width: 220,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center, // <-- To wyśrodkuje nasz numer kadencji
          child: Text(
            '$_currentTerm',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        // Minus button
        GestureDetector(
          onTap: _decrementTerm,
          child: Container(
            width: 70,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: const Icon(Icons.remove, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8.0),
        // Plus button
        GestureDetector(
          onTap: _incrementTerm,
          child: Container(
            width: 70,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// ----------------------------------------------------------
/// Widget ElectionCalculatorTab ("Własne" dane użytkownika)
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

  late String _selectedDistrict; // nazwa klucza z dataJson/votesJson

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
    // Domyślnie: pierwszy z okręgów dostępnych w dataJson
    _selectedDistrict = widget.dataJson.keys.first;

    _pisController = TextEditingController();
    _koController = TextEditingController();
    _tdController = TextEditingController();
    _lewicaController = TextEditingController();
    _konfController = TextEditingController();
    _frequencyController = TextEditingController();
    _seatsController = TextEditingController();

    // Wczytujemy wartości dla aktualnie wybranego okręgu
    _loadDistrictValues(_selectedDistrict);
    // Ustawiamy w TextEditingController
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
    // Pozwalamy na wpisywanie z przecinkiem
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

    // Jeśli mamy tryb procentowy, to suma musi dać 100
    if (_type == "procentowy" && (sumVotes - 100.0).abs() > 0.0001) {
      _showErrorDialog(
          "Suma procentów musi wynosić dokładnie 100% (obecnie: $sumVotes).");
      return;
    }

    // Zamiana z procentów -> wartości "w sztukach" głosów
    double actualPis = _type == "procentowy" ? (_pis / 100) * _frequency : _pis;
    double actualKo = _type == "procentowy" ? (_ko / 100) * _frequency : _ko;
    double actualTd = _type == "procentowy" ? (_td / 100) * _frequency : _td;
    double actualLewica =
        _type == "procentowy" ? (_lewica / 100) * _frequency : _lewica;
    double actualKonf = _type == "procentowy"
        ? (_konfederacja / 100) * _frequency
        : _konfederacja;

    // Zapisujemy do głównego modelu (przekazanego z View3), aby przechowywać stan
    widget.votesJson[_selectedDistrict]["PiS"] = actualPis;
    widget.votesJson[_selectedDistrict]["KO"] = actualKo;
    widget.votesJson[_selectedDistrict]["Trzecia Droga"] = actualTd;
    widget.votesJson[_selectedDistrict]["Lewica"] = actualLewica;
    widget.votesJson[_selectedDistrict]["Konfederacja"] = actualKonf;

    widget.dataJson[_selectedDistrict]["Frekwencja"] = _frequency;
    widget.dataJson[_selectedDistrict]["Miejsca do zdobycia"] = _seatsNum;

    widget.onVotesJsonChanged(widget.votesJson);
    widget.onDataJsonChanged(widget.dataJson);

    // Tu używasz swojej logiki liczenia mandatów:
    final result = SeatsCalculator.chooseMethods(
      PiS: actualPis,
      KO: actualKo,
      TD: actualTd,
      Lewica: actualLewica,
      Konfederacja: actualKonf,
      Freq: _frequency,
      seatsNum: _seatsNum,
      method: _method,
    );

    // Zakładamy, że result[0] to Map<String,int> z liczbą mandatów
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
        "Brak obliczeń",
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

  /// Dropdown z wyborem okręgu
  Widget _buildDistrictSelector() {
    final keys = widget.dataJson.keys.toList();
    return DropdownButton<String>(
      value: _selectedDistrict,
      items: keys.map((dist) {
        return DropdownMenuItem(
          value: dist,
          child: Text(dist),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedDistrict = val;
            // Wczytujemy wartości z modelu
            _loadDistrictValues(val);
            _setControllersValues();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Wybór okręgu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Okręg: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildDistrictSelector(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("Typ danych: "),
              DropdownButton<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                    value: "ilościowy",
                    child: Text("ilościowy"),
                  ),
                  DropdownMenuItem(
                    value: "procentowy",
                    child: Text("procentowy"),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _type = val;
                    });
                  }
                },
              ),
            ],
          ),
          const Divider(),
          _buildNumberField(label: 'PiS', controller: _pisController),
          _buildNumberField(label: 'KO', controller: _koController),
          _buildNumberField(label: 'Trzecia Droga', controller: _tdController),
          _buildNumberField(label: 'Lewica', controller: _lewicaController),
          _buildNumberField(label: 'Konfederacja', controller: _konfController),
          const SizedBox(height: 8),
          _buildNumberField(
              label: _type == "procentowy"
                  ? 'Frekwencja (liczba wszystkich głosów)'
                  : 'Frekwencja (łączna liczba uprawnionych?)',
              controller: _frequencyController),
          _buildNumberField(
              label: 'Liczba mandatów w okręgu', controller: _seatsController),
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
          const Text(
            'Wynik podziału mandatów:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildResultsTable(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
