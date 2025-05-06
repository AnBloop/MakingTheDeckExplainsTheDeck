import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'deck_selection.dart';

String deckDataLocation = "/Scryfall Deckbuilder Decks/decks.json";

void saveDecksToJson(List<Deck> decks) async {
  final Directory saveDirectory = await getApplicationDocumentsDirectory();
  final file = File('${saveDirectory.path}$deckDataLocation');

  await file.parent.create(recursive: true);

  List<Map<String, dynamic>> deckMaps = decks.map((deck) => deck.toJson()).toList();

  String jsonString = jsonEncode(deckMaps);

  await file.writeAsString(jsonString);
}

Future<List<Deck>> loadDecksFromJson() async {
  final saveDirectory = await getApplicationDocumentsDirectory();
  final file = File('${saveDirectory.path}$deckDataLocation');

  if (!await file.exists()) return [];

  String jsonString = await file.readAsString();
  List<dynamic> decodedList = jsonDecode(jsonString);

  List<Deck> loadedDecks = [];
  for (var deckJson in decodedList) {
    Deck deck = await getDeckFromJson(deckJson);
    loadedDecks.add(deck);
  }

  return loadedDecks;
}
