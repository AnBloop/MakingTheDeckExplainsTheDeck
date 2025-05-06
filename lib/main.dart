import 'deck_selection.dart';
import 'package:flutter/material.dart';

String apptitle = 'Scryfall Deckbuilder';
String appbarText = 'Deckbuilder';
Widget activeWidget = Placeholder();


double heightToWidthRatio = 63/88;

GlobalKey<_baseplateState> baseplateKey = GlobalKey<_baseplateState>();

class baseplate extends StatefulWidget {

  baseplate({Key? key}) : super(key : key);

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
      home: activeWidget
    );
  }
}

List<Deck> decks = [];

void main() {

  runApp(baseplate(key: baseplateKey));

  WidgetsBinding.instance.addPostFrameCallback((_) {
  baseplateKey.currentState?.update(
      newWidget: deckSelectionWidget(decks)
  );});
}


