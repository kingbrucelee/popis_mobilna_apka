import 'package:flutter/material.dart';
import '../controllers/interpelation_controller.dart';
import '../controllers/committee_controller.dart';
import '../controllers/voting_controller.dart';
import '../controllers/acts_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class View2 extends StatefulWidget {
  @override
  _View2State createState() => _View2State();
}

class _View2State extends State<View2> with SingleTickerProviderStateMixin {
  final InterpelationController _interpelationController =
      InterpelationController(); // Kontroler do obsługi API
  final TextEditingController _interpelationController2 =
      TextEditingController(text: '1');
  final TextEditingController _termController =
      TextEditingController(text: '10');
  final TextEditingController _yearController =
      TextEditingController(text: DateTime.now().year.toString());

  final CommitteeController _committeeController = CommitteeController();
  final VotingController _votingController = VotingController();
  final LegislativeController _legislativeController = LegislativeController();

  late TabController _tabController;

  int _selectedTerm = 10;
  int _selectedInterpelation = 1;
  Map<String, dynamic>? _interpelationDetails;
  bool _isLoading = false;

  // <<< LISTA NA DETALE POSELSKIE >>>
  List<dynamic> _mpDetailsList = [];

  String? _selectedCommittee;
  List<Map<String, dynamic>> _committees = [];
  Map<String, dynamic>? _committeeDetails;
  List<String> _recentMeetings = [];
  List<Map<String, dynamic>> _committeePresidium = [];

  List<Map<String, dynamic>> _mps = [];
  Map<String, dynamic>? _selectedMp;
  List<int> _proceedingNumbers = [];
  int? _selectedProceedingNumber;
  List<String> _votingDates = [];
  String? _selectedVotingDate;
  List<Map<String, dynamic>> _votingDetails = [];

  List<Map<String, dynamic>> _legislativeProcesses = [];
  Map<String, dynamic>? _processDetails;
  List<Map<String, dynamic>> _latestLaws = [];
  String? _selectedProcess;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _termController.text = '10';
    _yearController.text = DateTime.now().year.toString();
    // Jeśli potrzebujemy od razu pobrać listę komisji (lub cokolwiek innego)
    // fetchCommittees(); // Upewnij się, że metoda fetchCommittees istnieje!
  }

  @override
  void dispose() {
    _tabController.dispose();
    _termController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> fetchInterpelationDetails() async {
    setState(() {
      _isLoading = true;
      _interpelationDetails = null;
      _mpDetailsList = []; // resetujemy listę posłów
    });

    try {
      final details = await _interpelationController.getInterpelationDetails(
        _selectedTerm,
        _selectedInterpelation,
      );
      setState(() {
        _interpelationDetails = details;
        // Odczytujemy listę posłów z klucza "mpDetails"
        _mpDetailsList = details['mpDetails'] ?? [];
      });
    } catch (e) {
      print('Błąd podczas ładowania szczegółów interpelacji: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Poniżej inne metody, np. fetchCommittees, fetchVotingDetails, etc. ---

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kadencja sejmu', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                child: Container(
                  width: 220,
                  height: 50,
                  child: TextField(
                    controller: _termController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                      });
                    },
                  ),
                ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTerm = _selectedTerm > 1 ? _selectedTerm - 1 : 1;
                      _termController.text = _selectedTerm.toString();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTerm++;
                      _termController.text = _selectedTerm.toString();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Numer interpelacji', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child:Container(
                  width: 220,
                  height: 50,
                  child: TextField(
                    controller: _interpelationController2,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[600],
                    ),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _selectedInterpelation = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedInterpelation = _selectedInterpelation > 1
                          ? _selectedInterpelation - 1
                          : 1;
                      _interpelationController2.text =
                          _selectedInterpelation.toString();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedInterpelation++;
                      _interpelationController2.text =
                          _selectedInterpelation.toString();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchInterpelationDetails,
              child: Text('Pokaż szczegóły'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : _interpelationDetails == null
                    ? Text('Wprowadź dane i kliknij "Pokaż szczegóły".')
                    : _buildInterpelationDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpelationDetails() {
    if (_interpelationDetails == null) {
      return Text('Brak szczegółów do wyświetlenia.');
    }

    final title = _interpelationDetails!['title'] ?? 'Brak tytułu';
    final sentDate = _interpelationDetails!['sentDate'] ?? 'Brak daty wysłania';
    final response = _interpelationDetails!['response'] ?? 'Brak odpowiedzi';
    final attachments =
        _interpelationDetails!['attachments'] as Iterable? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tytuł: $title',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Data wysłania: $sentDate'),
        SizedBox(height: 8),
        Text(
          'Odpowiedź:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(response),
        SizedBox(height: 8),
        if (attachments.isNotEmpty && attachments.any((url) => url != null))
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Załączniki:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...attachments.map((url) {
                if (url != null) {
                  return InkWell(
                    onTap: () => _launchUrl(url),
                    child: Text(
                      url,
                      style: TextStyle(
                          color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  );
                } else {
                  return SizedBox.shrink(); // Nie wyświetlaj nic dla null
                }
              }),
            ],
          ),
        SizedBox(height: 16),
        Divider(),

        // >>> TUTAJ WYŚWIETLAMY DANE O POSŁACH ORAZ ICH ZDJĘCIA <<<
        Text(
          'Autorzy interpelacji:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (_mpDetailsList.isEmpty)
          Text('Brak danych o posłach.')
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _mpDetailsList.map((mp) {
              // mp jest obiektem MPDetails
              final id = mp.id;
              final name = mp.accusativeName;
              final profession = mp.profession;
              final photoUrl = mp.photoUrl;
              final club = mp.club;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zdjęcie
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Jeśli zdjęcie się nie wczyta, wyświetli placeholder
                          return Container(
                            color: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    // Dane posła
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$name',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Zawód: $profession'),
                          Text('Partia: $club'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // Funkcja pomocnicza do otwierania URL
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Nie udało się otworzyć linku: $url');
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
      print('Błąd podczas ładowania składu komisji: $e');
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

  Widget _buildCommitteesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kadencja sejmu',
                style: TextStyle(fontSize: 18, color: Colors.black)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child:Container(
                  width: 220,
                  height: 50,
                  child: TextField(
                    controller: _termController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                      });
                      fetchCommittees();
                    },
                  ),
                ),),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTerm = _selectedTerm > 1 ? _selectedTerm - 1 : 1;
                      _termController.text = _selectedTerm.toString();
                      _selectedCommittee = null; // Resetowanie wybranej komisji
                    });
                    fetchCommittees();
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTerm++;
                      _termController.text = _selectedTerm.toString();
                      _termController.text = _selectedTerm.toString();
                      _selectedCommittee = null; // Resetowanie wybranej komisji
                    });
                    fetchCommittees();
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Komisja, której statystyki cię interesują',
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _committees.isEmpty
                    ? const Text('Brak komisji do wyświetlenia.')
                    : DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCommittee,
                        hint: const Text('Wybierz komisję'),
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
            const SizedBox(height: 16),
            _committeeDetails == null
                ? const Text('')
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
        Text('Skład komisji:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        _committeePresidium.isEmpty
            ? Text('Brak danych o składzie.')
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Imię i nazwisko')),
                    DataColumn(label: Text('Partia')),
                    DataColumn(label: Text('Funkcja')),
                  ],
                  rows: _committeePresidium.expand((item) {
                    final members = item['members'] as Map<String, int>;
                    final clubs = item['clubs'] as Map<String, List<String>>;
                    final functions =
                        item['functions'] as Map<String, Map<String, String>>;

                    return members.keys.map((memberName) {
                      final clubEntry = clubs.entries.firstWhere(
                        (clubEntry) => clubEntry.value.contains(memberName),
                        orElse: () => MapEntry('Nieznany klub', []),
                      );
                      final clubName = clubEntry.key;
                      final memberFunction =
                          functions[memberName]?['function'] ?? 'Brak funkcji';

                      return DataRow(cells: [
                        DataCell(Text(memberName)), // Imię i nazwisko
                        DataCell(Text(clubName)), // Klub
                        DataCell(Text(memberFunction)), // Funkcja
                      ]);
                    }).toList();
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildLawsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kadencja sejmu',
                style: TextStyle(fontSize: 18, color: Colors.black)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child:Container(
                  width: 220,
                  height: 50,
                  child: TextField(
                    controller: _termController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                      });
                    },
                  ),
                ),),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTerm = _selectedTerm > 1 ? _selectedTerm - 1 : 1;
                      _termController.text = _selectedTerm.toString();
                      _resetLegislativeData();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTerm++;
                      _termController.text = _selectedTerm.toString();
                      _resetLegislativeData();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchLegislativeProcesses,
              child: Text('Pobierz procesy legislacyjne'),
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
                        items: _legislativeProcesses.map((process) {
                          final processNumber = process['number'];
                          return DropdownMenuItem<String>(
                            value: processNumber,
                            child: Text('$processNumber - ${process['title']}'),
                          );
                        }).toList(),
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
            Text('Rok ustaw',
                style: TextStyle(fontSize: 18, color: Colors.black)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child:Container(
                  width: 220,
                  height: 50,
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear =
                            int.tryParse(value) ?? DateTime.now().year;
                      });
                    },
                  ),
                ),),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedYear = _selectedYear > 2000
                          ? _selectedYear - 1
                          : _selectedYear;
                      _yearController.text = _selectedYear.toString();
                      _resetLatestLaws();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedYear++;
                      _yearController.text = _selectedYear.toString();
                      _resetLatestLaws();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
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
                    : SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.5, // Ustawienie wysokości na połowę ekranu // Ustalona wysokość dla przewijanej listy
                        child: ListView.builder(
                          itemCount: _latestLaws.length,
                          itemBuilder: (context, index) {
                            final law = _latestLaws[index];
                            return ListTile(
                              title: Text(law['title']),
                              subtitle: Text('Typ: ${law['type']}'),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }

// Resetowanie danych procesów legislacyjnych
  void _resetLegislativeData() {
    _legislativeProcesses = [];
    _processDetails = null;
    _selectedProcess = null;
  }

// Resetowanie danych aktów prawnych
  void _resetLatestLaws() {
    _latestLaws = [];
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
            Text('Kadencja sejmu',
                style: TextStyle(fontSize: 18, color: Colors.black)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child:Container(
                  width: 220,
                  height: 50,
                  child: TextField(
                    controller: _termController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        _selectedTerm = int.tryParse(value) ?? 10;
                        _termController.text = _selectedTerm.toString();
                        _resetVotingData();
                      });
                    },
                  ),
                ),),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTerm = _selectedTerm > 1 ? _selectedTerm - 1 : 1;
                      _termController.text = _selectedTerm.toString();
                      _resetVotingData();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTerm++;
                      _termController.text = _selectedTerm.toString();
                      _resetVotingData();
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: fetchMps,
                child: Text('Pobierz posłów'),
              ),
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
                                _resetProceedingAndVotingData();
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
                            _resetVotingDates();
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

// Resetowanie danych związanych z głosowaniami
  void _resetVotingData() {
    _mps = [];
    _selectedMp = null;
    _resetProceedingAndVotingData();
  }

// Resetowanie danych posiedzeń i głosowań
  void _resetProceedingAndVotingData() {
    _proceedingNumbers = [];
    _selectedProceedingNumber = null;
    _resetVotingDates();
  }

// Resetowanie dat głosowań i szczegółów głosowań
  void _resetVotingDates() {
    _votingDates = [];
    _selectedVotingDate = null;
    _votingDetails = [];
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
