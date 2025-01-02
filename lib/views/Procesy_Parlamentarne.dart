import 'package:flutter/material.dart';
import '../controllers/interpelation_controller.dart';
import '../controllers/committee_controller.dart';
import '../controllers/voting_controller.dart';
import '../controllers/acts_controller.dart';

class View2 extends StatefulWidget {
  @override
  _View2State createState() => _View2State();
}

class _View2State extends State<View2> with SingleTickerProviderStateMixin {
  final InterpelationController _interpelationController =
      InterpelationController(); // Kontroler do obsługi API
  final CommitteeController _committeeController =
      CommitteeController(); // Tworzymy instancję dla kontrolera komisji
  final VotingController _votingController =
      VotingController(); // Kontroler do obsługi głosowań

  final LegislativeController _legislativeController = LegislativeController();

  late TabController _tabController;

  int _selectedTerm = 10; // Domyślna kadencja
  int _selectedInterpelation = 1; // Domyślny numer interpelacji
  Map<String, dynamic>?
      _interpelationDetails; // Szczegóły wybranej interpelacji
  bool _isLoading = false; // Status ładowania danych

  String? _selectedCommittee; // Wybrana komisja
  List<Map<String, dynamic>> _committees = []; // Lista komisji
  Map<String, dynamic>? _committeeDetails; // Szczegóły wybranej komisji
  List<String> _recentMeetings = []; // Ostatnie posiedzenia
  List<Map<String, dynamic>> _committeePresidium = []; // Prezydium komisji

  List<Map<String, dynamic>> _mps = []; // Lista posłów
  Map<String, dynamic>? _selectedMp; // Wybrany poseł
  List<int> _proceedingNumbers = []; // Lista numerów posiedzeń
  int? _selectedProceedingNumber; // Wybrany numer posiedzenia
  List<String> _votingDates = []; // Lista dat głosowań
  String? _selectedVotingDate; // Wybrana data głosowania
  List<Map<String, dynamic>> _votingDetails = []; // Szczegóły głosowań

  List<Map<String, dynamic>> _legislativeProcesses = [];
  Map<String, dynamic>? _processDetails;
  List<Map<String, dynamic>> _latestLaws = [];
  String? _selectedProcess;
  int _selectedYear = DateTime.now().year;

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

  Future<void> fetchInterpelationDetails() async {
    setState(() {
      _isLoading = true;
      _interpelationDetails =
          null; // Resetowanie szczegółów przed nowym pobraniem
    });

    try {
      final details = await _interpelationController.getInterpelationDetails(
        _selectedTerm,
        _selectedInterpelation,
      );
      setState(() {
        _interpelationDetails = details;
      });
    } catch (e) {
      print('Błąd podczas ładowania szczegółów interpelacji: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchLegislativeProcesses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _legislativeProcesses =
          await _legislativeController.fetchLegislativeProcesses(_selectedTerm);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchProcessDetails(String processNumber) async {
    setState(() {
      _isLoading = true;
    });
    try {
      _processDetails = await _legislativeController.fetchProcessDetails(
          _selectedTerm, processNumber);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchLatestLaws() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Pobierz wszystkie akty prawne dla danego roku
      List<Map<String, dynamic>> allLaws =
          await _legislativeController.fetchLatestLaws(_selectedYear);

      // Pobierz tylko ostatnie 10
      setState(() {
        _latestLaws = allLaws.take(10).toList();
      });
    } catch (e) {
      print('Błąd podczas ładowania ostatnich aktów prawnych: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCommittees() async {
    setState(() {
      _isLoading = true;
      _committees = [];
    });

    try {
      final committees =
          await _committeeController.getCommittees(_selectedTerm);
      setState(() {
        _committees = committees;
      });
    } catch (e) {
      print('Błąd podczas ładowania komisji: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCommitteeDetails(String code) async {
    setState(() {
      _isLoading = true;
      _committeeDetails = null;
      _recentMeetings = [];
      _committeePresidium = [];
    });

    try {
      final details = await _committeeController.getCommitteeDetails(
        _selectedTerm,
        code,
      );
      setState(() {
        _committeeDetails = details;
      });

      await fetchCommitteePresidium(code);
    } catch (e) {
      print('Błąd podczas ładowania szczegółów komisji: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCommitteePresidium(String code) async {
    setState(() {
      _isLoading = true;
      _committeePresidium = [];
    });

    try {
      final presidium = await _committeeController.getCommitteePresidium(
        _selectedTerm,
        code,
      );
      setState(() {
        _committeePresidium = presidium;
      });
    } catch (e) {
      print('Błąd podczas ładowania prezydium komisji: $e');
    } finally {
      print(_committeePresidium);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchMps() async {
    setState(() {
      _isLoading = true;
      _mps = [];
    });

    try {
      final mps = await _votingController.getMps(_selectedTerm);
      setState(() {
        _mps = mps;
      });
    } catch (e) {
      print('Błąd podczas ładowania posłów: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchProceedingNumbers() async {
    setState(() {
      _isLoading = true;
      _proceedingNumbers = [];
    });

    try {
      final proceedingNumbers =
          await _votingController.getProceedingNumbers(_selectedTerm);
      setState(() {
        _proceedingNumbers = proceedingNumbers;
      });
    } catch (e) {
      print('Błąd podczas ładowania numerów posiedzeń: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchVotingDates() async {
    if (_selectedProceedingNumber == null) return;

    setState(() {
      _isLoading = true;
      _votingDates = [];
    });

    try {
      final votingDates = await _votingController.getVotingDates(
        _selectedTerm,
        _selectedProceedingNumber!,
      );
      setState(() {
        _votingDates = votingDates;
      });
    } catch (e) {
      print('Błąd podczas ładowania dat głosowań: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchVotingDetails() async {
    if (_selectedMp == null ||
        _selectedProceedingNumber == null ||
        _selectedVotingDate == null) return;

    setState(() {
      _isLoading = true;
      _votingDetails = [];
    });

    try {
      final votingDetails = await _votingController.getVotingDetails(
        _selectedTerm,
        _selectedMp!['id'],
        _selectedProceedingNumber!,
        _selectedVotingDate!,
      );
      setState(() {
        _votingDetails = votingDetails;
      });
    } catch (e) {
      print('Błąd podczas ładowania szczegółów głosowań: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Row(
            children: [
              Icon(Icons.bar_chart, size: 32),
              SizedBox(width: 8),
              Text('Procesy Parlamentarne', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: [
            Tab(
              child: Text(
                'Interpelacje',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Tab(
              child: Text(
                'Ustawy',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Tab(
              child: Text(
                'Komisje',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            Tab(
              child: Text(
                'Głosowania Posłów',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInterpelationTab(),
          _buildLawsTab(),
          _buildCommitteesTab(),
          _buildVotingTab(),
        ],
      ),
    );
  }

  Widget _buildInterpelationTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Numer Kadencji'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _selectedTerm = int.tryParse(value) ?? 10;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Numer Interpelacji'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _selectedInterpelation = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: fetchInterpelationDetails,
                child: Text('Pokaż'),
              ),
            ],
          ),
          SizedBox(height: 16),
          _isLoading
              ? CircularProgressIndicator()
              : _interpelationDetails == null
                  ? Text('Wprowadź dane i kliknij "Pokaż".')
                  : _buildInterpelationDetails(),
        ],
      ),
    );
  }

  Widget _buildInterpelationDetails() {
    if (_interpelationDetails == null) {
      return Text('Brak szczegółów do wyświetlenia.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tytuł: ${_interpelationDetails!['title']}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Data wysłania: ${_interpelationDetails!['sentDate']}'),
        SizedBox(height: 8),
        Text(
          'Odpowiedź:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(_interpelationDetails!['response'] ?? 'Brak odpowiedzi'),
      ],
    );
  }

  Widget _buildCommitteesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Numer Kadencji'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: fetchCommittees,
                  child: Text('Pobierz komisje'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _committees.isEmpty
                    ? Text('Brak komisji do wyświetlenia.')
                    : DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCommittee,
                        hint: Text('Wybierz komisję'),
                        items: _committees
                            .map((committee) => DropdownMenuItem<String>(
                                  value: committee['code'],
                                  child: Text(committee['name']),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCommittee = value;
                          });
                          if (value != null) {
                            fetchCommitteeDetails(value);
                          }
                        },
                      ),
            SizedBox(height: 16),
            _committeeDetails == null
                ? Text('Wybierz komisję, aby zobaczyć szczegóły.')
                : _buildCommitteeDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitteeDetails() {
    if (_committeeDetails == null) {
      return Text('Brak szczegółów do wyświetlenia.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Szczegóły Komisji:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Nazwa: ${_committeeDetails!['name']}'),
        Text('Zakres działania: ${_committeeDetails!['scope']}'),
        SizedBox(height: 8),
        Text('Prezydium Komisji:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        _committeePresidium.isEmpty
            ? Text('Brak danych o prezydium.')
            : DataTable(
                columns: [
                  DataColumn(label: Text('Imię i nazwisko')),
                  DataColumn(label: Text('Stanowisko')),
                ],
                rows: _committeePresidium.expand((item) {
                  // Rozbijamy dane `members` i przypisujemy je do odpowiednich klubów
                  final members = item['members'] as Map<String, int>;
                  final clubs = item['clubs'] as Map<String, List<String>>;

                  return members.entries.map((member) {
                    // Znajdujemy klub, do którego należy członek
                    final club = clubs.entries
                        .firstWhere(
                          (clubEntry) => clubEntry.value.contains(member.key),
                          orElse: () => MapEntry('Nieznany klub', []),
                        )
                        .key;

                    return DataRow(cells: [
                      DataCell(Text(member.key)), // Imię i nazwisko
                      DataCell(Text(club)), // Klub
                    ]);
                  });
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildLawsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Add this to make content scrollable
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Numer Kadencji'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: fetchLegislativeProcesses,
                  child: Text('Pobierz procesy legislacyjne'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _legislativeProcesses.isEmpty
                    ? Text('Brak dostępnych procesów legislacyjnych.')
                    : DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedProcess,
                        hint: Text('Wybierz proces legislacyjny'),
                        items: _legislativeProcesses
                            .map((process) => DropdownMenuItem<String>(
                                  value: process['number'],
                                  child: Text(
                                      '${process['number']} - ${process['title']}'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProcess = value;
                          });
                          if (value != null) {
                            fetchProcessDetails(value);
                          }
                        },
                      ),
            SizedBox(height: 16),
            _processDetails == null
                ? Text('Wybierz proces, aby zobaczyć szczegóły.')
                : _buildProcessDetails(),
            Divider(),
            TextField(
              decoration: InputDecoration(labelText: 'Rok'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _selectedYear = int.tryParse(value) ?? DateTime.now().year;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchLatestLaws,
              child: Text('Pobierz ostatnie akty prawne'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _latestLaws.isEmpty
                    ? Text('Brak dostępnych aktów prawnych.')
                    : ListView(
                        shrinkWrap:
                            true, // Prevent ListView from growing indefinitely
                        //physics: NeverScrollableScrollPhysics(),
                        children: _latestLaws.map((law) {
                          return law['type'] == 'Rozporządzenie'
                              ? ListTile(
                                  title: Text(law['title']),
                                  subtitle: Text('Typ: ${law['type']}'),
                                )
                              : Container();
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessDetails() {
    if (_processDetails == null) {
      return Text('Brak szczegółów do wyświetlenia.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Szczegóły procesu legislacyjnego:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Tytuł: ${_processDetails!['title'] ?? 'Brak tytułu'}'),
        Text('Opis: ${_processDetails!['description'] ?? 'Brak opisu'}'),
        SizedBox(height: 16),
        Text('Etapy procesu:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...(_processDetails!['stages'] ?? []).map((stage) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Etap: ${stage['stageName']}'),
              if (stage['decision'] != null && stage['decision'].isNotEmpty)
                Text('Decyzja: ${stage['decision']}'),
              Divider(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildVotingTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Numer Kadencji'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: fetchMps,
                  child: Text('Pobierz posłów'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _mps.isEmpty
                    ? Text('Brak posłów do wyświetlenia.')
                    : Column(
                        children: [
                          DropdownButton<Map<String, dynamic>>(
                            isExpanded: true,
                            value: _selectedMp,
                            hint: Text('Wybierz posła'),
                            items: _mps
                                .map((mp) =>
                                    DropdownMenuItem<Map<String, dynamic>>(
                                      value: mp,
                                      child: Text(mp['lastFirstName']),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMp = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchProceedingNumbers,
                            child: Text('Pobierz numery posiedzeń'),
                          ),
                        ],
                      ),
            SizedBox(height: 16),
            _proceedingNumbers.isEmpty
                ? Text('Brak numerów posiedzeń do wyświetlenia.')
                : Column(
                    children: [
                      DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedProceedingNumber,
                        hint: Text('Wybierz numer posiedzenia'),
                        items: _proceedingNumbers
                            .map((number) => DropdownMenuItem<int>(
                                  value: number,
                                  child: Text(number.toString()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProceedingNumber = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchVotingDates,
                        child: Text('Pobierz daty głosowań'),
                      ),
                    ],
                  ),
            SizedBox(height: 16),
            _votingDates.isEmpty
                ? Text('Brak dat głosowań do wyświetlenia.')
                : Column(
                    children: [
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedVotingDate,
                        hint: Text('Wybierz datę głosowania'),
                        items: _votingDates
                            .map((date) => DropdownMenuItem<String>(
                                  value: date,
                                  child: Text(date),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVotingDate = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchVotingDetails,
                        child: Text('Pokaż głosowania'),
                      ),
                    ],
                  ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _votingDetails.isEmpty
                    ? Text('Brak szczegółów głosowań do wyświetlenia.')
                    : _buildVotingDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Szczegóły Głosowań:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ..._votingDetails.map((voting) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Numer głosowania: ${voting['votingNumber']}'),
                  Text('Temat: ${voting['topic'] ?? 'Brak tematu'}'),
                  Text('Głos: ${voting['vote'] ?? 'Brak informacji'}'),
                  Text('Data: ${voting['date']}'),
                ],
              ),
            )),
      ],
    );
  }
}
