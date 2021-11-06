import 'package:flutter/material.dart';

import 'CropSquarePage.dart';
import 'OperationsPage.dart';
import 'CreditsPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "jpeg_ffi demo",
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/cropSquare': (context) => Scaffold(body: CropSquarePage()),
        '/operations': (context) => Scaffold(body: OperationsPage()),
        '/credits': (context) => CreditsPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('jpeg_ffi examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            ElevatedButton(
              child: Text("Crop to square"),
              onPressed: () {
                Navigator.pushNamed(context, '/cropSquare');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Operations"),
              onPressed: () {
                Navigator.pushNamed(context, '/operations');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Credits"),
              onPressed: () {
                Navigator.pushNamed(context, '/credits');
              },
            ),
          ],
        ),
      ),
    );
  }
}
