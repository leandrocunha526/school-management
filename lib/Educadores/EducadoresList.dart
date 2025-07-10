import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'CadastrarEducadorScreen.dart';
import 'AtribuirTurmasScreen.dart';

class EducadoresList extends StatefulWidget {
  const EducadoresList({super.key});

  @override
  State<EducadoresList> createState() => _EducadoresListState();
}

class _EducadoresListState extends State<EducadoresList> {
  List<dynamic> educadores = [];
  String ultimaEdicao = '--/--/--';

  @override
  void initState() {
    super.initState();
    buscarEducadores();
  }

  Future<void> buscarEducadores() async {
    try {
      final response = await Supabase.instance.client
          .from('educadores')
          .select('id, nome, ano_letivo, periodo, perfil, created_at')
          .order('created_at', ascending: false);

      final dados = List<Map<String, dynamic>>.from(response);

      // Para cada educador, buscar turmas relacionadas na tabela 'turma' (singular)
      for (final educador in dados) {
        final educadorId = educador['id'];
        final turmasResponse = await Supabase.instance.client
            .from('turma')
            .select('id')
            .eq('educador_id', educadorId);

        educador['turmas_count'] = (turmasResponse as List).length;
      }

      final edicaoMaisRecente = dados.isNotEmpty
          ? DateTime.parse(dados.first['created_at']).toLocal()
          : null;

      setState(() {
        educadores = dados;
        ultimaEdicao = edicaoMaisRecente != null
            ? '${edicaoMaisRecente.day.toString().padLeft(2, '0')}/${edicaoMaisRecente.month.toString().padLeft(2, '0')}/${edicaoMaisRecente.year.toString().substring(2)}'
            : '--/--/--';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar educadores: $e')),
        );
      }
    }
  }

  Future<void> deletarEducador(String id) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este educador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      try {
        await Supabase.instance.client
            .from('educadores')
            .delete()
            .eq('id', id);

        await buscarEducadores();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Educador excluído com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir educador: $e')),
          );
        }
      }
    }
  }

  Widget _buildEducadorItem(Map<String, dynamic> educador) {
    final nome = educador['nome'] ?? '';
    final periodo = educador['periodo'] ?? '';
    final ano = educador['ano_letivo'] ?? '';

    final perfilRaw = educador['perfil'];
    final perfil = (perfilRaw == null || perfilRaw.toString().trim().isEmpty)
        ? 'Desconhecido'
        : perfilRaw.toString();

    final turmasCount = educador['turmas_count'] ?? 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AtribuirTurmasScreen(educadorId: educador['id'].toString()),
          ),
        );
        buscarEducadores(); // Atualiza ao voltar
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Ano: $ano - Período: $periodo',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Perfil: $perfil',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$turmasCount turma${turmasCount == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deletarEducador(educador['id'].toString()),
              tooltip: 'Excluir educador',
            ),
          ],
        ),
      ),
    );
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
              const Text('EDUCADORES',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Última edição em $ultimaEdicao',
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),
              Expanded(
                child: educadores.isEmpty
                    ? const Center(
                    child: Text('Nenhum educador cadastrado ainda.',
                        style: TextStyle(color: Colors.black54)))
                    : ListView.separated(
                  itemCount: educadores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildEducadorItem(educadores[index]),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CadastrarEducadorScreen()),
                    );
                    if (result != null) buscarEducadores();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002D72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Adicionar educador',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
