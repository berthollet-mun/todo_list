import 'package:todo_list/models/user.dart';
import 'package:todo_list/services/auth_service.dart';
import 'package:todo_list/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Page d'inscription à l'application
/// Permet aux nouveaux utilisateurs de créer un compte
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Inscription d'un nouvel utilisateur
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérification de la correspondance des mots de passe
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Création d'un nouvel utilisateur avec un ID unique
      final user = User(
        id: const Uuid().v4(), // Génération d'un UUID unique
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _authService.registerUser(user);

      // Message de succès et retour à la page de connexion
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compte créé avec succès')));

      Navigator.pop(context);
    } catch (e) {
      print("Erreur: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: [
              // GRADIENT BACKGROUND
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                      Color(0xFF90CAF9),
                    ],
                  ),
                ),
              ),

              // CONTENU
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // TITRE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Créer un Compte",
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARTE DE FORMULAIRE
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 25),
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 25,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // NOM D'UTILISATEUR
                            CustomTextField(
                              controller: _usernameController,
                              label: 'Nom d\'utilisateur',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un nom d\'utilisateur';
                                }
                                if (value.length < 3) {
                                  return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // EMAIL
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre email';
                                }
                                if (!value.contains('@')) {
                                  return 'Email invalide';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // MOT DE PASSE
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Mot de passe',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un mot de passe';
                                }
                                if (value.length < 6) {
                                  return 'Le mot de passe doit contenir au moins 6 caractères';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // CONFIRMER LE MOT DE PASSE
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirmer le mot de passe',
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  );
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez confirmer votre mot de passe';
                                }
                                if (value != _passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            // BOUTON D'INSCRIPTION
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, 55),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 5,
                                      shadowColor: Colors.blue.withOpacity(0.3),
                                    ),
                                    child: Text(
                                      "Créer un compte",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 20),

                            // LIEN VERS LA PAGE DE CONNEXION
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Déjà un compte ? Se connecter",
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _register() {
  //   // Ton code d'inscription ici
  // }
}
