import 'package:flutter/material.dart';
import 'views/Statystyki.dart';
import 'views/Procesy_Parlamentarne.dart';
import 'views/Analiza_Polityczna.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IAPP',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      routes: {
        '/view1': (context) => View1(),
        '/view2': (context) => View2(),
        '/view3': (context) => View3(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Zwiększenie wysokości AppBar
        child: AppBar(
          title: Padding(
            padding:
                const EdgeInsets.only(top: 20.0), // Przesunięcie tytułu w dół
            child: Text(
              'Internetowa Analiza Polskiej Polityki',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40), // Top spacing
              CustomElevatedButton(
                text: 'Statystyki',
                onPressed: () => Navigator.pushNamed(context, '/view1'),
              ),
              SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Procesy Parlamentarne',
                onPressed: () => Navigator.pushNamed(context, '/view2'),
              ),
              SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Analiza Polityczna',
                onPressed: () => Navigator.pushNamed(context, '/view3'),
              ),
              SizedBox(height: 40), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Button Widget for Consistency
class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple, // Button color
        foregroundColor: Colors.white, // Text color
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
