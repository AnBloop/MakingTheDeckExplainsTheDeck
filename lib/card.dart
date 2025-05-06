import 'package:flutter/material.dart';
import 'scryfall.dart';
import 'main.dart';
import 'deck_builder.dart';

class MCard {
  late final String id;
  final Map<String, dynamic> cardData;
  late final String layout;
  late final Mode cardMode;
  late final String imageURI;
  late final String imageBackURI;
  late final String cardType;

  bool isCommander = false;
  bool isSideboard = false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  MCard(this.cardData){
    layout = cardData['layout'] ?? 'normal';
    id = cardData['id'];
    cardType = classifyCard(this);

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
}

  String getImageURI({bool isFront=true}){
    if(isFront)
    {return imageURI;}
    else
    {return imageBackURI;}
  }

  String getTypeline(){
    return cardData['type_line'];
  }

  String getName(){return cardData['name'];}

  double getCMC(){
    return cardData['cmc'];
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
              onPressed: () {addCard(widget.card.id);},
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
  
  CardWidgetForDeckBuilder(this.card, this.cardQuantity);

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
              onPressed: () {addCard(widget.card.id);},
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
              onPressed: () {removeCard(widget.card.id);},
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
      ))

    ],
    color: Colors.black.withOpacity(0.3));
}