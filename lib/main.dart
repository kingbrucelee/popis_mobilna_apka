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
      // Corrected: Use appBar instead of title
      appBar: AppBar(
          title: Text('Internetowa Analiza Polskiej Polityki',
              overflow: TextOverflow.ellipsis)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Statystyki'),
              onPressed: () => Navigator.pushNamed(context, '/view1'),
            ),
            ElevatedButton(
              child: Text('Procesy Parlamentarne'),
              onPressed: () => Navigator.pushNamed(context, '/view2'),
            ),
            ElevatedButton(
              child: Text('Analiza Polityczna'),
              onPressed: () => Navigator.pushNamed(context, '/view3'),
            ),
          ],
        ),
      ),
    );
  }
}
