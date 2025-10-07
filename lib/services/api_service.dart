import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Token d'authentification
  String? _authToken;

  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Configuration du token d'authentification
  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Headers avec authentification
  Map<String, String> get _headers {
    final headers = Map<String, String>.from(defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Méthode GET
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .get(url, headers: _headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erreur GET $endpoint: $e');
    }
  }

  // Méthode POST
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            url,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erreur POST $endpoint: $e');
    }
  }

  // Méthode PUT
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            url,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erreur PUT $endpoint: $e');
    }
  }

  // Méthode DELETE
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(url, headers: _headers)
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erreur DELETE $endpoint: $e');
    }
  }

  // Gestion des réponses
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('API Response: ${response.statusCode} - ${response.body}');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException('Requête invalide');
      case 401:
        throw UnauthorizedException('Non autorisé');
      case 403:
        throw ForbiddenException('Accès interdit');
      case 404:
        throw NotFoundException('Ressource non trouvée');
      case 500:
        throw ServerException('Erreur serveur');
      default:
        throw ApiException('Erreur inattendue: ${response.statusCode}');
    }
  }

  // Vérification de la connectivité
  Future<bool> checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/../health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Exceptions personnalisées
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
