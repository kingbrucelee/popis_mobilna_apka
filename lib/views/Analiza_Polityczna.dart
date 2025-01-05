import 'package:flutter/material.dart';
// Upewnij się, że import jest zgodny z Twoją strukturą katalogów:
import '../controllers/seatsCalculator.dart';

class View3 extends StatefulWidget {
  const View3({Key? key}) : super(key: key);

  @override
  _View3State createState() => _View3State();
}

class _View3State extends State<View3> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    "Wrocław": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 14,
      "Uzupełniono": false,
    },
    "Bydgoszcz": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Toruń": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 13,
      "Uzupełniono": false,
    },
    "Lublin": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 15,
      "Uzupełniono": false,
    },
    "Chełm": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Zielona Góra": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Łódź": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Piotrków Trybunalski": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Sieradz": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Chrzanów": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 8,
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
    "Nowy Sącz": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Tarnów": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Płock": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Radom": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Siedlce": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Warszawa": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 20,
      "Uzupełniono": false,
    },
    "Warszawa 2": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Opole": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Krosno": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 11,
      "Uzupełniono": false,
    },
    "Rzeszów": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 15,
      "Uzupełniono": false,
    },
    "Białystok": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 14,
      "Uzupełniono": false,
    },
    "Gdańsk": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Słupsk": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 14,
      "Uzupełniono": false,
    },
    "Bielsko-Biała": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Częstochowa": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 7,
      "Uzupełniono": false,
    },
    "Gliwice": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Rybnik": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Katowice": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Sosnowiec": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Kielce": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 16,
      "Uzupełniono": false,
    },
    "Elbląg": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 8,
      "Uzupełniono": false,
    },
    "Olsztyn": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Kalisz": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
    "Konin": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Piła": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 9,
      "Uzupełniono": false,
    },
    "Poznań": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 10,
      "Uzupełniono": false,
    },
    "Koszalin": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 8,
      "Uzupełniono": false,
    },
    "Szczecin": {
      "PiS": 0,
      "KO": 0,
      "Trzecia Droga": 0,
      "Lewica": 0,
      "Konfederacja": 0,
      "Frekwencja": 0.0,
      "Miejsca do zdobycia": 12,
      "Uzupełniono": false,
    },
  };

// votesJson
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
    "Wrocław": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Bydgoszcz": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Toruń": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Lublin": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Chełm": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Zielona Góra": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Łódź": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Piotrków Trybunalski": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Sieradz": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Chrzanów": {
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
    "Nowy Sącz": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Tarnów": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Płock": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Radom": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Siedlce": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Warszawa": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Warszawa 2": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Opole": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Krosno": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Rzeszów": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Białystok": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Gdańsk": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Słupsk": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Bielsko-Biała": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Częstochowa": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Gliwice": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Rybnik": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Katowice": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Sosnowiec": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Kielce": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Elbląg": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Olsztyn": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Kalisz": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Konin": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Piła": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Poznań": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Koszalin": {
      "PiS": 0.0,
      "KO": 0.0,
      "Trzecia Droga": 0.0,
      "Lewica": 0.0,
      "Konfederacja": 0.0,
    },
    "Szczecin": {
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

  /// Przykładowa funkcja budująca zawartość nieużywanych jeszcze zakładek
  Widget _buildTabContent(String title) {
    return Center(
      child: Text('$title content here', style: const TextStyle(fontSize: 14)),
    );
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
            children: const [
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
          tabs: const [
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
  String _type = "ilościowy"; // Opcje: "ilościowy" lub "procentowy"
  String _method = "d'Hondta";
  late String _selectedDistrict;

  // Pola tymczasowe do UI, wczytywane z dataJson/votesJson.
  double _pis = 0.0,
      _ko = 0.0,
      _td = 0.0,
      _lewica = 0.0,
      _konf = 0.0,
      _frequency = 0.0;
  int _seatsNum = 0;

  // Przechowujemy wynik kalkulacji
  Map<String, int> _resultSeats = {};

  // Kontrolery do textFieldów (dzięki nim wartości w polach są zawsze aktualne)
  late TextEditingController _pisController,
      _koController,
      _tdController,
      _lewicaController,
      _konfController,
      _frequencyController,
      _seatsController;

  @override
  void initState() {
    super.initState();
    _selectedDistrict = widget.dataJson.keys.first;
    _loadDistrictValues(_selectedDistrict);

    // Inicjalizacja kontrolerów
    _pisController = TextEditingController();
    _koController = TextEditingController();
    _tdController = TextEditingController();
    _lewicaController = TextEditingController();
    _konfController = TextEditingController();
    _frequencyController = TextEditingController();
    _seatsController = TextEditingController();

    // Ustawiamy wartości początkowe
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

  /// Ładuje wartości z widget.dataJson i widget.votesJson do pól tymczasowych
  void _loadDistrictValues(String district) {
    final distData = widget.dataJson[district];
    final distVotes = widget.votesJson[district];
    if (distData != null && distVotes != null) {
      _pis = distVotes["PiS"]?.toDouble() ?? 0.0;
      _ko = distVotes["KO"]?.toDouble() ?? 0.0;
      _td = distVotes["Trzecia Droga"]?.toDouble() ?? 0.0;
      _lewica = distVotes["Lewica"]?.toDouble() ?? 0.0;
      _konf = distVotes["Konfederacja"]?.toDouble() ?? 0.0;

      _frequency = distData["Frekwencja"]?.toDouble() ?? 0.0;
      _seatsNum = distData["Miejsca do zdobycia"] ?? 0;
    }
  }

  /// Aktualizuje wartości w polach tekstowych
  void _setControllersValues() {
    _pisController.text = _pis == 0.0 ? '' : _pis.toString();
    _koController.text = _ko == 0.0 ? '' : _ko.toString();
    _tdController.text = _td == 0.0 ? '' : _td.toString();
    _lewicaController.text = _lewica == 0.0 ? '' : _lewica.toString();
    _konfController.text = _konf == 0.0 ? '' : _konf.toString();
    _frequencyController.text = _frequency == 0.0 ? '' : _frequency.toString();
    _seatsController.text = _seatsNum == 0 ? '' : _seatsNum.toString();
  }

  /// Zapamiętuje wartości w polach tymczasowych (z kontrolerów)
  void _updateTempValuesFromControllers() {
    _pis = _parseDouble(_pisController.text);
    _ko = _parseDouble(_koController.text);
    _td = _parseDouble(_tdController.text);
    _lewica = _parseDouble(_lewicaController.text);
    _konf = _parseDouble(_konfController.text);
    _frequency = _parseDouble(_frequencyController.text);
    _seatsNum = int.tryParse(_seatsController.text) ?? 0;
  }

  /// Pomocnicza funkcja parsująca double z ewentualną zamianą przecinka na kropkę
  double _parseDouble(String val) {
    return double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown z wyborem okręgu
          const Text('Wybierz okręg:',
              style: TextStyle(fontWeight: FontWeight.bold)),
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
                  _setControllersValues();
                });
              }
            },
          ),
          const Divider(),

          // Dropdown do wyboru typu głosów
          const Text('Rodzaj głosów:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _type,
            items: const [
              DropdownMenuItem(
                value: "ilościowy",
                child: Text("Ilościowy"),
              ),
              DropdownMenuItem(
                value: "procentowy",
                child: Text("Procentowy"),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _type = value;
                });
              }
            },
          ),
          const Divider(),

          // Pola do wprowadzania głosów
          _buildNumberField(
            label: 'PiS (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _pisController,
          ),
          _buildNumberField(
            label: 'KO (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _koController,
          ),
          _buildNumberField(
            label: 'Trzecia Droga (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _tdController,
          ),
          _buildNumberField(
            label: 'Lewica (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _lewicaController,
          ),
          _buildNumberField(
            label: 'Konfederacja (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _konfController,
          ),

          // Frekwencja
          _buildNumberField(
            label: 'Frekwencja (${_type == "procentowy" ? "%" : "głosów"})',
            controller: _frequencyController,
          ),

          // Liczba miejsc
          TextField(
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Liczba mandatów w okręgu'),
            controller: _seatsController,
          ),

          const SizedBox(height: 16),

          // Metoda podziału:
          const Text(
            'Wybierz metodę:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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

          const SizedBox(height: 16),

          // Przycisk obliczania
          ElevatedButton(
            onPressed: _calculateSeats,
            child: const Text('Oblicz podział mandatów'),
          ),

          const SizedBox(height: 16),

          // Wyświetlanie wyniku
          const Text(
            'Wynik podziału mandatów:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (_resultSeats.isNotEmpty)
            ..._resultSeats.entries.map((e) {
              return Text('${e.key}: ${e.value}');
            }),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Funkcja obliczająca podział mandatów
  void _calculateSeats() {
    // Najpierw wczytujemy aktualne wartości z kontrolerów
    _updateTempValuesFromControllers();

    // Sprawdzenie poprawności danych w przypadku procentów
    if (_type == "procentowy") {
      double totalPercentage = _pis + _ko + _td + _lewica + _konf;
      if (totalPercentage > 100.0) {
        _showErrorDialog("Suma procentów przekracza 100%.");
        return;
      }
      // Można też sprawdzać czy sumy < 100% itp.
    }

    // Przekształcenie procentów na głosy, jeśli wybrano opcję procentową
    // (interpretujemy _frequency jako łączną liczbę głosów?)
    double totalVotes = _frequency;
    double actualPis = _type == "procentowy" ? (_pis / 100) * totalVotes : _pis;
    double actualKo = _type == "procentowy" ? (_ko / 100) * totalVotes : _ko;
    double actualTd = _type == "procentowy" ? (_td / 100) * totalVotes : _td;
    double actualLewica =
        _type == "procentowy" ? (_lewica / 100) * totalVotes : _lewica;
    double actualKonf =
        _type == "procentowy" ? (_konf / 100) * totalVotes : _konf;

    // Zaktualizuj głosy i frekwencję w oryginalnych mapach
    widget.votesJson[_selectedDistrict]["PiS"] = actualPis;
    widget.votesJson[_selectedDistrict]["KO"] = actualKo;
    widget.votesJson[_selectedDistrict]["Trzecia Droga"] = actualTd;
    widget.votesJson[_selectedDistrict]["Lewica"] = actualLewica;
    widget.votesJson[_selectedDistrict]["Konfederacja"] = actualKonf;

    widget.dataJson[_selectedDistrict]["Frekwencja"] = _frequency;
    widget.dataJson[_selectedDistrict]["Miejsca do zdobycia"] = _seatsNum;

    // Wywołaj callbacki, aby przekazać zmiany wyżej (np. do View3)
    widget.onVotesJsonChanged(widget.votesJson);
    widget.onDataJsonChanged(widget.dataJson);

    // Oblicz mandaty
    final result = SeatsCalculatorSingleDistrict.chooseMethods(
      PiS: actualPis,
      KO: actualKo,
      TD: actualTd,
      Lewica: actualLewica,
      Konf: actualKonf,
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

  /// Wyświetla dialog błędu
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

  /// Pomocnicze pole do wprowadzania wartości double
  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      controller: controller,
      onChanged: (val) {
        // Można dodatkowo wymusić odświeżenie stanu itp.
        // setState(() {});
      },
    );
  }
}
