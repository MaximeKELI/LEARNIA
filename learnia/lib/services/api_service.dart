import 'dart:convert';
import 'config_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final ConfigService _config = ConfigService();

  // Méthode générique pour les requêtes HTTP
  Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${_config.apiBaseUrl}$endpoint').replace(queryParameters: queryParams);
      
      final requestHeaders = {..._getDefaultHeaders(), ...?headers};
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders).timeout(
            Duration(seconds: _config.defaultTimeout),
          );
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(Duration(seconds: _config.defaultTimeout));
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(Duration(seconds: _config.defaultTimeout));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders).timeout(
            Duration(seconds: _config.defaultTimeout),
          );
          break;
        default:
          throw Exception('Méthode HTTP non supportée: $method');
      }

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erreur de connexion: $e');
    }
  }

  Map<String, String> _getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Learnia/1.0.0',
      'X-Environment': _config.environment,
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Erreur de parsing JSON: $e');
      }
    } else {
      throw ApiException(
        'Erreur HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // Méthodes publiques pour les différentes APIs
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) {
    return _makeRequest(
      endpoint: endpoint,
      method: 'GET',
      queryParams: queryParams,
    );
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) {
    return _makeRequest(
      endpoint: endpoint,
      method: 'POST',
      body: body,
    );
  }

  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) {
    return _makeRequest(
      endpoint: endpoint,
      method: 'PUT',
      body: body,
    );
  }

  Future<Map<String, dynamic>> delete(String endpoint) {
    return _makeRequest(
      endpoint: endpoint,
      method: 'DELETE',
    );
  }

  // Méthodes spécialisées pour les APIs d'IA
  Future<Map<String, dynamic>> aiRequest({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    return _makeRequest(
      endpoint: endpoint,
      method: 'POST',
      body: payload,
      headers: {
        'X-AI-Timeout': _config.aiTimeout.toString(),
      },
    );
  }

  // Méthode pour les requêtes avec authentification
  Future<Map<String, dynamic>> authenticatedRequest({
    required String endpoint,
    required String token,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    return _makeRequest(
      endpoint: endpoint,
      method: method,
      body: body,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Méthode pour les requêtes avec token JWT
  Future<Map<String, dynamic>> jwtRequest({
    required String endpoint,
    required String token,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    return _makeRequest(
      endpoint: endpoint,
      method: method,
      body: body,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
} 