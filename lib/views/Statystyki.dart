// Added code start
import 'package:flutter/material.dart';
import '../api_wrappers/committees.dart';
import '../models/mp.dart'; // Dodany import modelu Mp
import 'package:fl_chart/fl_chart.dart';

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
      if ("${mp.club} - ${mp.districtName} - ${mp.voivodeship} - ${mp.toString()}" ==
          val) {
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

  Future<void> _loadCommitteeStats() async {
    String? code;
    if (_selectedCommittee == "łącznie") {
      code = "łącznie";
    } else if (_selectedCommittee == "Wybierz komisje") {
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
    } catch (e) {
      // Handle error if needed
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
        _mpNames = _mpsList
            .map((mp) =>
                "${mp.club} - ${mp.districtName} - ${mp.voivodeship} - ${mp.toString()}")
            .toList();
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

      int total_votes =
          history.fold(0, (sum, d) => sum + (d["Uzyskane głosy"] as int));
      history.add({
        "Kadencja": "Łącznie",
        "Klub": "${_mpsList.length} unikalnych klubów",
        "Okrąg": "${_mpsList.length} unikalnych okręgów",
        "Województwo": "${_mpsList.length} unikalnych województw",
        "Edukacja":
            "${_mpsList.map((mp) => mp.educationLevel).toSet().length} unikalnych poziomów edukacji",
        "Uzyskane głosy": total_votes,
        "Profesja":
            "${_mpsList.map((mp) => mp.profession ?? "Brak").toSet().length} unikalnych zawodów",
      });

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
                          _loadCommittees(); // Automatyczne przeładowanie komisji
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
                          _loadCommittees(); // Automatyczne przeładowanie komisji
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
                    "łącznie"
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
                    child: Text("Wybierz komisję aby zobaczyć statystyki",
                        style: TextStyle(fontStyle: FontStyle.italic)),
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

        // Tutaj rozszerzamy dostępne miejsce dla TabBarView
        if (_selectedCommittee != "Wybierz komisje" && _committeeStats != null)
          Expanded(
            child: TabBarView(
              controller: _innerTabController,
              children: [
                // Dla zakładek stosujemy SingleChildScrollView wewnątrz,
                // aby zawartość mogła się przewijać.
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

  // Teraz _buildMpStatistics() zwraca bezpośrednio Widget, bez async
  Widget _buildMpStatistics() {
    if (_selectedMpStat == "wiek") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Statystyki wieku posła", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Wykres wieku posła (zaimplementuj według potrzeb)"),
        ],
      );
    } else if (_selectedMpStat == "głosy") {
      final selectedMpObject = _findMpByString(_selectedMp);
      if (selectedMpObject != null) {
        return _buildMpVotesChart(selectedMpObject);
      } else {
        return Text("Brak danych do wyświetlenia.");
      }
    } else if (_selectedMpStat == "edukacja") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Statystyki edukacji posła", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Wykres edukacji posła (zaimplementuj według potrzeb)"),
        ],
      );
    } else if (_selectedMpStat == "profesja") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Statystyki profesji posła", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Wykres profesji posła (zaimplementuj według potrzeb)"),
        ],
      );
    } else if (_selectedMpStat == "okręg") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Statystyki okręgu posła", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Wykres okręgu posła (zaimplementuj według potrzeb)"),
        ],
      );
    } else if (_selectedMpStat == "województwo") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Statystyki województwa posła", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Wykres województwa posła (zaimplementuj według potrzeb)"),
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

    // Lista dostępnych kolorów do przypisania partiom
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

    // Przypisywanie kolorów dynamicznie dla partii
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
                      color: dynamicColors[partyName], // Przypisany kolor
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    )
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false, // Ukryj nazwy partii pod wykresem
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
        // Dodanie legendy pod wykresem z dynamicznymi kolorami
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
                  color: dynamicColors[partyName], // Dynamiczny kolor
                ),
                SizedBox(width: 4),
                Text(partyName), // Nazwa partii
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
          if (_selectedCommittee == "łącznie") ...[
            SizedBox(height: 16),
            Text("Dane wszystkich posłów"),
            _buildMembersDataTable(membersMap),
          ]
        ],
      ),
    );
  }

  Widget _buildClubsDataTable(Map<String, dynamic> clubs) {
    final columns = ["Klub", "Członkowie"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 26.0, // Większy odstęp między kolumnami
        dataRowMinHeight: 64.0, // Minimalna wysokość wiersza
        dataRowMaxHeight: 160.0, // Maksymalna wysokość wiersza
        headingRowHeight: 56.0, // Wysokość nagłówka tabeli
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
                constraints: BoxConstraints(
                    maxWidth: 250), // Ograniczenie szerokości kolumny
                child: Padding(
                  padding: const EdgeInsets.all(
                      8.0), // Dodanie wewnętrznego paddingu
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
          else if (_selectedStat == "wiek")
            Text("Tu pokaż dane wieku (zaimplementuj według potrzeb)")
          else if (_selectedStat == "edukacja")
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
        title: Row(
          children: [
            Icon(Icons.bar_chart, size: 32),
            SizedBox(width: 8),
            Text('Statystyki', style: TextStyle(fontSize: 24)),
          ],
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
