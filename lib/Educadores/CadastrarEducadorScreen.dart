import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CadastrarEducadorScreen extends StatefulWidget {
  const CadastrarEducadorScreen({super.key});

  @override
  State<CadastrarEducadorScreen> createState() => _CadastrarEducadorScreenState();
}

class _CadastrarEducadorScreenState extends State<CadastrarEducadorScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController anoLetivoController = TextEditingController();
  String periodoSelecionado = 'Período';

  final List<String> periodos = ['Manhã', 'Tarde', 'Noite'];
  bool carregando = false;

  Future<void> adicionarEducador() async {
    final nome = nomeController.text.trim();
    final ano = anoLetivoController.text.trim();
    final periodo = periodoSelecionado;

    if (nome.isEmpty || ano.isEmpty || !periodos.contains(periodo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      final newEducador = await Supabase.instance.client
          .from('educadores')
          .insert({
        'nome': nome,
        'ano_letivo': ano,
        'periodo': periodo,
      })
          .select()
          .single();

      Navigator.pop(context, {
        'id': newEducador['id'],
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar educador: $e')),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EDUCADORES',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Preencha os dados do educador', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),
              _buildInputField(controller: nomeController, hintText: 'Nome do educador'),
              const SizedBox(height: 12),
              _buildInputField(
                controller: anoLetivoController,
                hintText: 'Ano letivo (grade)',
                showSearchIcon: true,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                hint: 'Período',
                value: periodos.contains(periodoSelecionado) ? periodoSelecionado : null,
                items: periodos,
                onChanged: (value) {
                  setState(() {
                    periodoSelecionado = value!;
                  });
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: carregando ? null : adicionarEducador,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002D72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Adicionar educador',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
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
    bool showSearchIcon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[700]),
          suffixIcon: showSearchIcon ? const Icon(Icons.search) : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey[700])),
          value: value,
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
