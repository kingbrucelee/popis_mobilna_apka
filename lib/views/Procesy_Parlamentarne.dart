import 'package:flutter/material.dart';
import '../models/mp_stats.dart';
import '../controllers/mps_stats_controller.dart';

class View2 extends StatefulWidget {
  @override
  _View1State createState() => _View1State();
}

class _View1State extends State<View2> with SingleTickerProviderStateMixin {
  final MyModel _model = MyModel();
  late MyController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = MyController(_model);
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
        title: Row(
          children: [
            Icon(Icons.bar_chart, size: 32), // Replace with your custom icon
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
          Center(
              child: Text(
                  'Interpelacje content here')), // Replace with your content
          Center(child: Text('Ustawy content here')),
          Center(
              child: Text('Komisje content here')), // Replace with your content
          Center(
              child: Text(
                  'Głosowania Posłów content here')), // Replace with your content
        ],
      ),
    );
  }
}
