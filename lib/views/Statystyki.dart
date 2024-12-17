// Added code start
import 'package:flutter/material.dart';
import '../api_wrappers/committees.dart';
import '../models/mp.dart'; // Dodany import modelu Mp
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class MyModel {}

class MyController {
  final MyModel model;
  MyController(this.model);
}
// Added code end

class View1 extends StatefulWidget {
  @override
  _View1State createState() => _View1State();
}

class _View1State extends State<View1> with TickerProviderStateMixin {
  final MyModel _model = MyModel();
  late MyController _controller = MyController(_model);

  final CommitteeService service = CommitteeService();

  int _value = 10;
  bool _isLoadingCommittees = false;
  List<dynamic> _committees = [];
  String _selectedCommittee = "Wybierz komisje";
  Map<String, dynamic>? _committeeStats;
  Map<String, List<String>> _clubsButBetter = {};
  String _selectedStat = "Wybierz typ statystyki";

  late TabController _tabController;
  late TabController _innerTabController;

  // Dla zakładki Posłowie:
  int _poslowieTermNumber = 10;
  String _selectedMpStat = "brak";
  List<Mp> _mpsList = []; // Lista posłów jako obiekty Mp
  List<String> _mpNames = [];
  String _selectedMp = "";
  List<Map<String, dynamic>> _historyOfMp = [];
  bool _isLoadingPoslowieData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _innerTabController = TabController(length: 2, vsync: this);

    _loadMpsData(_poslowieTermNumber); // Załaduj posłów
    _loadCommittees(); // Automatyczne załadowanie komisji
  }

  @override
  void dispose() {
    _tabController.dispose();
    _innerTabController.dispose();
    super.dispose();
  }

  Mp? _findMpByString(String val) {
    for (final mp in _mpsList) {
      if ("${mp.firstName} ${mp.lastName}" == val) {
        return mp;
      }
    }
    return null;
  }

  Future<void> _loadCommittees() async {
    setState(() {
      _isLoadingCommittees = true;
      _committees = [];
      _selectedCommittee = "Wybierz komisje";
    });
    try {
      final data = await service.getCommittees(_value);
      setState(() {
        _committees = data;
        _isLoadingCommittees = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCommittees = false;
      });
    }
  }

  List<int> _committeeAges = [];

  Future<void> _loadCommitteeStats() async {
    String? code;
    if (_selectedCommittee == "Wybierz komisje") {
      code = null;
    } else {
      final parts = _selectedCommittee.split("-");
      if (parts.length > 1) {
        code = parts.last.trim();
      } else {
        code = null;
      }
    }

    try {
      final stats = await service.getCommitteeStats(_value, code: code);
      setState(() {
        _committeeStats = stats;
        _clubsButBetter = Map<String, List<String>>.from(stats['clubs']);
      });

      final agesResult =
          await service.getCommitteeMemberAges(_clubsButBetter, term: _value);
      final Map<String, List<int>> mpsAgeMap =
          Map<String, List<int>>.from(agesResult['MPsAge']);
      List<int> allAges = [];
      mpsAgeMap.values.forEach((list) => allAges.addAll(list));

      setState(() {
        _committeeAges = allAges;
      });
    } catch (e) {
      // Obsługa błędów jeśli potrzeba
    }
  }

  Future<void> _loadMpsData(int term) async {
    setState(() {
      _isLoadingPoslowieData = true;
    });
    try {
      final mps = await service.getMps(term); // Pobieranie listy posłów
      setState(() {
        _mpsList = mps;
        _mpNames =
            _mpsList.map((mp) => "${mp.firstName} ${mp.lastName}").toList();
        if (_mpNames.isNotEmpty) {
          _selectedMp = _mpNames.first;
          _loadMpHistory(
              _mpsList.first, term); // Załaduj historię pierwszego posła
        }
        _isLoadingPoslowieData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPoslowieData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas ładowania posłów: $e')),
      );
    }
  }

  Widget _buildMpVotesChart(Mp mp) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: mp.numberOfVotes.toDouble() + 1000,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: mp.numberOfVotes.toDouble(),
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                )
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text("Głosy", style: TextStyle(fontSize: 12));
                  }),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Future<void> _loadMpHistory(Mp mp, int term) async {
    setState(() {
      _isLoadingPoslowieData = true;
    });
    try {
      final history = [
        {
          "Kadencja": term,
          "Klub": mp.club,
          "Okrąg": mp.districtName,
          "Województwo": mp.voivodeship,
          "Edukacja": mp.educationLevel,
          "Uzyskane głosy": mp.numberOfVotes,
          "Profesja": mp.profession ?? "Brak",
        },
      ];

      setState(() {
        _historyOfMp = history;
        _isLoadingPoslowieData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPoslowieData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas ładowania historii posła: $e')),
      );
    }
  }

  Widget _buildKomisjeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kadencja sejmu',
                  style: TextStyle(fontSize: 18, color: Colors.black)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: TextEditingController(text: '$_value'),
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        decoration: InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_value > 1) _value--;
                          _loadCommittees();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _value++;
                          _loadCommittees();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_isLoadingCommittees)
                Center(child: CircularProgressIndicator())
              else if (_committees.isEmpty &&
                  _selectedCommittee == "Wybierz komisje")
                Text("Nie znaleziono komisji dla kadencji $_value")
              else ...[
                Text("Komisja, której statystyki cię interesują"),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCommittee,
                  items: <String>[
                    "Wybierz komisje",
                    ..._committees.map((c) => "${c['name']} - ${c['code']}"),
                  ]
                      .map((e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) async {
                    setState(() {
                      _selectedCommittee = val!;
                      _committeeStats = null;
                    });
                    if (_selectedCommittee != "Wybierz komisje") {
                      await _loadCommitteeStats();
                    }
                  },
                ),
                if (_selectedCommittee == "Wybierz komisje")
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text("", style: TextStyle(fontStyle: FontStyle.italic)),
                  )
                else if (_committeeStats != null) ...[
                  TabBar(
                    controller: _innerTabController,
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Przegląd Komisji"),
                      Tab(text: "Statystyki Szczegółowe"),
                    ],
                  ),
                ]
              ]
            ],
          ),
        ),
        if (_selectedCommittee != "Wybierz komisje" && _committeeStats != null)
          Expanded(
            child: TabBarView(
              controller: _innerTabController,
              children: [
                SingleChildScrollView(child: _buildOverviewTab()),
                SingleChildScrollView(child: _buildDetailsTab()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPoslowieTab() {
    final statsOptions = [
      "brak",
      "wiek",
      "edukacja",
      "profesja",
      "okręg",
      "województwo"
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Kadencja sejmu (Posłowie)", style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller:
                        TextEditingController(text: '$_poslowieTermNumber'),
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_poslowieTermNumber > 1) _poslowieTermNumber--;
                      _loadMpsData(_poslowieTermNumber);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Icon(Icons.remove, color: Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _poslowieTermNumber++;
                      _loadMpsData(_poslowieTermNumber);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_isLoadingPoslowieData)
            Center(child: CircularProgressIndicator())
          else if (_mpsList.isEmpty)
            Text("Brak danych dla kadencji $_poslowieTermNumber")
          else ...[
            Text("Wybierz statystykę:", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedMpStat,
              items: statsOptions
                  .map(
                      (o) => DropdownMenuItem<String>(value: o, child: Text(o)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMpStat = val!;
                });
              },
            ),
            SizedBox(height: 16),
            Text("Wybierz posła:", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedMp.isEmpty ? null : _selectedMp,
              items: _mpNames
                  .map(
                      (n) => DropdownMenuItem<String>(value: n, child: Text(n)))
                  .toList(),
              onChanged: (val) async {
                setState(() {
                  _selectedMp = val!;
                });
                final selectedMpObject = _findMpByString(val!);
                if (selectedMpObject != null) {
                  await _loadMpHistory(selectedMpObject, _poslowieTermNumber);
                }
              },
            ),
            SizedBox(height: 16),
            if (_historyOfMp.isNotEmpty) _buildMpHistoryTable(_historyOfMp),
            SizedBox(height: 16),
            _selectedMpStat != "brak"
                ? _buildMpStatistics()
                : SizedBox.shrink(),
          ],
        ],
      ),
    );
  }

  Widget _buildMpStatistics() {
    if (_selectedMpStat == "wiek") {
      List<int> ages = _mpsList.where((mp) => mp.birthDate != null).map((mp) {
        DateTime birthDate = DateTime.parse(mp.birthDate!);
        return DateTime.now().year - birthDate.year;
      }).toList();

      if (ages.isEmpty) {
        return Center(child: Text("Brak danych o wieku posłów."));
      }

      final stats = calculateAgeStats(ages);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Statystyki wieku posłów", style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          buildAgeHistogram(ages),
          SizedBox(height: 16),
          Text("Statystyki ogólne:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DataTable(
            columns: [
              DataColumn(label: Text('Statystyka')),
              DataColumn(label: Text('Wartość')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('Najmłodszy')),
                DataCell(Text('${stats['minAge']} lat'))
              ]),
              DataRow(cells: [
                DataCell(Text('Najstarszy')),
                DataCell(Text('${stats['maxAge']} lat'))
              ]),
              DataRow(cells: [
                DataCell(Text('Średnia')),
                DataCell(Text('${stats['avgAge']} lat'))
              ]),
              DataRow(cells: [
                DataCell(Text('Mediana')),
                DataCell(Text('${stats['medianAge']} lat'))
              ]),
              DataRow(cells: [
                DataCell(Text('Odchylenie standardowe')),
                DataCell(Text('${stats['stdDev']} lat'))
              ]),
            ],
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildMpHistoryTable(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return SizedBox.shrink();
    final columns = data.first.keys.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
        rows: data.map((row) {
          return DataRow(
            cells: columns.map((c) {
              return DataCell(Text(row[c].toString()));
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Map<String, int> getClubsCount(Map<String, dynamic> clubs) {
    final counts = <String, int>{};
    clubs.forEach((club, members) {
      counts[club] = (members as List).length;
    });
    return counts;
  }

  Widget buildBarChart(Map<String, int> data) {
    final clubEntries = data.entries.toList();
    final List<Color> availableColors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.amber,
      Colors.cyan,
      Colors.teal,
      Colors.pink,
      Colors.orange,
      Colors.brown,
      Colors.purple,
    ];
    final Map<String, Color> dynamicColors = {};
    for (var i = 0; i < clubEntries.length; i++) {
      dynamicColors[clubEntries[i].key] =
          availableColors[i % availableColors.length];
    }

    return Column(
      children: [
        Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              barGroups: clubEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final partyName = entry.value.key;
                final count = entry.value.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: dynamicColors[partyName],
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    )
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: clubEntries.map((entry) {
            final partyName = entry.key;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: dynamicColors[partyName],
                ),
                SizedBox(width: 4),
                Text(partyName),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final clubs = Map<String, dynamic>.from(_committeeStats!['clubs']);
    final membersMap = Map<String, int>.from(_committeeStats!['members']);
    final clubsCount = getClubsCount(clubs);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16),
          Text("Liczba członków w komisjach", style: TextStyle(fontSize: 18)),
          SizedBox(height: 16),
          buildBarChart(clubsCount),
          SizedBox(height: 16),
          _buildClubsDataTable(clubs),
        ],
      ),
    );
  }

  Widget _buildClubsDataTable(Map<String, dynamic> clubs) {
    final columns = ["Klub", "Członkowie"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 26.0,
        dataRowMinHeight: 64.0,
        dataRowMaxHeight: 160.0,
        headingRowHeight: 56.0,
        columns: columns
            .map((c) => DataColumn(
                label: Text(c,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold))))
            .toList(),
        rows: clubs.entries.map((e) {
          final clubName = e.key;
          final members = (e.value as List).join(", ");

          return DataRow(cells: [
            DataCell(
              Text(
                clubName,
                style: TextStyle(fontSize: 14),
              ),
            ),
            DataCell(
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 250),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    members,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildMembersDataTable(Map<String, int> membersMap) {
    final columns = ["Poseł", "Liczba komisji"];
    return DataTable(
      columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
      rows: membersMap.entries.map((e) {
        return DataRow(cells: [
          DataCell(Text(e.key)),
          DataCell(Text(e.value.toString())),
        ]);
      }).toList(),
    );
  }

  Widget _buildDetailsTab() {
    final options = ["Wybierz typ statystyki", "wiek", "edukacja", "profesja"];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text("Wybierz statystykę", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedStat,
            items: options
                .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedStat = val!;
              });
            },
          ),
          SizedBox(height: 16),
          if (_selectedStat == "Wybierz typ statystyki")
            Text("Wybierz typ statystyki aby zobaczyć szczegółowe dane")
          else if (_selectedStat == "wiek") ...[
            if (_committeeAges.isEmpty)
              Text("Brak danych o wieku członków tej komisji.")
            else ...[
              Text("Statystyki wieku członków komisji",
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              buildAgeHistogram(_committeeAges),
              SizedBox(height: 16),
              Text("Statystyki ogólne:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Builder(
                builder: (context) {
                  final stats = calculateAgeStats(_committeeAges);
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('Statystyka')),
                      DataColumn(label: Text('Wartość')),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text('Najmłodszy')),
                        DataCell(Text('${stats['minAge']} lat'))
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Najstarszy')),
                        DataCell(Text('${stats['maxAge']} lat'))
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Średnia')),
                        DataCell(Text('${stats['avgAge']} lat'))
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Mediana')),
                        DataCell(Text('${stats['medianAge']} lat'))
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Odchylenie standardowe')),
                        DataCell(Text('${stats['stdDev']} lat'))
                      ]),
                    ],
                  );
                },
              ),
            ],
          ] else if (_selectedStat == "edukacja")
            Text("Tu pokaż dane edukacji (zaimplementuj według potrzeb)")
          else if (_selectedStat == "profesja")
            Text("Tu pokaż dane profesji (zaimplementuj według potrzeb)")
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Wyśrodkowanie tytułu
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Wyśrodkowanie w poziomie
            mainAxisSize: MainAxisSize.min, // Minimalny rozmiar Row
            children: [
              Icon(Icons.bar_chart, size: 32),
              SizedBox(width: 8),
              Text('Statystyki', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: [
            Tab(
              child: Text('Komisje', style: TextStyle(color: Colors.red)),
            ),
            Tab(
              child: Text('Posłowie', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKomisjeTab(),
          _buildPoslowieTab(),
        ],
      ),
    );
  }
}

// Funkcja do obliczenia statystyk wieku
Map<String, dynamic> calculateAgeStats(List<int> ages) {
  ages.sort();
  int minAge = ages.first;
  int maxAge = ages.last;
  double avgAge = ages.reduce((a, b) => a + b) / ages.length;
  num medianAge = ages.length % 2 == 0
      ? (ages[ages.length ~/ 2 - 1] + ages[ages.length ~/ 2]) / 2
      : ages[ages.length ~/ 2];
  double stdDev = sqrt(
      ages.map((a) => pow(a - avgAge, 2)).reduce((a, b) => a + b) /
          ages.length);

  return {
    'minAge': minAge,
    'maxAge': maxAge,
    'avgAge': avgAge.toStringAsFixed(1),
    'medianAge': medianAge.toStringAsFixed(1),
    'stdDev': stdDev.toStringAsFixed(1),
  };
}

Widget buildAgeHistogram(List<int> ages) {
  Map<String, int> ageBins = {};
  for (int age in ages) {
    int binStart = (age ~/ 10) * 10;
    String binLabel = "$binStart-${binStart + 10}";
    ageBins[binLabel] = (ageBins[binLabel] ?? 0) + 1;
  }

  List<MapEntry<String, int>> sortedBins = ageBins.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return Container(
    height: 300,
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        barGroups: sortedBins.asMap().entries.map((entry) {
          int index = entry.key;
          String bin = entry.value.key;
          int count = entry.value.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: Colors.orange,
                width: 20,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= sortedBins.length) return SizedBox();
                return Text(sortedBins[value.toInt()].key,
                    style: TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    ),
  );
}
