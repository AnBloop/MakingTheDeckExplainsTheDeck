import 'package:flutter/material.dart';
import 'dart:convert';
import 'card.dart';
import 'package:http/http.dart' as http;

String baseUrl = 'https://api.scryfall.com/cards/search?q=';

Future<Map<String, dynamic>> fetchCard(String query) async {

  query = parseQuery(query);

  final url = Uri.parse(baseUrl+query);
  final response = await http.get(url);

  if(response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data;
  }
  else {
    throw Exception('Failed to load card data');
  }
}

String getCardURL = "https://api.scryfall.com/cards/";

Future<MCard> getCardFromID(String id) async{
  
  final url = Uri.parse("$getCardURL$id");
  final response = await http.get(url);

  if(response.statusCode == 200){
    final data = json.decode(response.body);
    return MCard(data);
  }else {
    throw Exception('Failed to load card data');
  }
}



Future<MCard> getCardFromJson(Map<String, dynamic> json) async {
  MCard card = await getCardFromID(json['id']);
  card.isCommander = json['isCommander'];
  card.isSideboard = json['isSideboard'];
  card.defaultFrontFace = json['defaultFrontFace'];
  
  return card;
}


//Scryfall Desugarer
String parseQuery(String q){
  List<String> tokens = q.split(',');

  List<MapEntry<String, String>> queryMap = [];

  //Query Parser
  for(String token in tokens){
    List<String> parts = token.split(":");
    if(parts.length == 2) {
      String command = parts[0].toLowerCase();
      String argument = parts[1].trim().toLowerCase();

      queryMap.add(MapEntry(command, argument));
    }else if(parts.length == 1){
      String command = parts[0].toLowerCase();
      String argument = parts[0].trim().toLowerCase();

      queryMap.add(MapEntry(command, argument));
    }
  }

  print("Query Map: $queryMap");

  String scryfallQuery = "game:paper ";

  //Query Builder
  for(MapEntry<String, String> pair in queryMap){

    String command = pair.key;
    String arg = pair.value;
    List<String> commandTokens = command.toLowerCase().split(" ");
    commandTokens.removeWhere((token) => token == "");
    bool negation = false;

    String addition = "";
    String compSign = "=";

    String duallandGuildString = "t:land -o:\"any color\"";

    if(commandTokens.length == 1){
      command = commandTokens[0];
    }else if(commandTokens[0] == "not"){
      command = commandTokens[1];
      negation = true;
    }else if(commandTokens[1] == "<" || commandTokens[1] == ">" || commandTokens[1] == "=<" || commandTokens[1] == ">="){
      compSign = commandTokens[1];
      command = commandTokens[0];
    }

    print("Command Tokens: $commandTokens - Argument: $arg");


    switch(command){

      //filter keywords
      case "t": case "type": 
      addition = "t:$arg"; break;
      case "mana": case "cost": 
      addition = "mv$compSign$arg"; break;
      case "color":
      addition = "color$compSign$arg"; break;
      case "identity":
      addition = "color>=$arg"; break;
      case "set":
      addition = "set:$arg"; break;
      case "ability":
      addition = "full-oracle:\"$arg\""; break;
      case "keyword":
      addition = "kw:$arg"; break;
      case "rarity":
      addition = "rarity$compSign$arg"; break;
      case "is": case "tag":
      addition = "function:$arg is:$arg"; break;
      case "price":
      addition = "usd$compSign$arg"; break;
      case "flavor":
      addition = "art:$arg wm:$arg"; break;
      case "name":
      addition = "!$arg"; break;

      //Helpful Land Searching
      case "dualland":
        switch(arg){
          case "fetch": 
          addition = "is:fetchland"; break;
          case "shock": 
          addition = "is:shockland"; break;
          case "cycle": 
          addition = "is:bikeland"; break;
          case "bounce": 
          addition = "is:bounceland"; break;
          case "cantrip": case "canopy":
          addition = "is:canland"; break;
          case "check":
          addition = "is:checkland"; break;
          case "classic": case "alpha": case "dual":
          addition = "is:dual"; break;
          case "fast": case "quick":
          addition = "is:fastland"; break;
          case "filter":
          addition = "is:filterland"; break;
          case "gain": case "life":
          addition = "is:gainland"; break;
          case "pain":
          addition = "is:painland"; break;
          case "scry":
          addition = "is:scryland"; break;
          case "reveal": case "snarl": case "shadow":
          addition = "is:shadowland"; break;
          case "storage":
          addition = "is:storageland"; break;
          case "creature": case "living":
          addition = "is:creatureland"; break;
          case "triland":
          addition = "is:triland"; break;
          case "tango": case "battle": case "commander":
          addition = "is:tangoland"; break;
          case "verge":
          addition = "verge t:land o:\"Activate only if you control a\""; break;
          case "unlucky":
          addition = "o:\"enters tapped unless a player has 13 or less life\""; break;
        
          //Duals of a specific guild
          case "azorius": case "WU": case "UW": addition = "produces:{W}{U} $duallandGuildString"; break;
          case "dimir": case "BU": case "UB": addition = "produces:{B}{U} $duallandGuildString"; break;
          case "rakdos": case "BR": case "RB": addition = "produces:{R}{B} $duallandGuildString"; break;
          case "gruul": case "GR": case "RG": addition = "produces:{R}{G} $duallandGuildString"; break;
          case "selesnya": case "WG": case "GW": addition = "produces:{G}{W} $duallandGuildString"; break;

          case "orzhov": case "WB": case "BW": addition = "produces:{W}{B} $duallandGuildString"; break;
          case "boros": case "WR": case "RW": addition = "produces:{R}{W} $duallandGuildString"; break;
          case "izzet": case "RU": case "UR": addition = "produces:{R}{U} $duallandGuildString"; break;
          case "simic": case "UG": case "GU": addition = "produces:{G}{U} $duallandGuildString"; break;
          case "golgari": case "GB": case "BG": addition = "produces:{G}{B} $duallandGuildString"; break;

          //Duals for three color commanders
  

        }
        break;
      

      default: 
      //name when there is no arguments
        if(arg == command){addition = "name:$command";}
      //when it doubt just parse it directly
        else{addition = "$command:$arg";}
      break;
    }

    if(negation){
      addition = "-$addition";
    }

    scryfallQuery+="$addition ";
  }
  print("Scryfall Query: $scryfallQuery");
  return scryfallQuery;
}