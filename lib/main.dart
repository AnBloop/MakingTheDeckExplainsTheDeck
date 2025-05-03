import 'package:flutter/material.dart';
import 'scryfall.dart';
import 'search.dart';

String apptitle = 'Scryfall Card Search';
String appbarText = 'Scryfall Card Search';
Widget activeWidget = CardSearchWidget();

GlobalKey<_baseplateState> baseplateKey = GlobalKey<_baseplateState>();

class baseplate extends StatefulWidget {
  @override
  _baseplateState createState() => _baseplateState();
}

class _baseplateState extends State<baseplate> {

  update({Widget? newWidget, String? newTitle, String? newAppBarText}) {
    setState(() {
      activeWidget = newWidget ?? activeWidget;
      apptitle = newTitle ?? apptitle;
      appbarText = newAppBarText ?? appbarText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: apptitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(appbarText),
        ),
        body: Center(
          child: activeWidget,
        ),
      ),
    );
  }
}


void main() {
  runApp(baseplate());

  baseplateKey.currentState?.update(
    newWidget: CardSearchWidget(),
  );
}
