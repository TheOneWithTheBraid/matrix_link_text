//  Copyright (c) 2019 Aleksander Woźniak
//  Copyright (c) 2022 Famedly GmbH
//  Licensed under Apache License v2.0

import 'package:flutter/material.dart';
import 'package:matrix_link_text/link_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkText Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _text =
      'Lorem ipsum https://flutter.dev\nhttps://pub.dev dolor https://google.com sit amet\nCustom handler: https://example.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LinkText Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24.0),
              _buildNormalText(),
              const SizedBox(height: 64.0),
              _buildLinkText(),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Normal Text Widget',
          textAlign: TextAlign.center,
          style: TextStyle().copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        Text(_text, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildLinkText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'LinkText Widget',
          textAlign: TextAlign.center,
          style: TextStyle().copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        LinkText(
          text: _text,
          textAlign: TextAlign.center,
          beforeLaunch: (uri) {
            if (uri.host == 'example.com') {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('This link is handled by the app...')));
              return false;
            }
            return null;
          },
        ),
      ],
    );
  }
}
