import 'package:cs442_mp6/scryfall.dart';
import 'package:flutter/material.dart';
import 'deck_builder.dart';
import 'deck_selection.dart';

class MCard {
  late final String id;
  final Map<String, dynamic> cardData;
  late final String layout;
  late final Mode cardMode;
  late final String imageURI;
  late final String imageBackURI;
  late String cardType;

  bool isCommander = false;
  bool isSideboard = false;
  bool defaultFrontFace = true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  MCard(this.cardData, {ic = false, si = false, dff = true}){

    isCommander = ic;
    isSideboard = si;
    defaultFrontFace = dff;

    layout = cardData['layout'] ?? 'normal';
    id = cardData['id'];

    switch (layout) {
      case "flip":
        imageURI = cardData['image_uris']['normal'];
        imageBackURI = imageURI;
        cardMode = Mode.flip;
        break;
      case "transform":
      case "modal_dfc":
      case "reversible_card":
        var faces = cardData['card_faces'];
        imageURI = faces[0]['image_uris']['normal'];
        imageBackURI = faces[1]['image_uris']['normal'];
        cardMode = Mode.twoSided;
        break;
      default:
        imageURI = cardData['image_uris']['normal'];
        imageBackURI = imageURI;
        cardMode = Mode.normal;
        break;
   }

    cardType = classifyCard(this);
}

  String getImageURI({bool isFront=true}){

    if(!defaultFrontFace){isFront = !isFront;}

    if(isFront)
    {return imageURI;}
    else
    {return imageBackURI;}
  }

  String getTypeline(){
    return cardMode == Mode.normal ? cardData['type_line'] : cardData['card_faces'][defaultFrontFace ? 0 : 1]['type_line'];
  }

  String getName(){return cardData['name'];}

  double getCMC(){
    return cardData['cmc'];
  }

  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "isCommander" : isCommander,
      "isSideboard" : isSideboard,
      "defaultFrontFace" : defaultFrontFace
    };
  }
  
}



enum Mode {
  flip, 
  twoSided,
  normal}


class CardWidgetForSearch extends StatefulWidget {
  final MCard card;

  CardWidgetForSearch(this.card);

  @override
  _CardWidgetForSearchState createState() => _CardWidgetForSearchState();
}

class _CardWidgetForSearchState extends State<CardWidgetForSearch> {
  bool frontFaced = true;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {

    String imageUrl = widget.card.getImageURI(isFront: frontFaced);
    
    return Stack(
      children: [

        //Card image
        Positioned(
          child: GestureDetector(

            onTap: () {print("Card Name: ${widget.card.getName()}");},

            child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ((!frontFaced && widget.card.cardMode == Mode.flip) ? 3.141592 : 0),
            child: Image.network(imageUrl)
            
        ))),


      //Add Card Button
       Positioned(
        top: 5,
        right: 5,
        height: 50,
        width: 50,
        child: isHovered
             ? ElevatedButton(
              onPressed: () {
                deckViewerKey.currentState?.setState((){
                  addCard(widget.card);
                });
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.zero,
              ),
              child: Center(child: Icon(Icons.add, color: Colors.white, size: 30)))
            : SizedBox.shrink(),
       ),


        //Mouse region to test for hover
        Positioned(
            child: MouseRegion(
              onEnter: (_) => setState(() {isHovered = true;}),
              onExit: (_) => setState(() {isHovered = false;}),
              hitTestBehavior: HitTestBehavior.translucent,
              child: Container()
            ),
        ),

        //Flip button for double faced cards
        Positioned(
          top: 110,
          right: 19,
          
            child: (widget.card.cardMode != Mode.normal)
                ? 
                Container(
                  
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3)
                  ),

                  child: IconButton(
                      icon: Icon(Icons.rotate_left),
                      color: Colors.white,
                      iconSize: 30,
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

class CardWidgetForDeckBuilder extends StatefulWidget {
  final MCard card;
  final int cardQuantity;
  final Format deckFormat;
  
  CardWidgetForDeckBuilder(this.card, this.cardQuantity, this.deckFormat);

  @override
  _CardWidgetForDeckBuilderState createState() => _CardWidgetForDeckBuilderState();
}

class _CardWidgetForDeckBuilderState extends State<CardWidgetForDeckBuilder>{
  bool frontFaced = true;
  bool isHovered = false;


  @override
  Widget build(BuildContext context) {

    String imageUrl = widget.card.getImageURI(isFront: frontFaced);
    
    return Stack(
      children: [

        //Card image
        Positioned(
          child: GestureDetector(

            onTap: () {print("Card Name: ${widget.card.getName()}");},

            child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ((!frontFaced && widget.card.cardMode == Mode.flip) ? 3.141592 : 0),
            child: Image.network(imageUrl)
            
        ))),


      //Add Card Button
      Positioned(
        top: 5,
        right: 5,
        height: 20,
        width: 20,
        child: isHovered
            ? ElevatedButton(
              onPressed: () {
                deckViewerKey.currentState?.setState((){
                  addCard(widget.card);
                });
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.zero,
              ),
              child: Center(child: Icon(Icons.add, color: Colors.white, size: 15)))
            : SizedBox.shrink(),
      ),

      //Sub Card Button
      Positioned(
        top: 30,
        right: 5,
        height: 20,
        width: 20,
        child: isHovered
            ? ElevatedButton(
              onPressed: () {
                deckViewerKey.currentState?.setState((){
                  removeCard(widget.card);
                });
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.zero,
              ),
              child: Center(child: Icon(Icons.remove, color: Colors.white, size: 15)))
            : SizedBox.shrink(),
      ),


      //Extra card options
      Positioned(
        top: 55,
        right: 5,
        height: 20,
        width: 20,
        child: isHovered
            ? ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: EdgeInsets.zero,
              ),
              child: GestureDetector(
                onTapDown: (TapDownDetails details){
                  cardExtraOptions(widget.card, details, context);
                },
                child: Center(child: Icon(Icons.arrow_right, color: Colors.white, size: 15)))
              )
            : SizedBox.shrink(),
      ),

      //Card Count
      Positioned(
        bottom: 0,
        left: 38,
        height: 20,
        width: 20,
        child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.zero,
              child: Center(child: 
              Text(
                "${widget.cardQuantity}", 
                style: TextStyle(
                  color: Colors.white.withOpacity(1))
                  )
                )
              )
      ),

      //Mouse region to test for hover
      Positioned(
          child: MouseRegion(
            onEnter: (_) => setState(() {isHovered = true;}),
            onExit: (_) => setState(() {isHovered = false;}),
            hitTestBehavior: HitTestBehavior.translucent,
            child: Container()
          ),
      ),

      //Flip button for double faced cards
      Positioned(
          bottom: 0,
          left: 0,
          
            child: (widget.card.cardMode != Mode.normal)
                ? 
                Container(
                  
                  height: 20,
                  width: 20,
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
          ),
      
      //Error for illegal cards
      Positioned(
        top: 0,
        left: 0,
        child: 
        cardIsLegalIn(widget.card, widget.deckFormat) ? SizedBox.shrink() :
        Icon(Icons.error,
          color: Colors.red,
        )
      )
      
      ],
    );
  }
    
}

void cardExtraOptions(MCard card, TapDownDetails details, BuildContext context){
  final position = details.globalPosition;

  showMenu(
    context: context, 
    position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
    items: [

    if(!card.isSideboard)
      PopupMenuItem(child: Center(
        child: ElevatedButton(
          onPressed: ((){toggleCommander(card); Navigator.pop(context);}), 
          child:Text(card.isCommander ? "Unset Commander" : "Set as Commander", ))
      )),

    if(!card.isCommander)
      PopupMenuItem(child: card.isCommander ? SizedBox.shrink() : Center(
        child: ElevatedButton(
          onPressed: ((){toggleSideboard(card); Navigator.pop(context);}), 
          child:Text(card.isSideboard ? "Move to Mainboard" : "Move to Sideboard"))
      )),

    if(card.cardMode != Mode.normal)
      PopupMenuItem(child: Center(
        child: ElevatedButton(
          onPressed: ((){deckViewerKey.currentState!.setState((){card.defaultFrontFace = !card.defaultFrontFace; updateCardPosition(card); Navigator.pop(context);});}), 
          child:Text("Treat as flip side"))
      ))

      
    ],
    color: Colors.black.withOpacity(0.3));
}

bool cardIsLegalIn(MCard card, Format format){

  if(format == Format.none) {return true;}

  if(card.cardData['legalities'][formatToString(format).toLowerCase()] == "legal"){
    return true;
  }
  return false;
}