import 'package:flutter/material.dart';
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
  "Battles" : [],
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
  DeckViewer({required this.deck, Key? key}) : super(key: key){
    loadDeck(deck);
  }

  @override
  _DeckViewer createState() => _DeckViewer();
}


class _DeckViewer extends State<DeckViewer> {

  final int minCardsAcross = 2;
  final int maxCardsAcross = 15;
  int cardsAcross = 4;

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
      child: SizedBox(height: 40, child: Stack(children:[
        //Return
        Positioned(
          top:0,
          left:0,
          child: IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            onPressed: (){
              baseplateKey.currentState?.update(
                newWidget: deckSelectionWidget(decks)
              );
              clearData();
            }
          )
        ),
        //Save Deck
        Positioned(
          top: 0,
          left: 30,
          child: IconButton(
            icon: Icon(Icons.save),
            onPressed: (){
              saveDeck(widget.deck);
            },
          )
        ),

        //Zoom Out
        Positioned(
          top: 0,
          right: 30,
          child: IconButton(
            icon: Icon(Icons.remove_circle),
            onPressed: (){
              setState((){
                cardsAcross = (cardsAcross+1).clamp(minCardsAcross, maxCardsAcross);
              });
            },
          )
        ),

        //Zoom in
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: (){
              setState((){
                cardsAcross = (cardsAcross-1).clamp(minCardsAcross, maxCardsAcross);
              });
            },
          )
        ),


      ])
      )
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
              "$section (${getNumCardsIn(section)})",
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

                  return CardWidgetForDeckBuilder(card, quantity!, widget.deck.deckFormat);
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
  else if(typeline.contains("artifact")){return "Artifacts";}
  else if(typeline.contains("enchantment")){return "Enchantments";}
  else if(typeline.contains("battle")){return "Battles";}
  else {return "Other";}
  
}

void addCard(MCard card, {int cardQuantity = 1}) {

  String section = card.cardType;

  if(card.isCommander){section = "Commander";}
  if(card.isSideboard){section = "Sideboard";}

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

  if(cardQuantities.keys.contains(card)){
    cardQuantities[card] = cardQuantities[card]! + cardQuantity;
    
    for (var cardMap in deckList[section]!) {
      if (cardMap.containsKey(card)) {
        cardMap[card] = cardQuantities[card]!;
        break;
      }
  }
  }else{
    cardQuantities[card] = cardQuantity;
    deckList[section]!.add({card: cardQuantities[card]!});
  }
  
}

void updateCardPosition(MCard card) {
  int quantity = 0;

  for (String section in deckList.keys) {
    final entry = deckList[section]!.firstWhere(
      (entry) => entry.containsKey(card),
      orElse: () => {},
    );

    if (entry.isNotEmpty) {
      quantity = entry[card]!;
      
      cardQuantities.removeWhere((key, value) => key == card);

      deckList[section]!.remove(entry);

      break;
    }
  }

  card.cardType = classifyCard(card);
  addCard(card, cardQuantity: quantity);
}

void removeCard(MCard card) {

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

void clearData(){
  cardQuantities.clear();
  for(String section in deckList.keys){
    deckList[section]!.clear();
  }
}

void loadDeck(Deck deck){
  for(MCard card in deck.deckList.keys){
    addCard(card, cardQuantity: deck.deckList[card]!);
  }
}

void saveDeck(Deck deck){
  for(int i=0; i<decks.length; i++){
    Deck iterDeck = decks[i];
    if(iterDeck == deck){
      decks[i].deckList = Map.from(cardQuantities);
      decks[i].deckIdentity = getDeckIdentity(decks[i]);
      saveDecks();
      return;
    }
  }
  throw Exception("No deck found to save");
}

List<String> getDeckIdentity(Deck deck){

  List<String> orderedList = ["W", "U", "B", "R", "G", "C"];
  List<String> deckIdentity = [];

  for(MCard card in deck.deckList.keys){
    for(String color in card.cardData['color_identity']){
      if(!deckIdentity.contains(color)){
        deckIdentity.add(color);
      }
    }
  }

  if(deckIdentity.isEmpty && deck.deckList.isNotEmpty){
    deckIdentity.add("C");
  }

  List<String> retList = [];

  for(String color in orderedList){
    if(deckIdentity.contains(color)){
      retList.add(color);
    }
  }

  return retList;
}