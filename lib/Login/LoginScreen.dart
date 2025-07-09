import 'package:escribo/Educadores/EducadoresList.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../SingUp/SignUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;

  void fazerLogin() async {
    setState(() => carregando = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      if (res.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EducadoresList()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ESCRIBO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              _buildInputField(controller: emailController, hintText: 'email'),
              const SizedBox(height: 16),
              _buildInputField(
                controller: senhaController,
                hintText: 'senha',
                obscureText: true,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: carregando ? null : fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF002D72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                child: const Text("Não tem conta? Cadastre-se"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[700]),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
