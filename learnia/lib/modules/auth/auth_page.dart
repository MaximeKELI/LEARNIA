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
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  DateTime? _birthDate;
  int? _age;
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
    if (!_isLogin && _birthDate == null) {
      setState(() { _error = 'Veuillez sélectionner votre date de naissance.'; });
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      if (_isLogin) {
        await AuthService().login(_email, _password);
      } else {
        await AuthService().register(
          email: _email,
          username: _username,
          firstName: _firstName,
          lastName: _lastName,
          password: _password,
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
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: (v) => v != null && v.isNotEmpty ? null : 'Obligatoire',
                    onSaved: (v) => _firstName = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (v) => v != null && v.isNotEmpty ? null : 'Obligatoire',
                    onSaved: (v) => _lastName = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Téléphone (optionnel)'),
                    keyboardType: TextInputType.phone,
                    onSaved: (v) => _phone = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(now.year - 16),
                              firstDate: DateTime(now.year - 100),
                              lastDate: now,
                            );
                            if (picked != null) {
                              setState(() {
                                _birthDate = picked;
                                final today = DateTime.now();
                                _age = today.year - picked.year - ((today.month < picked.month || (today.month == picked.month && today.day < picked.day)) ? 1 : 0);
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de naissance',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              children: [
                                Text(_birthDate == null
                                    ? 'Sélectionner...'
                                    : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'),
                                if (_age != null) ...[
                                  const SizedBox(width: 12),
                                  Text('Vous avez $_age ans', style: const TextStyle(color: Colors.green)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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