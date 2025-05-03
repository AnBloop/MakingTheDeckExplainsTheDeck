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
                right: 100,
                height: 40,
                child: DropdownButton(
                  items: sortList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  
                  onChanged: (value) {setState(() {
                    sortCardData(value!, cardData!);
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

final int minCardsPerRow = 3;
final int maxCardsPerRow = 9;
int cardsPerRow = 6;
double heightToWidthRatio = 63/88;

Widget buildSearchResults(Map<String, dynamic> cardData) {
    return 
    Expanded(
      child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cardsPerRow,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: heightToWidthRatio,
          ),
        itemCount: cardData['data'].length,
        itemBuilder: (context, index){
          return MagicCard(cardData['data'][index]);
        }
      ),
    )
  );
}


class MagicCard extends StatefulWidget {
  final Map<String, dynamic> cardData;

  MagicCard(this.cardData);

  @override
  MagicCardState createState() => MagicCardState();
}

class MagicCardState extends State<MagicCard> {
  bool frontFaced = true;

  @override
  Widget build(BuildContext context) {

    // Initialize the image URLs with null safety checks
    final imageUrl = widget.cardData['image_uris']?['normal'];
    final doubleSideUrl = (widget.cardData['card_faces'] != null &&
            widget.cardData['card_faces'].isNotEmpty)
        ? widget.cardData['card_faces'][(frontFaced ? 0 : 1)]['image_uris']['normal']
        : null;
    
    return Stack(
      children: [

        Positioned(
          child: 
          (imageUrl != null) ? Image.network(imageUrl!): 
          (doubleSideUrl != null ? Image.network(doubleSideUrl!):
          Center(child: Text('No image available',style: TextStyle(color: Colors.grey),),
                    )),
        ),

        Positioned(
          top: 37,
          left: 19,
          
            child: (doubleSideUrl != null)
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

enum sortBy {
  name, 
  set,
  rarity,
  color,
  price,
  cmc,
  edhrec,
  }

sortBy currentSort = sortBy.name;
String currentSortString = "Name";

final sortList = [
  "Name", 
  "EDHRec Rank", 
  "Price",
  "Mana Cost",
  "Color",
  "Rarity",
  "Set"];

void sortCardData(String value, Map<String, dynamic> cardData) {

  switch (value) {
    case "Name":
      currentSort = sortBy.name;
      currentSortString = sortList[0];
      cardData['data'].sort((a, b) => a['name'].compareTo(b['name']));
      break;

    case "EDHRec Rank":
      currentSort = sortBy.edhrec;
      currentSortString = sortList[1];
      cardData['data'].sort((a, b) => a['edhrec_rank'].compareTo(b['edhrec_rank']));
      break;

    case "Price":
      currentSort = sortBy.price;
      currentSortString = sortList[2];
      cardData['data'].sort((a, b) => a['prices']['usd']?.compareTo(b['prices']['usd']) ?? 0);
      break;

    case "Mana Cost":
      currentSort = sortBy.cmc;
      currentSortString = sortList[3];
      cardData['data'].sort((a, b) => a['cmc'].compareTo(b['cmc']));
      break;

    case "Color":
      currentSort = sortBy.color;
      currentSortString = sortList[4];
      cardData['data'].sort((a, b) => a['colors'].toString().compareTo(b['colors'].toString()));
      break;

    case "Rarity":
      currentSort = sortBy.rarity;
      currentSortString = sortList[5];
      cardData['data'].sort((a, b) => a['rarity'].compareTo(b['rarity']));
      break;

    case "Set":
      currentSort = sortBy.set;
      currentSortString = sortList[6];
      cardData['data'].sort((a, b) => a['set_name'].compareTo(b['set_name']));
      break;

    default:
      break;
  }
}
