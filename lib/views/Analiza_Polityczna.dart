import 'package:flutter/material.dart';
import '../models/mp_stats.dart';
import '../controllers/mps_stats_controller.dart';

class View3 extends StatefulWidget {
  @override
  _View1State createState() => _View1State();
}

class _View1State extends State<View3> with SingleTickerProviderStateMixin {
  final MyModel _model = MyModel();
  late MyController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = MyController(_model);
    _tabController = TabController(length: 2, vsync: this);
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
        title: Row(
          children: [
            Icon(Icons.bar_chart, size: 32), // Replace with your custom icon
            SizedBox(width: 8),
            Text('Analiza Polityczna', style: TextStyle(fontSize: 24)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: [
            Tab(
              child: Text(
                'Potencjalne Koalicje',
                style: TextStyle(color: Colors.red),
              ),
            ),
            Tab(
              child: Text(
                'Kalkulator Wyborczy',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
              child: Text(
                  'Potencjalne Koalicje content here')), // Replace with your content
          Center(child: Text('Kalkulator Wyborczy content here')),
        ],
      ),
    );
  }
}
