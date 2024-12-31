// views/Analiza_Polityczna.dart
import 'package:flutter/material.dart';
// Zakładam, że plik seatsCalculator.dart jest katalog wyżej, a ten z kolei w folderze controllers.
// Dopasuj ścieżkę importu do faktycznej struktury projektu:
//import '../controllers/seatsCalculator.dart';

class View3 extends StatefulWidget {
  @override
  _View3State createState() => _View3State();
}

class _View3State extends State<View3> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Przykładowe dane
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
                child: Text('Potencjalne Koalicje',
                    style: TextStyle(color: Colors.red, fontSize: 12))),
            Tab(
                child: Text('Kalkulator Wyborczy',
                    style: TextStyle(color: Colors.red, fontSize: 12))),
            Tab(
                child: Text('Korelacje Wyborcze',
                    style: TextStyle(color: Colors.red, fontSize: 12))),
            Tab(
                child: Text('Prawo Benforda',
                    style: TextStyle(color: Colors.red, fontSize: 12))),
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
  String _type = "ilościowy";
  String _method = "d'Hondta";
  String _selectedDistrict = "";
  double _pis = 0.0,
      _ko = 0.0,
      _td = 0.0,
      _lewica = 0.0,
      _konf = 0.0,
      _frequency = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.dataJson.isNotEmpty) {
      _selectedDistrict = widget.dataJson.keys.first;
      _loadDistrictValues(_selectedDistrict);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          // ...
          // Tu wstaw swój UI do wprowadzania głosów, frekwencji, metody, itp.
          // np. dropdown do wyboru okręgu, inputy do PiS/KO/TD/Lewica/Konf...
          // Przyciski, które wywołają SeatsCalculatorSingleDistrict.chooseMethods(...)
          // i wyświetlą wynik.
        ],
      ),
    );
  }

  void _loadDistrictValues(String district) {
    final distVotes = widget.votesJson[district];
    if (distVotes != null) {
      setState(() {
        _pis = distVotes["PiS"]?.toDouble() ?? 0.0;
        _ko = distVotes["KO"]?.toDouble() ?? 0.0;
        _td = distVotes["Trzecia Droga"]?.toDouble() ?? 0.0;
        _lewica = distVotes["Lewica"]?.toDouble() ?? 0.0;
        _konf = distVotes["Konfederacja"]?.toDouble() ?? 0.0;
        _frequency = widget.dataJson[district]["Frekwencja"]?.toDouble() ?? 0.0;
      });
    }
  }
}
