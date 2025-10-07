import '../../models/user_model.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';
  String _fullName = '';
  String _gradeLevel = 'Collège';
  String _school = '';
  String _phone = '';
  String? _error;

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (!_isLogin && _password != _confirmPassword) {
      setState(() { _error = 'Les mots de passe ne correspondent pas.'; });
      return;
    }
    if (!_isLogin && _fullName.isEmpty) {
      setState(() { _error = 'Veuillez entrer votre nom complet.'; });
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      if (_isLogin) {
        final result = await AuthService().login(_email, _password);
        // Le token est maintenant géré dans le service
      } else {
        await AuthService().register(
          email: _email,
          username: _username,
          fullName: _fullName,
          password: _password,
          gradeLevel: _gradeLevel,
          school: _school.isNotEmpty ? _school : null,
          phone: _phone.isNotEmpty ? _phone : null,
        );
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Connexion' : 'Inscription'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Email invalide',
                  onSaved: (v) => _email = v!.trim(),
                ),
                const SizedBox(height: 12),
                if (!_isLogin) ...[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
                    validator: (v) => v != null && v.length >= 3 ? null : 'Min. 3 caractères',
                    onSaved: (v) => _username = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom complet'),
                    validator: (v) => v != null && v.isNotEmpty ? null : 'Obligatoire',
                    onSaved: (v) => _fullName = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Téléphone (optionnel)'),
                    keyboardType: TextInputType.phone,
                    onSaved: (v) => _phone = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gradeLevel,
                    decoration: const InputDecoration(labelText: 'Niveau scolaire'),
                    items: const [
                      DropdownMenuItem(value: 'Primaire', child: Text('Primaire')),
                      DropdownMenuItem(value: 'Collège', child: Text('Collège')),
                      DropdownMenuItem(value: 'Lycée', child: Text('Lycée')),
                      DropdownMenuItem(value: 'Terminale', child: Text('Terminale')),
                    ],
                    onChanged: (value) => setState(() => _gradeLevel = value!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'École (optionnel)'),
                    onSaved: (v) => _school = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min. 6 caractères',
                  onSaved: (v) => _password = v!.trim(),
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                    obscureText: true,
                    validator: (v) => v != null && v.length >= 6 ? null : 'Min. 6 caractères',
                    onSaved: (v) => _confirmPassword = v!.trim(),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(_isLogin ? 'Se connecter' : 'S\'inscrire'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : _toggleMode,
                  child: Text(_isLogin
                      ? 'Créer un compte'
                      : 'Déjà inscrit ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 