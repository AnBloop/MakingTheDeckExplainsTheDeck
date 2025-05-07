
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'card.dart';
import 'deck_builder.dart';
import 'search.dart';
import 'scryfall.dart';

enum Format {
  standard,
  commander,
  pauper,
  none
}

Format stringToFormat(String value) {
  return Format.values.firstWhere(
    (format) => formatToString(format).toLowerCase() == value.toLowerCase(),
    orElse: () => Format.none,
  );
}

String formatToString(Format f){
  switch(f){
    case Format.standard: return "Standard";
    case Format.commander: return "Commander";
    case Format.pauper: return "Pauper";
    default: return "WIP";
  }
}

const double iconSize = 20;
const double iconSpacing = 2;

Widget identityToIcons(List<String> identity){
  return Row(
    children: identity.map((symbol) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: iconSpacing),
        child: Image.asset(
          'assets/icons/mana_${symbol.toLowerCase()}.png',
          width: iconSize,
          height: iconSize
        )
      );
    }).toList()
  );
}

class Deck {

  late String deckName;
  late Map<MCard, int> deckList;
  late Format deckFormat;
  List<String> deckIdentity = [];
  final String id;

  Deck({
    required this.deckName,
    required this.deckFormat,
    this.deckList = const {},
    this.deckIdentity = const [],
    String? id,
  }) : id = id ?? Uuid().v4() {
    deckIdentity = getDeckIdentity(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deck &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson(){
    return {
      "id" : id,
      "name" : deckName,
      "format" : formatToString(deckFormat),
      "deck_list": deckList.entries.map((entry) => {
        "card": entry.key.toJson(),
        "quantity": entry.value
      }).toList()
    };
  }
}

Future<Deck> getDeckFromJson(Map<String, dynamic> deckData) async {
  Map<MCard, int> deck_list = {};

  for (var item in deckData['deck_list']) {
    MCard card = await getCardFromJson(item['card']);
    int quantity = item['quantity'];
    deck_list[card] = quantity;
  }

  Deck deck = Deck(
    deckName: deckData['name'],
    id: deckData['id'],
    deckFormat: stringToFormat(deckData['format']), // Assuming you have a reverse function
    deckList: deck_list,
  );

  return deck;
}


class deckSelectionWidget extends StatefulWidget{

  final List<Deck> decks;

  deckSelectionWidget(this.decks);
  
  @override
  State<StatefulWidget> createState() => _deckSelectionWidgetState();
}

class _deckSelectionWidgetState extends State<deckSelectionWidget>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(apptitle)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children:[
          Expanded(child:
            ListView.builder(
              itemCount: widget.decks.length+1,
              itemBuilder: (context, index){
                if(index < widget.decks.length){
                  Deck deck = decks[index];
                  return deckNameplateWidget(deck, ((){setState((){saveDecks();});}));
                }else{
                  return ElevatedButton.icon(
                    label: Text("New Deck"),
                    icon: Icon(Icons.add, color: Colors.green),
                    onPressed: (){
                      setState((){
                        decks.add(Deck(deckName: "New Deck", deckFormat: Format.none));
                        saveDecks();
                      });
                    });
                }
              }
            )
          ),

        ]
      )
    );
  }
}

class deckNameplateWidget extends StatelessWidget{

  late final Deck deck;
  late final VoidCallback onUpdate;
  final double padding = 16;

  deckNameplateWidget(this.deck, this.onUpdate);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
          child: Stack(
            children: [

              Positioned(
                top: padding,
                left: padding,
                child: Text(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  deck.deckName
                  )),

              Positioned(
                bottom: padding,
                left: padding,
                child: 
                  Text(
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    formatToString(deck.deckFormat)
                    ),
                ),

              Positioned(
                bottom: padding,
                right: padding,
                child: identityToIcons(deck.deckIdentity)
              ),

              
              Positioned(
                child: GestureDetector(
                  onTap: () {
                    baseplateKey.currentState?.update(
                        newWidget: deckEditorWidget(deck)
                    );
                    onUpdate();
                  }
                )
              ),

              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.settings),
                  iconSize: 20,
                  onPressed: ((){
                    deckOptions(context, deck, onUpdate);}),
                )
                )
            ],
          )
      )
    );
  }
}

class deckEditorWidget extends StatelessWidget{

  Deck deck;

  deckEditorWidget(this.deck);

  Widget build(BuildContext context){

    TextEditingController deckNameController = TextEditingController(text: deck.deckName);

    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: deckNameController,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            onSubmitted: (value){
              deck.deckName = value;
            },
          ),
        ),
        body: Center(
          child: PageView(
            scrollDirection: Axis.horizontal,
            children: [
              DeckBuilderWidget(deck),
              CardSearchWidget(),
              ],
        ),
      ),
    );
  }
}

void deckOptions(BuildContext context, Deck deck, VoidCallback onUpdate){
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            //Edit Deck Name
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit Deck Name"),
              onTap: () {
                editDeckName(deck, context, onUpdate);
              },
            ),

            //Change Format
            ListTile(
              leading: Icon(Icons.change_circle),
              title: Text("Change Deck Format"),
              onTap: () {
                editDeckFormat(deck, context, onUpdate);
              },
            ),

            //Delete Deck
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Delete Deck", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                decks.remove(deck);
                onUpdate();
              },
            ),

            //DEBUG ONLY 
            /*
            ListTile(
              leading: Icon(Icons.javascript_outlined, color: Colors.black),
              title: Text("Deck to Json", style: TextStyle(color: Colors.black)),
              onTap: () {
                print(deck.toJson());
              },
            ),
            */
          ],
        ),
      );
    },
  );
}

void editDeckName(Deck deck, BuildContext context, VoidCallback onUpdate){

  TextEditingController controller = TextEditingController(text: deck.deckName);

  showDialog(
    context: context,
    builder: (context){
      return AlertDialog(
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  deck.deckName = controller.text;
                  Navigator.pop(context);
                  onUpdate();
                  })
            ),
            onSubmitted: (text) {
              deck.deckName = text;
              saveDecks();
              onUpdate();
            },
          )
        );
    }
  );
}

void editDeckFormat(Deck deck,  BuildContext context, VoidCallback onUpdate){
  showDialog(
    context: context,
    builder: (context){
      return AlertDialog(
        content: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value : formatToString(deck.deckFormat),
            items: Format.values.map((Format val) {
                return DropdownMenuItem<String>(
                  value: formatToString(val), // Value to be selected
                  child: Text(formatToString(val)), // Text to display
                );
              }).toList(),
            onChanged: (value){
              deck.deckFormat = stringToFormat(value!);
              saveDecks();
              onUpdate();
            }
        )
        )
      );
    }
  );
}