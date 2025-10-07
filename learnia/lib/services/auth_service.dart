import 'dart:convert';
import 'token_storage.dart';
import 'config_service.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ConfigService _config = ConfigService();
  final TokenStorage _tokenStorage = TokenStorage();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${_config.apiBaseUrl}/api/v1/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Stocker le token
      final token = data['access_token'];
      await _tokenStorage.saveToken(token);
      
      // Récupérer les informations utilisateur
      final userInfo = await getCurrentUser(token);
      _currentUser = userInfo;
      await _tokenStorage.saveUser(userInfo.toJson());
      
      return {
        'token': token,
        'user': userInfo.toJson(),
      };
    } else {
      throw Exception('Erreur de connexion: ${response.body}');
    }
  }

  Future<UserModel> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
    String? gradeLevel,
    String? school,
    String? phone,
  }) async {
    final url = Uri.parse('${_config.apiBaseUrl}/api/v1/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'full_name': fullName,
        'password': password,
        'grade_level': gradeLevel,
        'school': school,
        'phone': phone,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = UserModel.fromJson(data);
      return _currentUser!;
    } else {
      throw Exception('Erreur d\'inscription: ${response.body}');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _tokenStorage.logout();
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isLoggedIn();
  }

  /// Récupère le token actuel
  Future<String?> getCurrentToken() async {
    return await _tokenStorage.getToken();
  }

  /// Initialise l'utilisateur depuis le stockage local
  Future<void> initializeUser() async {
    final userData = await _tokenStorage.getUser();
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
    }
  }

  Future<UserModel> getCurrentUser(String token) async {
    final url = Uri.parse('${_config.apiBaseUrl}/api/v1/auth/me');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = UserModel.fromJson(data);
      return _currentUser!;
    } else {
      throw Exception('Erreur de récupération du profil: ${response.body}');
    }
  }

  Future<UserModel> fetchProfile(String token) async {
    return getCurrentUser(token);
  }
} 