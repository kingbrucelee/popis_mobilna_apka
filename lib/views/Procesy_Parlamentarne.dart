import 'package:flutter/material.dart';
import '../controllers/interpelation_controller.dart'; // Dodaj kontroler do obsługi API
import '../controllers/committee_controller.dart'; // Kontroler do obsługi API


class View2 extends StatefulWidget {
  @override
  _View2State createState() => _View2State();
}

class _View2State extends State<View2> with SingleTickerProviderStateMixin {
  final InterpelationController _interpelationController =
      InterpelationController(); // Kontroler do obsługi API
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

  Future<void> fetchCommittees() async {
    setState(() {
      _isLoading = true;
      _committees = [];
    });

    try {
      final committees = await CommitteeController.getCommittees(_selectedTerm);
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
    });

    try {
      final details = await CommitteeController.getCommitteeDetails(
        _selectedTerm,
        code,
      );
      //final meetings = await CommitteeController.getRecentMeetings(
      //  _selectedTerm,
      //  code,
      //  3,
      //);
      setState(() {
        _committeeDetails = details;
        //_recentMeetings = meetings;
      });
    } catch (e) {
      print('Błąd podczas ładowania szczegółów komisji: $e');
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
        title: Row(
          children: [
            Icon(Icons.bar_chart, size: 32),
            SizedBox(width: 8),
            Text('Procesy Parlamentarne', style: TextStyle(fontSize: 24)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: [
            Tab(
              child: Text(
                'Interpelacje',
                style: TextStyle(color: Colors.red),
              ),
            ),
            Tab(
              child: Text(
                'Ustawy',
                style: TextStyle(color: Colors.red),
              ),
            ),
            Tab(
              child: Text(
                'Komisje',
                style: TextStyle(color: Colors.red),
              ),
            ),
            Tab(
              child: Text(
                'Głosowania Posłów',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInterpelationTab(), // Zakładka Interpelacje
          Center(child: Text('Ustawy content here')),
          _buildCommitteesTab(),
          Center(child: Text('Głosowania Posłów content here')),
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
        Text('Tytuł: ${_interpelationDetails!['title']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Data wysłania: ${_interpelationDetails!['sentDate']}'),
        SizedBox(height: 8),
        //Text('Autorzy: ${_interpelationDetails!['authors']?.join(', ') ?? 'Brak danych'}'),SizedBox(height: 8),
        Text('Odpowiedź:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(_interpelationDetails!['response'] ?? 'Brak odpowiedzi'),
      ],
    );
  }



Widget _buildCommitteesTab() {
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
            ElevatedButton(
              onPressed: fetchCommittees,
              child: Text('Pobierz komisje'),
            ),
          ],
        ),
        SizedBox(height: 16),
        _isLoading
            ? CircularProgressIndicator()
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
      Text('Ostatnie posiedzenia:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ..._recentMeetings.map((meeting) => Text(meeting)).toList(),
    ],
  );
}
}

