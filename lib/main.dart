import 'deck_selection.dart';
import 'package:flutter/material.dart';
import 'save.dart';

String apptitle = 'Scryfall Deckbuilder';
String appbarText = 'Deckbuilder';


double heightToWidthRatio = 63/88;

GlobalKey<_baseplateState> baseplateKey = GlobalKey<_baseplateState>();

class baseplate extends StatefulWidget {

  baseplate({Key? key}) : super(key : key);

  @override
  _baseplateState createState() => _baseplateState();
}

class _baseplateState extends State<baseplate> {

  Widget activeWidget = LoadingScreen();

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(baseplate(key: baseplateKey));

  decks = await loadDecksFromJson();

  WidgetsBinding.instance.addPostFrameCallback((_) {
  baseplateKey.currentState?.update(
      newWidget: deckSelectionWidget(decks)
  );});
}

void saveDecks(){
  saveDecksToJson(decks);
}

class LoadingScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: Center(child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text("Loading Decks..."),
        SizedBox(height: 10),
        CircularProgressIndicator()
      ])
      )
    );
  }
}


