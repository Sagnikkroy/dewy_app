import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';

class SearchService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> performHybridSearch(String query) async {
    try {
      // 1. Get Embedding from Gemini
      final vector = await _getGeminiEmbedding(query);

      // 2. Call the Hybrid Search RPC in Supabase
      final List<dynamic> response = await _supabase.rpc(
        'hybrid_search_products',
        params: {
          'query_text': query,
          'query_embedding': vector,
          'match_count': 12,
        },
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Search Service Error: $e');
      return [];
    }
  }

  Future<List<double>> _getGeminiEmbedding(String text) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=${AppConfig.geminiApiKey}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'models/text-embedding-004',
        'content': { 'parts': [{'text': text}] },
        'output_dimensionality': 768, 
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return List<double>.from(json['embedding']['values']);
    } else {
      throw Exception('Gemini Error: ${response.body}');
    }
  }
}