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

  // Dodatkowe zmienne do statystyk w Komisjach:
  List<int> _committeeAges = [];
  Map<String, int> _committeeEducation = {};
  Map<String, int> _committeeProfession = {};
  Map<String, Map<String, int>> _committeeProfessionByParty = {};

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

  // Analogicznie jak w Twoim kodzie...
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

      // Wiek
      final agesResult =
          await service.getCommitteeMemberAges(_clubsButBetter, term: _value);
      final Map<String, List<int>> mpsAgeMap =
          Map<String, List<int>>.from(agesResult['MPsAge']);
      List<int> allAges = [];
      mpsAgeMap.values.forEach((list) => allAges.addAll(list));
      setState(() {
        _committeeAges = allAges;
      });

      // Wykształcenie
      final educationDetails = await service.getCommitteeMemberDetails(
        _clubsButBetter,
        term: _value,
        searchedInfo: 'edukacja',
      );
      Map<String, int> aggregatedEducation = {};
      educationDetails.forEach((club, eduMap) {
        eduMap.forEach((education, count) {
          aggregatedEducation[education] =
              (aggregatedEducation[education] ?? 0) + count;
        });
      });
      setState(() {
        _committeeEducation = aggregatedEducation;
      });

      // Profesja (komisje)
      final professionDetails = await service.getCommitteeMemberDetails(
        _clubsButBetter,
        term: _value,
        searchedInfo: 'profesja',
      );
      Map<String, int> aggregatedProfession = {};
      professionDetails.forEach((club, profMap) {
        profMap.forEach((profession, count) {
          aggregatedProfession[profession] =
              (aggregatedProfession[profession] ?? 0) + count;
        });
      });
      setState(() {
        _committeeProfession = aggregatedProfession;
        _committeeProfessionByParty =
            Map<String, Map<String, int>>.from(professionDetails);
      });
    } catch (e) {
      print("Błąd podczas ładowania statystyk komisji: $e");
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
          _loadMpHistory(_mpsList.first, term); // Załaduj historię pierwszego
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

  // ------------------------ ZAKŁADKA KOMISJE ------------------------
  Widget _buildKomisjeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... Twój niezmieniony kod do UI (kadencja, pobieranie, dropdown) ...
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

  // ------------------------ ZAKŁADKA POSŁOWIE ------------------------
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
          // ... UI do zmiany numeru kadencji ...
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

  // Tabela z historią danego posła
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

  // ------------------------ STATYSTYKI POSŁÓW ------------------------
  Widget _buildMpStatistics() {
    if (_selectedMpStat == "wiek") {
      final ages = _mpsList.where((mp) => mp.birthDate != null).map((mp) {
        final birthDate = DateTime.parse(mp.birthDate!);
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
    } else if (_selectedMpStat == "edukacja") {
      final Map<String, Map<String, int>> partyEducationMap =
          groupEducationLevelsByParty(_mpsList);
      partyEducationMap.remove("niez."); // ewentualnie
      if (partyEducationMap.isEmpty) {
        return Center(
          child: Text("Brak danych o wykształceniu posłów."),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Statystyki wykształcenia posłów wg klubów/partii",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...partyEducationMap.entries.map((entry) {
            final partyName = entry.key;
            final educationData = entry.value;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    buildEducationPieChart(educationData),
                    SizedBox(height: 16),
                    Text(
                      "Szczegóły wykształcenia:",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    buildEducationDetailsTable(educationData),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      );
    } else if (_selectedMpStat == "profesja") {
      final Map<String, Map<String, int>> partyProfessionMap =
          groupProfessionByParty(_mpsList);
      if (partyProfessionMap.isEmpty) {
        return Center(child: Text("Brak danych o profesji posłów."));
      }

      // 1) Zsumuj profesje dla całej listy posłów (łącznie)
      Map<String, int> aggregatedProfession = {};
      partyProfessionMap.forEach((party, profMap) {
        profMap.forEach((prof, count) {
          aggregatedProfession[prof] =
              (aggregatedProfession[prof] ?? 0) + count;
        });
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Statystyki profesji posłów – całościowo",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Ogólny wykres
          buildProfessionPieChart(aggregatedProfession),
          SizedBox(height: 16),
          Text(
            "Szczegóły profesji (ogółem):",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          buildEducationDetailsTable(aggregatedProfession),
          SizedBox(height: 24),

          Text(
            "Statystyki profesji w rozbiciu na partie:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...partyProfessionMap.entries.map((entry) {
            final partyName = entry.key;
            final profData = entry.value;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    buildProfessionPieChart(profData),
                    SizedBox(height: 16),
                    Text(
                      "Szczegóły profesji:",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    buildEducationDetailsTable(profData),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      );
    } else if (_selectedMpStat == "województwo") {
      // Wyświetlamy statystyki województw
      return _buildMpStatsWojewodztwo();
    } else if (_selectedMpStat == "okręg") {
      return _buildMpStatsOkreg(_mpsList);
    } else {
      // "okręg" lub "brak"
      return SizedBox.shrink();
    }
  }

  // ------------------------ ZAKŁADKA KOMISJE (UI) ------------------------
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
          ] else if (_selectedStat == "edukacja") ...[
            if (_committeeEducation.isEmpty)
              Center(
                child: Text(
                  "Brak danych o wykształceniu członków tej komisji.",
                  style: TextStyle(fontSize: 16),
                ),
              )
            else ...[
              Text(
                "Statystyki wykształcenia członków komisji",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildEducationPieChart(_committeeEducation),
              SizedBox(height: 16),
              Text(
                "Szczegóły wykształcenia:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildEducationDetailsTable(_committeeEducation),
            ],
          ] else if (_selectedStat == "profesja") ...[
            if (_committeeProfession.isEmpty)
              Center(
                child: Text(
                  "Brak danych o profesjach członków tej komisji.",
                  style: TextStyle(fontSize: 16),
                ),
              )
            else ...[
              Text(
                "Statystyki profesji w całej komisji",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildProfessionPieChart(_committeeProfession),
              SizedBox(height: 16),
              Text(
                "Szczegóły profesji (ogółem):",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              buildEducationDetailsTable(_committeeProfession),
              SizedBox(height: 24),
              Text(
                "Statystyki profesji w rozbiciu na partie:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ..._committeeProfessionByParty.entries.map((entry) {
                final partyName = entry.key;
                final profData = entry.value;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partyName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        buildProfessionPieChart(profData),
                        SizedBox(height: 16),
                        Text(
                          "Szczegóły profesji:",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        buildEducationDetailsTable(profData),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ],
      ),
    );
  }

  // ------------------------ POMOCNICZE (WSPÓLNE) ------------------------
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
                  sideTitles: SideTitles(showTitles: false),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
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
        ),
      ],
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
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold))))
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

  // FUNKCJA DO WYKRESÓW "profesja" (z łączeniem <1% w „Pozostałe”)
  Widget buildProfessionPieChart(Map<String, int> professionData) {
    final total = professionData.values.fold(0, (sum, count) => sum + count);
    if (total == 0) {
      return Center(
        child: Text(
          "Brak danych o profesjach",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    final Map<String, int> mergedData = {};
    professionData.forEach((profession, count) {
      final percentage = (count / total) * 100;
      if (percentage < 2.0) {
        mergedData["Pozostałe"] = (mergedData["Pozostałe"] ?? 0) + count;
      } else {
        mergedData[profession] = count;
      }
    });

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
    final sections = mergedData.entries.map((entry) {
      final count = entry.value;
      final double percentage = (count / total) * 100;
      final badgeOffset = percentage < 10 ? 1.8 : 1.5;

      return PieChartSectionData(
        color: expandedColors[colorIndex++ % expandedColors.length],
        value: percentage + 7,
        radius: 60,
        title: '',
        badgeWidget: _buildLabelWidget(
          '${percentage.toStringAsFixed(1)}%',
          expandedColors[(colorIndex - 1) % expandedColors.length],
        ),
        badgePositionPercentageOffset: badgeOffset,
      );
    }).toList();

    return Column(
      children: [
        Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: mergedData.entries.map((entry) {
              final idx = mergedData.keys.toList().indexOf(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: expandedColors[idx % expandedColors.length],
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Histogram wieku
  Widget buildAgeHistogram(List<int> ages) {
    Map<String, int> ageBins = {};
    for (int age in ages) {
      int binStart = (age ~/ 10) * 10;
      String binLabel = "$binStart-${binStart + 9}";
      ageBins[binLabel] = (ageBins[binLabel] ?? 0) + 1;
    }

    final sortedBins = ageBins.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          barGroups: sortedBins.asMap().entries.map((entry) {
            final index = entry.key;
            final bin = entry.value.key;
            final count = entry.value.value;
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
                  if (value < 0 || value >= sortedBins.length) {
                    return SizedBox();
                  }
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

  // Prosty wykres kołowy do edukacji
  Widget buildEducationPieChart(Map<String, int> educationData) {
    final rawTotal = educationData.values.fold(0, (sum, count) => sum + count);
    if (rawTotal == 0) {
      return Center(
        child: Text(
          "Brak danych do wyświetlenia",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    int colorIndex = 0;
    final sections = educationData.entries.map((entry) {
      final double percentage = (entry.value / rawTotal) * 100;
      return PieChartSectionData(
        color: sectionColors[colorIndex++ % sectionColors.length],
        value: percentage + 7,
        radius: 60,
        title: '',
        badgeWidget: _buildLabelWidget(
          '${percentage.toStringAsFixed(1)}%',
          sectionColors[colorIndex - 1],
        ),
        badgePositionPercentageOffset: 1.4,
      );
    }).toList();

    return Column(
      children: [
        Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: educationData.entries.map((entry) {
              final int index = educationData.keys.toList().indexOf(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: sectionColors[index % sectionColors.length],
                  ),
                  SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Kolory do wykresu kołowego edukacji
  final List<Color> sectionColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  // Etykieta do wykresów (PieChart)
  Widget _buildLabelWidget(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // Prosta tabela szczegółów (edukacja, profesja – wielokrotne użycie)
  Widget buildEducationDetailsTable(Map<String, int> data) {
    return DataTable(
      columnSpacing: 16.0,
      dataRowMinHeight: 64.0,
      dataRowMaxHeight: 64.0,
      headingRowHeight: 56.0,
      columns: [
        DataColumn(
          label: Text(
            'Kategoria',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Liczba osób',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: data.entries.map((entry) {
        return DataRow(cells: [
          DataCell(
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200),
              child: Text(
                entry.key,
                style: TextStyle(fontSize: 12),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          DataCell(
            Text(
              entry.value.toString(),
              style: TextStyle(fontSize: 12),
            ),
          ),
        ]);
      }).toList(),
    );
  }

  // Statystyki wieku
  Map<String, dynamic> calculateAgeStats(List<int> ages) {
    ages.sort();
    final minAge = ages.first;
    final maxAge = ages.last;
    final avgAge = ages.reduce((a, b) => a + b) / ages.length;
    final medianAge = ages.length % 2 == 0
        ? (ages[ages.length ~/ 2 - 1] + ages[ages.length ~/ 2]) / 2
        : ages[ages.length ~/ 2];
    final stdDev = sqrt(
      ages.map((a) => pow(a - avgAge, 2)).reduce((a, b) => a + b) / ages.length,
    );

    return {
      'minAge': minAge,
      'maxAge': maxAge,
      'avgAge': avgAge.toStringAsFixed(1),
      'medianAge': medianAge.toStringAsFixed(1),
      'stdDev': stdDev.toStringAsFixed(1),
    };
  }

  // Policz liczbę członków w klubach
  Map<String, int> getClubsCount(Map<String, dynamic> clubs) {
    final counts = <String, int>{};
    clubs.forEach((club, members) {
      counts[club] = (members as List).length;
    });
    return counts;
  }

  // Grupowanie poziomów wykształcenia
  Map<String, Map<String, int>> groupEducationLevelsByParty(List<Mp> mps) {
    final result = <String, Map<String, int>>{};
    for (final mp in mps) {
      final party = mp.club.isNotEmpty ? mp.club : "Niezrzeszeni";
      final edu = mp.educationLevel.isNotEmpty ? mp.educationLevel : "Nieznane";
      result.putIfAbsent(party, () => {});
      result[party]![edu] = (result[party]![edu] ?? 0) + 1;
    }
    return result;
  }

  // Grupowanie profesji posłów wg partii
  Map<String, Map<String, int>> groupProfessionByParty(List<Mp> mps) {
    final result = <String, Map<String, int>>{};
    for (final mp in mps) {
      final party = mp.club.isNotEmpty ? mp.club : "Niezrzeszeni";
      final prof = (mp.profession != null && mp.profession!.isNotEmpty)
          ? mp.profession!
          : "Nieznane";
      result.putIfAbsent(party, () => {});
      result[party]![prof] = (result[party]![prof] ?? 0) + 1;
    }
    return result;
  }

  // ------ WOJEWÓDZTWO (NOWE!) ------
  Widget _buildMpStatsWojewodztwo() {
    // 1) Grupujemy wszystkich posłów wg partii i wg województwa
    final partyVoivodeshipMap = groupVoivodeshipByParty(_mpsList);
    if (partyVoivodeshipMap.isEmpty) {
      return Center(child: Text("Brak danych o województwie posłów."));
    }

    // 2) Tworzymy mapę zbiorczą (wszystkie partie łącznie)
    Map<String, int> aggregatedVoivodeship = {};
    partyVoivodeshipMap.forEach((party, voivMap) {
      voivMap.forEach((voiv, count) {
        aggregatedVoivodeship[voiv] =
            (aggregatedVoivodeship[voiv] ?? 0) + count;
      });
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Statystyki województwa posłów – całościowo",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        buildVoivodeshipPieChart(aggregatedVoivodeship),
        SizedBox(height: 16),
        Text(
          "Szczegóły województw (ogółem):",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        buildEducationDetailsTable(aggregatedVoivodeship),
        SizedBox(height: 24),
        Text(
          "Statystyki województwa w rozbiciu na partie:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...partyVoivodeshipMap.entries.map((entry) {
          final partyName = entry.key;
          final voivData = entry.value;
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partyName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  buildVoivodeshipPieChart(voivData),
                  SizedBox(height: 16),
                  Text(
                    "Szczegóły województw:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  buildEducationDetailsTable(voivData),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // FUNKCJA do grupowania posłów wg partii → województwo
  Map<String, Map<String, int>> groupVoivodeshipByParty(List<Mp> mps) {
    final result = <String, Map<String, int>>{};
    for (final mp in mps) {
      final party = mp.club.isNotEmpty ? mp.club : "Niezrzeszeni";
      // Zakładamy, że "voivodeship" jest w polu mp.voivodeship
      final voiv = (mp.voivodeship != null && mp.voivodeship!.isNotEmpty)
          ? mp.voivodeship!
          : "Nieznane";

      result.putIfAbsent(party, () => {});
      result[party]![voiv] = (result[party]![voiv] ?? 0) + 1;
    }
    return result;
  }

  // WYKRES DLA WOJEWÓDZTWA
  Widget buildVoivodeshipPieChart(Map<String, int> voivData) {
    final total = voivData.values.fold(0, (sum, count) => sum + count);
    if (total == 0) {
      return Center(
        child: Text(
          "Brak danych o województwach",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    // 1) Łączenie <1% w "Pozostałe"
    final Map<String, int> mergedData = {};
    voivData.forEach((voiv, count) {
      final percentage = (count / total) * 100;
      if (percentage < 1.0) {
        mergedData["Pozostałe"] = (mergedData["Pozostałe"] ?? 0) + count;
      } else {
        mergedData[voiv] = count;
      }
    });

    // 2) Kolory i sekcje
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
    final sections = mergedData.entries.map((entry) {
      final count = entry.value;
      final double percentage = (count / total) * 100;
      final badgeOffset = percentage < 5 ? 1.5 : 1.5;

      return PieChartSectionData(
        color: expandedColors[colorIndex++ % expandedColors.length],
        value: percentage + 7,
        radius: 60,
        title: '',
        badgeWidget: _buildLabelWidget(
          '${percentage.toStringAsFixed(1)}%',
          expandedColors[(colorIndex - 1) % expandedColors.length],
        ),
        badgePositionPercentageOffset: badgeOffset,
      );
    }).toList();

    // 3) Render
    return Column(
      children: [
        Container(
          height: 300,
          padding: EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: mergedData.entries.map((entry) {
              final idx = mergedData.keys.toList().indexOf(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: expandedColors[idx % expandedColors.length],
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Wyśrodkowanie tytułu
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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

Map<String, Map<String, int>> groupDistrictByParty(List<Mp> mps) {
  // Kluczem w zewnętrznej mapie będzie nazwa okręgu,
  // w wewnętrznej – nazwa partii (club).
  final result = <String, Map<String, int>>{};
  for (final mp in mps) {
    final district = mp.districtName.isNotEmpty ? mp.districtName : "Nieznane";
    final party = mp.club.isNotEmpty ? mp.club : "Niezrzeszeni";

    // Gdy w danym okręgu nie ma jeszcze wpisu, twórzmy mapę
    result.putIfAbsent(district, () => {});
    // Zwiększamy licznik posłów danej partii w tym okręgu
    result[district]![party] = (result[district]![party] ?? 0) + 1;
  }
  return result;
}

Widget _buildMpStatsOkreg(List<Mp> mpsList) {
  // 1) Grupujemy posłów wg okręgu → partia
  final districtData = groupDistrictByParty(mpsList);

  if (districtData.isEmpty) {
    return Center(child: Text("Brak danych o okręgach wyborczych."));
  }

  // 2) Zbierz wszystkie unikatowe partie
  final allParties =
      districtData.values.expand((map) => map.keys).toSet().toList()..sort();

  // 3) Posortuj listę okręgów (klucze)
  final sortedDistricts = districtData.keys.toList()..sort();

  // 4) Budujemy tabelę z przewijaniem pionowym
  return Scrollbar(
    thumbVisibility: true,
    child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            // Pierwsza kolumna: nazwa okręgu
            DataColumn(
              label: Text(
                "Okręg",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Kolumny dla każdej partii
            ...allParties.map(
              (party) => DataColumn(
                label: Text(
                  party,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          rows: sortedDistricts.map((district) {
            final partiesCountMap = districtData[district]!;
            final rowCells = <DataCell>[];

            // 1) nazwa okręgu
            rowCells.add(DataCell(Text(district)));

            // 2) liczba posłów w każdej partii (lub 0, jeśli brak)
            for (final party in allParties) {
              final count = partiesCountMap[party] ?? 0;
              rowCells.add(DataCell(Text(count.toString())));
            }

            return DataRow(cells: rowCells);
          }).toList(),
        ),
      ),
    ),
  );
}

// Pomocniczy widget generujący wiersz "Razem" (podsumowanie kolumn)
DataRow _buildOkregSumRow(
  Map<String, Map<String, int>> districtData,
  List<String> allParties,
) {
  int grandTotal = 0; // łączna liczba posłów w każdym okręgu

  // Zliczamy sumy kolumn (dla każdej partii osobno):
  final columnSums = <String, int>{};
  for (final district in districtData.keys) {
    final partiesMap = districtData[district]!;
    for (final party in allParties) {
      columnSums[party] = (columnSums[party] ?? 0) + (partiesMap[party] ?? 0);
    }
  }

  // Wyliczamy sumę łączną (wszystkie kolumny)
  grandTotal = columnSums.values.fold(0, (prev, el) => prev + el);

  // Budujemy listę DataCell:
  final sumCells = <DataCell>[];
  sumCells.add(
      DataCell(Text("Razem", style: TextStyle(fontWeight: FontWeight.bold))));

  // Dla każdej partii wstawiamy sumę z columnSums
  for (final party in allParties) {
    final sumValue = columnSums[party] ?? 0;
    sumCells.add(DataCell(Text(
      sumValue.toString(),
      style: TextStyle(fontWeight: FontWeight.bold),
    )));
  }

  // Ostatnia kolumna – łączna suma
  sumCells.add(DataCell(Text(
    grandTotal.toString(),
    style: TextStyle(fontWeight: FontWeight.bold),
  )));

  return DataRow(cells: sumCells);
}
