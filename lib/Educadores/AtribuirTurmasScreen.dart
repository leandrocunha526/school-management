import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AtribuirTurmasScreen extends StatefulWidget {
  final String educadorId;

  const AtribuirTurmasScreen({
    super.key,
    required this.educadorId,
  });

  @override
  State<AtribuirTurmasScreen> createState() => _AtribuirTurmasScreenState();
}

class _AtribuirTurmasScreenState extends State<AtribuirTurmasScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? educador;
  bool carregandoEducador = true;
  bool salvando = false;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final anoLetivoController = TextEditingController();

  String perfilSelecionado = 'Professor';
  String? periodoSelecionado;
  final List<String> todosPeriodos = ['Manhã', 'Tarde', 'Noite'];

  List<TextEditingController> turmasControllers = [];
  List<String?> periodosTurmas = [];

  List<String> sugestoesTurmas = [];

  @override
  void initState() {
    super.initState();
    carregarEducador();
    carregarSugestoesTurmas();
  }

  Future<void> carregarEducador() async {
    try {
      final response = await supabase
          .from('educadores')
          .select()
          .eq('id', widget.educadorId)
          .single();

      final turmasResponse = await supabase
          .from('turma')
          .select()
          .eq('educador_id', widget.educadorId);

      setState(() {
        educador = response;
        nomeController.text = response['nome'] ?? '';
        emailController.text = response['email'] ?? '';
        telefoneController.text = response['telefone'] ?? '';
        anoLetivoController.text = response['ano_letivo']?.toString() ?? '';
        periodoSelecionado = response['periodo'] ?? todosPeriodos.first;
        perfilSelecionado = response['perfil'] ?? 'Professor';
        carregandoEducador = false;

        turmasControllers.clear();
        periodosTurmas.clear();
        if (turmasResponse.isNotEmpty) {
          for (var turma in turmasResponse) {
            final controller = TextEditingController(text: turma['turma'] ?? '');
            turmasControllers.add(controller);
            periodosTurmas.add(turma['periodo'] ?? todosPeriodos.first);
          }
        }
        if (turmasControllers.isEmpty) {
          turmasControllers.add(TextEditingController());
          periodosTurmas.add(todosPeriodos.first);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar educador: $e')),
      );
      setState(() => carregandoEducador = false);
    }
  }

  Future<void> carregarSugestoesTurmas() async {
    try {
      final response = await supabase.from('turma').select('turma').limit(100);
      setState(() {
        sugestoesTurmas = (response as List)
            .map((r) => r['turma'].toString())
            .toSet()
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar sugestões de turmas: $e')),
      );
    }
  }

  Future<void> salvar() async {
    setState(() => salvando = true);
    try {
      await supabase.from('educadores').upsert({
        'id': widget.educadorId,
        'nome': nomeController.text.trim().isEmpty ? 'Sem Nome' : nomeController.text.trim(),
        'email': emailController.text.trim().isEmpty ? 'sememail@exemplo.com' : emailController.text.trim(),
        'telefone': telefoneController.text.trim(),
        'perfil': perfilSelecionado,
        'ano_letivo': anoLetivoController.text.trim(),
        'periodo': periodoSelecionado,
      });

      await supabase.from('turma').delete().eq('educador_id', widget.educadorId);

      for (int i = 0; i < turmasControllers.length; i++) {
        final turmaNome = turmasControllers[i].text.trim();
        final turmaPeriodo = perfilSelecionado == 'Coordenador'
            ? periodosTurmas[i]
            : periodoSelecionado;

        if (turmaNome.isNotEmpty) {
          await supabase.from('turma').insert({
            'educador_id': widget.educadorId,
            'turma': turmaNome,
            'ano_letivo': anoLetivoController.text.trim(),
            'periodo': turmaPeriodo,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados salvos com sucesso')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      setState(() => salvando = false);
    }
  }

  Widget _buildTurmasFields() {
    return Column(
      children: [
        ...turmasControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            return sugestoesTurmas
                                .where((turma) => turma.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                                .toList();
                          },
                          onSelected: (String selection) {
                            controller.text = selection;
                          },
                          fieldViewBuilder: (context, textFieldController, focusNode, onFieldSubmitted) {
                            textFieldController.text = controller.text;
                            return TextField(
                              controller: textFieldController,
                              focusNode: focusNode,
                              onChanged: (value) {
                                controller.text = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Nome da turma',
                                border: InputBorder.none,
                              ),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            turmasControllers.removeAt(index);
                            periodosTurmas.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                  if (perfilSelecionado == 'Coordenador')
                    DropdownButtonFormField<String>(
                      value: periodosTurmas[index],
                      items: todosPeriodos.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (value) {
                        setState(() {
                          periodosTurmas[index] = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Período da turma'),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              turmasControllers.add(TextEditingController());
              periodosTurmas.add(todosPeriodos.first);
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Turma'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003972),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro do Educador'),
        backgroundColor: const Color(0xFF002D72),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: carregandoEducador
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ListView(
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome completo'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              TextField(
                controller: telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  hintText: 'Digite o telefone, se desejar',
                ),
              ),
              TextField(
                controller: anoLetivoController,
                decoration: const InputDecoration(
                  labelText: 'Ano letivo',
                  hintText: 'Ex: 2025',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: periodoSelecionado,
                items: todosPeriodos.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    periodoSelecionado = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Período do educador'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: perfilSelecionado,
                items: ['Professor', 'Coordenador'].map((perfil) {
                  return DropdownMenuItem(
                    value: perfil,
                    child: Text(perfil),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      perfilSelecionado = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Perfil'),
              ),
              const SizedBox(height: 24),
              const Text('Lista de turmas:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTurmasFields(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: salvando ? null : salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002D72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
