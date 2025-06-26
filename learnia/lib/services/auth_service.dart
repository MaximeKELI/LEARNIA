import 'dart:convert';
import 'config_service.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ConfigService _config = ConfigService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel> login(String email, String password) async {
    final url = Uri.parse('${_config.apiBaseUrl}/api/v1/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = UserModel.fromJson(data['user'] ?? data);
      return _currentUser!;
    } else {
      throw Exception('Erreur de connexion: ${response.body}');
    }
  }

  Future<UserModel> register({
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    required String password,
    String? phone,
  }) async {
    final url = Uri.parse('${_config.apiBaseUrl}/api/v1/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'phone': phone,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = UserModel.fromJson(data['user'] ?? data);
      return _currentUser!;
    } else {
      throw Exception('Erreur d\'inscription: ${response.body}');
    }
  }

  void logout() {
    _currentUser = null;
  }

  Future<UserModel> fetchProfile(String token) async {
    final url = Uri.parse('${_config.apiBaseUrl}/api/v1/auth/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _currentUser = UserModel.fromJson(data['user'] ?? data);
      return _currentUser!;
    } else {
      throw Exception('Erreur de récupération du profil: ${response.body}');
    }
  }
} 