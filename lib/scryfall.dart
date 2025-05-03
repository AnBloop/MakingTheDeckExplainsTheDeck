import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String baseUrl = 'https://api.scryfall.com/cards/search?q=';

Future<Map<String, dynamic>> fetchCard(String query) async {
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