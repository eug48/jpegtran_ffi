import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partial credits'),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 10),
          ..._buildTiles(),
        ],
      ),
    );
  }

  List<ListTile> _buildTiles() {
    var texts = [
      "Dart & Flutter teams",
      "libjpeg-turbo & Independent JPEG Group teams",
      "LLVM, clang, gcc and countless other build tools",
      "Test image: New born Frisian red white calf, Wikimedia Commons, Uberprutser, licensed under the Creative Commons Attribution-Share Alike 3.0 Unported license",
    ];

    return texts.map((text) => ListTile(title: Text(text))).toList();
  }
}
