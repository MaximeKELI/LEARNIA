import 'api_service.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  User? _currentUser;
  bool _isLoggedIn = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // Inscription
  Future<AuthResult> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
    String? gradeLevel,
    String? school,
    String? phone,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', body: {
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
        'grade_level': gradeLevel,
        'school': school,
        'phone': phone,
      });

      final user = User.fromJson(response['user']);
      final token = response['access_token'];

      // Sauvegarder localement
      await _saveUserLocally(user);
      await _saveToken(token);

      _currentUser = user;
      _isLoggedIn = true;
      _apiService.setAuthToken(token);

      return AuthResult.success(user: user, token: token);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur inscription: $e');
      }
      return AuthResult.error('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      final user = User.fromJson(response['user']);
      final token = response['access_token'];

      // Sauvegarder localement
      await _saveUserLocally(user);
      await _saveToken(token);

      _currentUser = user;
      _isLoggedIn = true;
      _apiService.setAuthToken(token);

      return AuthResult.success(user: user, token: token);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur connexion: $e');
      }
      return AuthResult.error('Erreur lors de la connexion: $e');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      if (_isLoggedIn) {
        await _apiService.post('/auth/logout');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur déconnexion: $e');
      }
    } finally {
      // Nettoyer les données locales
      await _clearLocalAuth();
      _currentUser = null;
      _isLoggedIn = false;
      _apiService.clearAuthToken();
    }
  }

  // Vérifier l'état de connexion
  Future<bool> checkAuthStatus() async {
    try {
      // Vérifier si on a un token local
      final token = await _getToken();
      if (token == null) return false;

      // Vérifier avec l'API
      _apiService.setAuthToken(token);
      final response = await _apiService.get('/auth/me');
      
      _currentUser = User.fromJson(response);
      _isLoggedIn = true;
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur vérification auth: $e');
      }
      await _clearLocalAuth();
      return false;
    }
  }

  // Mise à jour du profil
  Future<AuthResult> updateProfile({
    String? fullName,
    String? gradeLevel,
    String? school,
    String? phone,
    String? password,
  }) async {
    try {
      if (!_isLoggedIn) {
        return AuthResult.error('Non connecté');
      }

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (gradeLevel != null) updateData['grade_level'] = gradeLevel;
      if (school != null) updateData['school'] = school;
      if (phone != null) updateData['phone'] = phone;
      if (password != null) updateData['password'] = password;

      final response = await _apiService.put('/auth/me', body: updateData);
      final user = User.fromJson(response);

      // Mettre à jour localement
      await _updateUserLocally(user);
      _currentUser = user;

      return AuthResult.success(user: user);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur mise à jour profil: $e');
      }
      return AuthResult.error('Erreur lors de la mise à jour: $e');
    }
  }

  // Sauvegarder l'utilisateur localement
  Future<void> _saveUserLocally(User user) async {
    await _dbHelper.updateUser(
      user.id,
      user.toJson(),
    );
  }

  // Mettre à jour l'utilisateur localement
  Future<void> _updateUserLocally(User user) async {
    await _dbHelper.updateUser(
      user.id,
      user.toJson(),
    );
  }

  // Sauvegarder le token
  Future<void> _saveToken(String token) async {
    // Dans un vrai projet, utiliser un service de stockage sécurisé
    // comme flutter_secure_storage
    await _dbHelper.insert('user_tokens', {
      'token': token,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Récupérer le token
  Future<String?> _getToken() async {
    final tokens = await _dbHelper.query('user_tokens', orderBy: 'created_at DESC', limit: 1);
    return tokens.isNotEmpty ? tokens.first['token'] : null;
  }

  // Nettoyer les données d'authentification locales
  Future<void> _clearLocalAuth() async {
    await _dbHelper.delete('user_tokens');
  }

  // Charger l'utilisateur depuis la base locale
  Future<void> loadUserFromLocal() async {
    try {
      final users = await _dbHelper.query('users', limit: 1);
      if (users.isNotEmpty) {
        _currentUser = User.fromJson(users.first);
        _isLoggedIn = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur chargement utilisateur local: $e');
      }
    }
  }
}

// Modèle utilisateur
class User {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final String? gradeLevel;
  final String? school;
  final bool isActive;
  final bool isTeacher;
  final DateTime? birthDate;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.gradeLevel,
    this.school,
    this.isActive = true,
    this.isTeacher = false,
    this.birthDate,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'],
      gradeLevel: json['grade_level'],
      school: json['school'],
      isActive: json['is_active'] ?? true,
      isTeacher: json['is_teacher'] ?? false,
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'grade_level': gradeLevel,
      'school': school,
      'is_active': isActive,
      'is_teacher': isTeacher,
      'birth_date': birthDate?.toIso8601String(),
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  String get displayName => fullName ?? username;
  String get initials {
    if (fullName != null) {
      final names = fullName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : 'U';
  }
}

// Résultat d'authentification
class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? error;

  AuthResult._({
    required this.success,
    this.user,
    this.token,
    this.error,
  });

  factory AuthResult.success({User? user, String? token}) {
    return AuthResult._(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
}
