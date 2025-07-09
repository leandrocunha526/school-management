import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Login/LoginScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;

  Future<void> cadastrar() async {
    setState(() => carregando = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
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
                  onPressed: carregando ? null : cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF002D72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: carregando
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Cadastrar',
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text("Já tem conta? Fazer login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
