import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'scryfall.dart';
import 'main.dart';
import 'card.dart';
import 'deck_selection.dart';


Map<MCard, int> cardQuantities = {};

final Map<String, List<Map<MCard, int>>> deckList = {
  "Commander" : [],
  "Creatures" : [],
  "Instants" : [],
  "Sorceries" : [],
  "Artifacts" : [],
  "Enchantments" : [],
  "Planeswalkers" : [],
  "Lands" : [],
  "Other" : [],
  "Sideboard" : []
};

GlobalKey<_DeckViewer> deckViewerKey = GlobalKey<_DeckViewer>();

class DeckBuilderWidget extends StatefulWidget{

  late final Deck currentDeck;

  DeckBuilderWidget(this.currentDeck);

  @override
  _DeckBuilderWidget createState() => _DeckBuilderWidget();
}

class _DeckBuilderWidget extends State<DeckBuilderWidget> with AutomaticKeepAliveClientMixin{
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DeckViewer(deck: widget.currentDeck, key: deckViewerKey);
  }
  
}

class DeckViewer extends StatefulWidget{

  late Deck deck;

  @override
  DeckViewer({required this.deck, Key? key}) : super(key: key);

  @override
  _DeckViewer createState() => _DeckViewer();
}

int cardsAcross = 4;

class _DeckViewer extends State<DeckViewer> {

  @override
  Widget build(BuildContext context) {

    
    int numCards = getNumCards();
    int maxCards = widget.deck.deckFormat == Format.commander ? 100 : 60;

    return Column(children: [

    Padding(
      padding: EdgeInsets.symmetric(horizontal:10),
      child: Row(
        children: [
          Text(
            "Cards: $numCards/$maxCards",
            style: TextStyle(color: numCards<=maxCards ? Colors.black : Colors.red)),
          SizedBox(width: 20),
          Text("Average Mana Cost: ${getAverageCMC().toStringAsFixed(2)}")
        ],
      )
    ),

        Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(children:[
        //Return
        IconButton(
          icon: Icon(Icons.keyboard_arrow_left),
          onPressed: (){
            baseplateKey.currentState?.update(
              newWidget: deckSelectionWidget(decks)
            );
          }
        ),
        //Save Deck
        IconButton(
          icon: Icon(Icons.save),
          onPressed: (){
            saveDeck(widget.deck);
          },
        )
      ])
    ),
    
    Expanded(child: ListView.builder(
      itemCount: deckList.length,
      itemBuilder: (context, sectionIndex) {
       
        String section = deckList.keys.toList()[sectionIndex];

        List<Map<MCard, int>> sectionCards = deckList[section]!;

        if(sectionCards.isEmpty){return SizedBox.shrink();}

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              section,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sectionCards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cardsAcross,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: heightToWidthRatio),
                itemBuilder: (context, cardIndex) {
                  final cardMap = sectionCards[cardIndex];
                  final card = cardMap.keys.first;
                  final quantity = cardMap[card];

                  return CardWidgetForDeckBuilder(card, quantity!);
                },
              )
            )
          ]
        );
      }
    )
    )
    ]);
    
    }
}

void toggleCommander(MCard card){

  deckViewerKey.currentState!.setState((){
    for(var cardMap in deckList["Commander"]!){
      if(cardMap.keys.contains(card)){
        deckList[classifyCard(card)]!.add(cardMap);
        deckList["Commander"]!.remove(cardMap);
        card.isCommander = false;
        return;
      }
    }

    for(var category in deckList.keys){
      for(var cardMap in deckList[category]!){
        if(cardMap.keys.contains(card)){
          deckList["Commander"]!.add(cardMap);
          deckList[classifyCard(card)]!.remove(cardMap);
          card.isCommander = true;
          return;
        }
      }
    }
  });
}

void toggleSideboard(MCard card){
  deckViewerKey.currentState!.setState((){
    for(var cardMap in deckList["Sideboard"]!){
      if(cardMap.keys.contains(card)){
        deckList[classifyCard(card)]!.add(cardMap);
        deckList["Sideboard"]!.remove(cardMap);
        card.isSideboard = false;
        return;
      }
    }

    for(var category in deckList.keys){
      for(var cardMap in deckList[category]!){
        if(cardMap.keys.contains(card)){
          deckList["Sideboard"]!.add(cardMap);
          deckList[classifyCard(card)]!.remove(cardMap);
          card.isSideboard = true;
          return;
        }
      }
    }
  });
}

String classifyCard(MCard card){
  String typeline = card.getTypeline().toLowerCase();

       if(typeline.contains("creature")){return "Creatures";}
  else if(typeline.contains("land")){return "Lands";}
  else if(typeline.contains("planeswalker")){return "Planeswalkers";}
  else if(typeline.contains("instant")){return "Instants";}
  else if(typeline.contains("sorcery")){return "Sorceries";}
  else if(typeline.contains("artifact")){return "Instants";}
  else if(typeline.contains("enchantment")){return "Enchantments";}
  else {return "Other";}
  
}

void addCard(String id) async {

  MCard card = await getCardFromID(id);
  String section = card.cardType;

  for(var cardMap in deckList["Commander"]!){
    if(cardMap.keys.contains(card)){
      section = "Commander";
    }
  }
  for(var cardMap in deckList["Sideboard"]!){
    if(cardMap.keys.contains(card)){
      section = "Sideboard";
    }
  }

  deckViewerKey.currentState!.setState(() {

    if(cardQuantities.keys.contains(card)){
      cardQuantities[card] = cardQuantities[card]! + 1;
      
      for (var cardMap in deckList[section]!) {
        if (cardMap.containsKey(card)) {
          cardMap[card] = cardQuantities[card]!;
          break;
        }
    }
    }else{
      cardQuantities[card] = 1;
      deckList[section]!.add({card: cardQuantities[card]!});
    }
  });
}

void removeCard(String id) async {

  MCard card = await getCardFromID(id);
  String section = card.cardType;

  for(var cardMap in deckList["Commander"]!){
    if(cardMap.keys.contains(card)){
      section = "Commander";
    }
  }
  for(var cardMap in deckList["Sideboard"]!){
    if(cardMap.keys.contains(card)){
      section = "Sideboard";
    }
  }

  deckViewerKey.currentState!.setState(() {

    if(cardQuantities.keys.contains(card)){
      cardQuantities[card] = cardQuantities[card]! - 1;
      if(cardQuantities[card] == 0){
        cardQuantities.remove(card);
        deckList[section]!.removeWhere((entry) => entry.containsKey(card));
      }else{
        for (var entry in deckList[section]!) {
        if (entry.containsKey(card)) {
          entry[card] = cardQuantities[card]!;
          break;
        }
      }
      }
    }

  });
}

double getAverageCMC(){
  double manaValueTotal = 0;
  int numCards = getNumCards(includeLands: false);

  for(String section in deckList.keys){
      if(section != "Sideboard" && section != "Other"){
        for(var cardMap in deckList[section]!){
          for(var key in cardMap.keys){
            manaValueTotal += key.getCMC() * cardMap[key]!;
          }
        }
      }
  }
  if(numCards == 0){return 0;}
  return manaValueTotal/numCards;
}

int getNumCardsIn(String section){
  int cardTotal = 0;

  for(var cardMap in deckList[section]!){
    for(var key in cardMap.keys){
      cardTotal += cardMap[key]!;
    }
  }
  return cardTotal;
}

int getNumCards({bool includeLands = true}){
  int cardTotal = 0;

  for(String section in deckList.keys){
      if(!includeLands && section == "Lands"){continue;}else{
        if(section != "Sideboard" && section != "Other"){
          for(var cardMap in deckList[section]!){
            for(var key in cardMap.keys){
              cardTotal += cardMap[key]!;
            }
          }
        }
      }
    }
  return cardTotal;
}

void saveDeck(Deck deck){
  for(Deck iter_deck in decks){
    if(iter_deck == deck){
      
    }
  }
}