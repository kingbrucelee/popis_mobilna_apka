import 'package:flutter/material.dart';
import '../controllers/interpelation_controller.dart'; // Dodaj kontroler do obsługi API

class View2 extends StatefulWidget {
  @override
  _View2State createState() => _View2State();
}

class _View2State extends State<View2> with SingleTickerProviderStateMixin {
  final InterpelationController _interpelationController = InterpelationController(); // Kontroler do obsługi API
  late TabController _tabController;

  int _selectedTerm = 10; // Domyślna kadencja
  int _selectedInterpelation = 1; // Domyślny numer interpelacji
  Map<String,
      dynamic>? _interpelationDetails; // Szczegóły wybranej interpelacji
  bool _isLoading = false; // Status ładowania danych

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
          Center(child: Text('Komisje content here')),
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

}