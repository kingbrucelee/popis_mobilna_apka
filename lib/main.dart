import 'package:flutter/material.dart';
// Upewnij się, że te pliki istnieją, możesz je tymczasowo wykomentować, jeśli ich nie masz
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
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
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
              SizedBox(height: 20),
              // Image with square frame
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.deepPurple,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/sejm.jpg', // Upewnij się, że plik istnieje
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Buttons below the image
              CustomHoverableButton(
                text: 'Statystyki',
                onPressed: () => Navigator.pushNamed(context, '/view1'),
              ),
              SizedBox(height: 20),
              CustomHoverableButton(
                text: 'Procesy Parlamentarne',
                onPressed: () => Navigator.pushNamed(context, '/view2'),
              ),
              SizedBox(height: 20),
              CustomHoverableButton(
                text: 'Analiza Polityczna',
                onPressed: () => Navigator.pushNamed(context, '/view3'),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Button Widget with Hover Effect
class CustomHoverableButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomHoverableButton({
    required this.text,
    required this.onPressed,
  });

  @override
  _CustomHoverableButtonState createState() => _CustomHoverableButtonState();
}

class _CustomHoverableButtonState extends State<CustomHoverableButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isHovered ? Colors.deepPurple[400] : Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: _isHovered ? 10 : 5,
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _isHovered ? Colors.white54 : Colors.white,
          ),
        ),
      ),
    );
  }
}
