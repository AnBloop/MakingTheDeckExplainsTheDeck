import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'scryfall.dart';
import 'main.dart';
import 'package:http/http.dart' as http;



class CardSearchWidget extends StatefulWidget {
  @override
  _CardSearchWidgetState createState() => _CardSearchWidgetState();
}

class _CardSearchWidgetState extends State<CardSearchWidget> {
  final TextEditingController _controller = TextEditingController();

  String searchText = '';
  Map<String, dynamic>? cardData = null;

  void search() async{
    if (searchText.isNotEmpty) {
      try {
        cardData = await fetchCard(searchText);
        cardData = sortCardData(currentSortString, cardData!);
        setState(() {
          activeWidget = CardSearchWidget();
        });
      } catch (e) {
        setState(() {
          showDialog(context: context, builder: (context) {
            return AlertDialog(title: Text("Error"), content: Text(e.toString()));});
        });
      }
    }
  }

  final double iconSize = 20;

  Widget build(BuildContext context) {
    return Column(

      children:[

        SizedBox(height: 10), 


        SizedBox(height: 90,
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child:Stack(
            children: [
              
             //Search Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 50,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter card name',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search_rounded),
                      onPressed: () async {
                        search();
                      }
                      )
                  ),
                  onChanged: (text) {
                    setState(() {
                      searchText = text;
                    });
                  },
                 onSubmitted: (text) async {search();},
          
                )
              ),

            //Color Sorting

              Positioned(
                bottom: 0,
                left: 0,
                  child: Opacity(
                    opacity: colorFilter['C']! ? 1 : 0.5,
                    child: IconButton(
                      icon: Image.asset(
                        "assets/icons/mana_c.png", 
                        height: iconSize, width: iconSize,
                        errorBuilder: (context, error, stackTrace){
                          return Icon(Icons.circle, color: Colors.grey);
                      },),
                      
                      onPressed: () {
                        setState((){
                          colorFilter["C"] = !colorFilter["C"]!;
                        });
                      }
                    )
                  )
              ),

              Positioned(
                bottom: 0,
                left: 25,
                child: Opacity(
                    opacity: colorFilter['W']! ? 1 : 0.5,
                    child: IconButton(
                      icon: Image.asset(
                        "assets/icons/mana_w.png", 
                        height: iconSize, width: iconSize,
                        errorBuilder: (context, error, stackTrace){
                          return Icon(Icons.circle, color: Colors.yellow);
                      },),
                      
                      onPressed: () {
                        setState((){
                          colorFilter["W"] = !colorFilter["W"]!;
                        });
                      }
                    )
                  )
              ),

              Positioned(
                bottom: 0,
                left: 50,
                child: Opacity(
                    opacity: colorFilter['U']! ? 1 : 0.5,
                    child: IconButton(
                      icon: Image.asset(
                        "assets/icons/mana_u.png", 
                        height: iconSize, width: iconSize,
                        errorBuilder: (context, error, stackTrace){
                          return Icon(Icons.circle, color: Colors.blue);
                      },),
                      
                      onPressed: () {
                        setState((){
                          colorFilter["U"] = !colorFilter["U"]!;
                        });
                      }
                    )
                  )
              ),

              Positioned(
                bottom: 0,
                left: 75,
                child: Opacity(
                    opacity: colorFilter['B']! ? 1 : 0.5,
                    child: IconButton(
                      icon: Image.asset(
                        "assets/icons/mana_b.png", 
                        height: iconSize, width: iconSize,
                        errorBuilder: (context, error, stackTrace){
                          return Icon(Icons.circle, color: Colors.black);
                      },),
                      
                      onPressed: () {
                        setState((){
                          colorFilter["B"] = !colorFilter["B"]!;
                        });
                      }
                    )
                  )
              ),

              Positioned(
                bottom: 0,
                left: 100,
                child: Opacity(
                    opacity: colorFilter['R']! ? 1 : 0.5,
                    child: IconButton(
                      icon: Image.asset(
                        "assets/icons/mana_r.png", 
                        height: iconSize, width: iconSize,
                        errorBuilder: (context, error, stackTrace){
                          return Icon(Icons.circle, color: Colors.red);
                      },),
                      
                      onPressed: () {
                        setState((){
                          colorFilter["R"] = !colorFilter["R"]!;
                        });
                      }
                    )
                  )
              ),

              Positioned(
                bottom: 0,
                left: 125,
                child: Opacity(
                    opacity: colorFilter['G']! ? 1 : 0.5,
                    child: IconButton(
                      icon: Image.asset(
                        "assets/icons/mana_g.png", 
                        height: iconSize, width: iconSize,
                        errorBuilder: (context, error, stackTrace){
                          return Icon(Icons.circle, color: Colors.green);
                      },),
                      
                      onPressed: () {
                        setState((){
                          colorFilter["G"] = !colorFilter["G"]!;
                        });
                      }
                    )
                  )
              ),


            
            //Options Bar

              Positioned(
                bottom: 0,
                right: 30,
                child: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      if(cardsPerRow + 1 <= maxCardsPerRow){
                        cardsPerRow++;
                      }
                    });
                  }
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: () {
                  setState(() {
                    if(cardsPerRow - 1 >= minCardsPerRow){
                      cardsPerRow--;
                    }
                  });
                }
              ),
              ),

              Positioned(
                bottom: 0,
                right: 65,
                child: IconButton(
                  icon: revSort ? Icon(Icons.arrow_downward_rounded) : Icon(Icons.arrow_upward_rounded),
                  onPressed: () {setState(() {
                    revSort = !revSort;
                    cardData = sortCardData(currentSortString, cardData!);
                  });},
                ),),

              Positioned(
                bottom: 0,
                right: 100,
                height: 40,
                child: DropdownButton(
                  value: currentSortString,
                  items: sortList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  
                  onChanged: (value) {setState(() {
                    currentSortString = value!;
                    if(cardData != null){cardData = sortCardData(value, cardData!);}
                    });
                  },
                  
                  )
              ),

              
            ]

          ))
        ),

        SizedBox(height: 25),

        Builder(builder: (context) {
          if (cardData != null) {
            return buildSearchResults(cardData!);
          } else {
            return Text('No card data available.');
          }
        }),
      ]
    );
  }

}

Map<String, bool> colorFilter = {
  "C" : true,
  "W" : true,
  "U" : true,
  "B" : true,
  "R" : true,
  "G" : true
};

final int minCardsPerRow = 1;
final int maxCardsPerRow = 5;
int cardsPerRow = 2;
double heightToWidthRatio = 63/88;

Widget buildSearchResults(Map<String, dynamic> cardData) {

  List<dynamic> filteredData = List.from(cardData['data']);

 for(var card in cardData['data']){

  if(card['color_identity'].isEmpty && !colorFilter["C"]!){
    filteredData.remove(card);
    continue;
  }

  for(String color in card['color_identity']){


    if(!colorFilter[color]!){
      filteredData.remove(card);
      continue;
    }
  }
 }

    return 
    Expanded(
      child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cardsPerRow,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: heightToWidthRatio,
          ),
        itemCount: filteredData.length,
        itemBuilder: (context, index){
          return MagicCard(filteredData[index]);
        }
      ),
    )
  );
}





enum Mode {
  flip, 
  twoSided,
  normal}


class MagicCard extends StatefulWidget {
  final Map<String, dynamic> cardData;

  late String layout;
  Mode cardMode = Mode.normal;

  MagicCard(this.cardData, {super.key}) : layout = cardData['layout'] ?? 'normal' {
    layout = cardData['layout'];
  }

  @override
  MagicCardState createState() => MagicCardState();
}


class MagicCardState extends State<MagicCard> {
  bool frontFaced = true;

  @override
  Widget build(BuildContext context) {

    // Initialize the image URLs with null safety checks
    final layout = widget.cardData['layout'];
    String imageUrl;

    switch(layout){
      case "flip": 
      imageUrl =  widget.cardData['image_uris']['normal']; 
      widget.cardMode = Mode.flip; break;

      case "transform": 
      case "modal_dfc": 
      case "reversible_card":
        imageUrl = widget.cardData['card_faces'][(frontFaced ? 0 : 1)]['image_uris']['normal']; 
        widget.cardMode = Mode.twoSided; break;

      default: 
        imageUrl = widget.cardData['image_uris']['normal']; 
        break;
    }
    
    return Stack(
      children: [

        Positioned(
          child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationZ((!frontFaced && widget.cardMode == Mode.flip) ? 3.141592 : 0),
          child: (imageUrl != null) ? 

            Image.network(imageUrl!): 

            Center(child: Text('No image available',style: TextStyle(color: Colors.grey))),
        )),

        Positioned(
          top: 110,
          right: 19,
          
            child: (widget.cardMode != Mode.normal)
                ? 
                Container(
                  
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3)
                  ),

                  child: IconButton(
                      icon: Icon(Icons.rotate_left),
                      color: Colors.white,
                      iconSize: 20,
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          frontFaced = !frontFaced;
                        });
                      },
                    ))
                : SizedBox.shrink(),
          )
      ],
    );
  }
}

String currentSortString = "Name";
bool revSort = true;

final sortList = [
  "Name", 
  "EDHRec Rank", 
  "Price",
  "Mana Cost",
  "Color",
  "Rarity",
  "Set"];

  //TODO: RECURSIVE SORT 
  //PRIMARY SORTING -> RELEASE DATE -> COLLECTOR NUMBER

Map<String, dynamic> sortCardData(String value, Map<String, dynamic> cardData) {
  switch (value) {
    case "Name":
      cardData['data'].sort((a, b) {
        String nameA = a['name'] ?? a['card_faces']?[0]['name'] ?? '';
        String nameB = b['name'] ?? b['card_faces']?[0]['name'] ?? '';
        return revSort ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
      });
      break;

    case "EDHRec Rank":
      cardData['data'].sort((a, b) {
        int rankA = a['edhrec_rank'] ?? a['card_faces']?[0]['edhrec_rank'] ?? 999999;
        int rankB = b['edhrec_rank'] ?? b['card_faces']?[0]['edhrec_rank'] ?? 999999;
        return revSort ? rankA.compareTo(rankB) : rankB.compareTo(rankA);
      });
      break;

    case "Price":
      cardData['data'].sort((a, b) {
        double priceA = double.tryParse(a['prices']?['usd'] ?? a['card_faces']?[0]['prices']?['usd'] ?? '0') ?? 0.0;
        double priceB = double.tryParse(b['prices']?['usd'] ?? b['card_faces']?[0]['prices']?['usd'] ?? '0') ?? 0.0;
        return revSort ? priceB.compareTo(priceA) : priceA.compareTo(priceB);
      });
      break;

    case "Mana Cost":
      cardData['data'].sort((a, b) {
        double cmcA = a['cmc'] ?? a['card_faces']?[0]['cmc'] ?? 0.0;
        double cmcB = b['cmc'] ?? b['card_faces']?[0]['cmc'] ?? 0.0;
        return revSort ? cmcA.compareTo(cmcB) : cmcB.compareTo(cmcA);
      });
      break;

    case "Color":
      cardData['data'].sort((a, b) {
        List<dynamic> colorA = a['colors'] ?? a['card_faces']?[0]['colors'] ?? [];
        List<dynamic> colorB = b['colors'] ?? b['card_faces']?[0]['colors'] ?? [];
        return revSort ? compareWUBRG(colorA, colorB) : compareWUBRG(colorB, colorA);
      });
      break;

    case "Rarity":
      cardData['data'].sort((a, b) {
        String rarityA = a['rarity'] ?? a['card_faces']?[0]['rarity'] ?? [];
        String rarityB = b['rarity'] ?? b['card_faces']?[0]['rarity'] ?? [];
        return revSort ? compareRarity(rarityA, rarityB) : compareRarity(rarityB, rarityA);
      });
      break;

    case "Set":
      cardData['data'].sort((a, b) {
        String setA = a['released_at'] ?? a['card_faces']?[0]['released_at'] ?? [];
        String setB = b['released_at'] ?? b['card_faces']?[0]['released_at'] ?? [];
        return revSort ? setA.compareTo(setB) : setB.compareTo(setA);
      });
      break;
  }

  return cardData;
}

int compareRarity(String _rarityA, String _rarityB){

  const Map<String, int> rarityPriority = {
    "common": 0,
    "uncommon" : 1,
    "rare": 2,
    "mythic": 3,
    "special": 4,
    "bonus" : 5
  };

  return rarityPriority[_rarityA]! - rarityPriority[_rarityB]!;
}

int compareWUBRG(List<dynamic> _colorA, List<dynamic> _colorB){

  const Map<String, int> colorPriority = {
    "" : 0, //Colorless
    "W": 1, //White
    "U": 2, //Blue
    "B": 3, //Black
    "R": 4, //Red
    "G": 5, //Green

    "WU": 6, //Azorius
    "UB": 7, //Dimir
    "BR": 8, //Rakdos
    "RG": 9, //Gruul
    "WG": 10, //Selesnya

    "WB": 11, //Orzhov
    "UR": 12, //Izzet
    "BG": 13, //Golgari
    "WR": 14, //Boros
    "UG": 15, //Simic

    "WUB": 16, //Esper
    "UBR": 17, //Grixis
    "BRG": 18, //Jund
    "WRG": 19, //Naya
    "WUG": 20, //Bant

    "WUR": 21, //Jeskai
    "UBG": 22, //Sultai
    "WBR": 23, //Mardu
    "URG": 24, //Temur
    "WBG": 25, //Abzan

    "WUBR" : 26, //Yore-Tiller
    "UBRG" : 27, //Glint-Eye
    "WBRG" : 28, //Dune-Brood
    "WURG" : 29, //Ink-Treader
    "WUBG" : 30,  //Witch-Maw

    "WUBRG" : 31 //WUBRG
  };

  List<String> sortColors(List<dynamic> colors){
    return colors.map((colors) => colors.toString()).toList()
    ..sort((a, b) => (colorPriority[a] ?? 999).compareTo(colorPriority[b] ?? 999));
  }

  String colorA = sortColors(_colorA).join();
  String colorB = sortColors(_colorB).join();

  return colorPriority[colorA]! - colorPriority[colorB]!;
}
