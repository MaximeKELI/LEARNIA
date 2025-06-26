import '../services/api_service.dart';
import '../services/config_service.dart';
import 'package:flutter/foundation.dart';

/// Helper pour faciliter l'intégration des APIs
class ApiIntegrationHelper {
  static final ApiIntegrationHelper _instance = ApiIntegrationHelper._internal();
  factory ApiIntegrationHelper() => _instance;
  ApiIntegrationHelper._internal();

  final ApiService _apiService = ApiService();

  /// Exemple d'intégration d'une API simple
  Future<Map<String, dynamic>> exampleApiCall() async {
    try {
      // Appel API simple
      final response = await _apiService.get('/example/endpoint');
      return response;
    } catch (e) {
      // Gestion d'erreur avec fallback
      return {'error': e.toString(), 'fallback': true};
    }
  }

  /// Template pour intégrer une nouvelle API d'IA
  Future<String> integrateNewAiApi({
    required String endpoint,
    required Map<String, dynamic> payload,
    String? fallbackResponse,
  }) async {
    try {
      final response = await _apiService.post(endpoint, body: payload);
      return response['result'] ?? fallbackResponse ?? 'Pas de réponse';
    } catch (e) {
      // Log de l'erreur pour debug
      debugPrint('Erreur API: $e');
      return fallbackResponse ?? 'Erreur de connexion';
    }
  }

  /// Template pour intégrer une API avec authentification
  Future<Map<String, dynamic>> authenticatedApiCall({
    required String endpoint,
    required String apiKey,
    Map<String, dynamic>? body,
  }) async {
    try {
      if (body != null) {
        return await _apiService.post(endpoint, body: body);
      } else {
        return await _apiService.get(endpoint);
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Template pour intégrer une API avec retry
  Future<Map<String, dynamic>> apiCallWithRetry({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        switch (method.toUpperCase()) {
          case 'GET':
            return await _apiService.get(endpoint);
          case 'POST':
            return await _apiService.post(endpoint, body: body);
          case 'PUT':
            return await _apiService.put(endpoint, body: body);
          case 'DELETE':
            return await _apiService.delete(endpoint);
          default:
            throw Exception('Méthode non supportée: $method');
        }
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          return {'error': 'Échec après $maxRetries tentatives: $e'};
        }
        // Attendre avant de réessayer
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    return {'error': 'Nombre maximum de tentatives atteint'};
  }

  /// Template pour intégrer une API avec cache
  final Map<String, dynamic> _cache = {};
  
  Future<Map<String, dynamic>> cachedApiCall({
    required String endpoint,
    required String cacheKey,
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    // Vérifier le cache
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      final timestamp = cached['timestamp'] as DateTime;
      
      if (DateTime.now().difference(timestamp) < cacheDuration) {
        return cached['data'] as Map<String, dynamic>;
      }
    }
    
    // Appel API
    try {
      final response = await _apiService.get(endpoint);
      
      // Mettre en cache
      _cache[cacheKey] = {
        'data': response,
        'timestamp': DateTime.now(),
      };
      
      return response;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Template pour intégrer une API avec validation
  Future<Map<String, dynamic>> validatedApiCall({
    required String endpoint,
    required Map<String, dynamic> payload,
    required List<String> requiredFields,
  }) async {
    // Validation des champs requis
    for (final field in requiredFields) {
      if (!payload.containsKey(field) || payload[field] == null) {
        return {'error': 'Champ requis manquant: $field'};
      }
    }
    
    try {
      return await _apiService.post(endpoint, body: payload);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Template pour intégrer une API avec transformation de données
  Future<List<Map<String, dynamic>>> transformApiResponse({
    required String endpoint,
    required String dataKey,
    required Map<String, String> fieldMapping,
  }) async {
    try {
      final response = await _apiService.get(endpoint);
      final rawData = response[dataKey] as List<dynamic>? ?? [];
      
      return rawData.map((item) {
        final transformed = <String, dynamic>{};
        for (final entry in fieldMapping.entries) {
          transformed[entry.value] = item[entry.key];
        }
        return transformed;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Exemples d'intégration spécifiques pour Learnia

  /// Intégration OpenAI
  Future<String> openaiIntegration(String prompt) async {
    return integrateNewAiApi(
      endpoint: '/ai/openai/chat',
      payload: {
        'prompt': prompt,
        'model': 'gpt-3.5-turbo',
        'max_tokens': 150,
      },
      fallbackResponse: 'Réponse locale générée',
    );
  }

  /// Intégration Hugging Face
  Future<Map<String, String>> huggingfaceTranslation(String text, String targetLang) async {
    try {
      final response = await _apiService.post(
        '/ai/huggingface/translate',
        body: {
          'text': text,
          'source_lang': 'fr',
          'target_lang': targetLang,
        },
      );
      
      return {
        'translated': response['translated_text'] ?? text,
        'confidence': response['confidence']?.toString() ?? '0.0',
      };
    } catch (e) {
      return {
        'translated': text,
        'confidence': '0.0',
        'error': e.toString(),
      };
    }
  }

  /// Intégration API locale
  Future<String> localAiIntegration(String input) async {
    return integrateNewAiApi(
      endpoint: '/ai/local/process',
      payload: {'input': input},
      fallbackResponse: 'Traitement local effectué',
    );
  }

  /// Configuration rapide d'une nouvelle API
  void configureNewApi({
    required String name,
    required String baseUrl,
    required String apiKey,
    Map<String, String>? headers,
  }) {
    // Cette méthode peut être étendue pour configurer dynamiquement les APIs
    debugPrint('Configuration de l\'API $name: $baseUrl');
  }

  /// Test de connectivité API
  Future<bool> testApiConnectivity(String endpoint) async {
    try {
      await _apiService.get(endpoint);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir les statistiques d'utilisation des APIs
  Map<String, dynamic> getApiStats() {
    return {
      'total_calls': 0, // À implémenter avec un compteur
      'successful_calls': 0,
      'failed_calls': 0,
      'average_response_time': 0.0,
    };
  }
}

/// Exemples d'utilisation pour les développeurs
class ApiIntegrationExamples {
  static void showExamples() {
    debugPrint('''
=== EXEMPLES D'INTÉGRATION API ===

1. Appel API simple:
   final helper = ApiIntegrationHelper();
   final result = await helper.exampleApiCall();

2. Intégration IA:
   final response = await helper.integrateNewAiApi(
     endpoint: '/ai/chat',
     payload: {'message': 'Hello'},
     fallbackResponse: 'Réponse locale',
   );

3. API avec authentification:
   final result = await helper.authenticatedApiCall(
     endpoint: '/secure/data',
     apiKey: 'your-api-key',
   );

4. API avec retry:
   final result = await helper.apiCallWithRetry(
     endpoint: '/unreliable/api',
     method: 'GET',
     maxRetries: 3,
   );

5. API avec cache:
   final result = await helper.cachedApiCall(
     endpoint: '/static/data',
     cacheKey: 'user_data',
   );

6. Validation de données:
   final result = await helper.validatedApiCall(
     endpoint: '/user/create',
     payload: {'name': 'John', 'email': 'john@example.com'},
     requiredFields: ['name', 'email'],
   );

7. Transformation de données:
   final users = await helper.transformApiResponse(
     endpoint: '/api/users',
     dataKey: 'users',
     fieldMapping: {'user_name': 'name', 'user_email': 'email'},
   );
''');
  }
} 