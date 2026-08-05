import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agendamento Médico',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TelaAgendamento(),
    );
  }
}

// Modelo de dados do Médico
class Medico {
  final String nome;
  final String especialidade;
  final double avaliacao;
  final double preco;
  final String fotoUrl;

  Medico({
    required this.nome,
    required this.especialidade,
    required this.avaliacao,
    required this.preco,
    required this.fotoUrl,
  });
}

class TelaAgendamento extends StatefulWidget {
  const TelaAgendamento({super.key});

  @override
  State<TelaAgendamento> createState() => _TelaAgendamentoState();
}

class _TelaAgendamentoState extends State<TelaAgendamento> {
  int _etapaAtual = 0;

  // Filtro de especialidade
  String _especialidadeSelecionada = 'Todas';
  final List<String> _especialidades = [
    'Todas',
    'Cardiologia',
    'Dermatologia',
    'Ortopedia',
    'Pediatria',
    'Oftalmologia',
  ];

  // Lista de médicos
  final List<Medico> _medicos = [
    Medico(
      nome: 'Dra. Ana Silva',
      especialidade: 'Cardiologia',
      avaliacao: 4.9,
      preco: 250.0,
      fotoUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    Medico(
      nome: 'Dr. Carlos Souza',
      especialidade: 'Dermatologia',
      avaliacao: 4.8,
      preco: 220.0,
      fotoUrl: 'https://i.pravatar.cc/150?img=12',
    ),
    Medico(
      nome: 'Dr. Roberto Lima',
      especialidade: 'Ortopedia',
      avaliacao: 4.7,
      preco: 200.0,
      fotoUrl: 'https://i.pravatar.cc/150?img=33',
    ),
    Medico(
      nome: 'Dra. Mariana Costa',
      especialidade: 'Pediatria',
      avaliacao: 5.0,
      preco: 230.0,
      fotoUrl: 'https://i.pravatar.cc/150?img=32',
    ),
  ];

  // Dados selecionados
  Medico? _medicoSelecionado;
  DateTime _dataSelecionada = DateTime.now().add(const Duration(days: 1));
  String? _horarioSelecionado;

  final List<String> _horariosDisponiveis = [
    '08:00',
    '09:30',
    '11:00',
    '14:00',
    '15:30',
    '17:00',
  ];

  // Controllers do Formulário
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamento de Consulta'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade50,
      ),
      body: Stepper(
        // Mudado para vertical para eliminar estouro de tela (overflow)
        type: StepperType.vertical,
        currentStep: _etapaAtual,
        onStepContinue: _avancarEtapa,
        onStepCancel: _voltarEtapa,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                if (_etapaAtual < 3)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(_etapaAtual == 2 ? 'Confirmar' : 'Avançar'),
                    ),
                  ),
                if (_etapaAtual > 0 && _etapaAtual < 3) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          // Passo 1: Médico
          Step(
            title: const Text('Escolha o Médico'),
            isActive: _etapaAtual >= 0,
            state: _etapaAtual > 0 ? StepState.complete : StepState.indexed,
            content: _construirEtapaMedico(),
          ),
          // Passo 2: Data e Hora
          Step(
            title: const Text('Data e Horário'),
            isActive: _etapaAtual >= 1,
            state: _etapaAtual > 1 ? StepState.complete : StepState.indexed,
            content: _construirEtapaDataHora(),
          ),
          // Passo 3: Dados
          Step(
            title: const Text('Seus Dados'),
            isActive: _etapaAtual >= 2,
            state: _etapaAtual > 2 ? StepState.complete : StepState.indexed,
            content: _construirEtapaDados(),
          ),
          // Passo 4: Confirmação
          Step(
            title: const Text('Confirmação'),
            isActive: _etapaAtual >= 3,
            state: StepState.complete,
            content: _construirEtapaConfirmacao(),
          ),
        ],
      ),
    );
  }

  // ETAPA 1: Seleção de Médico
  Widget _construirEtapaMedico() {
    final medicosFiltrados = _especialidadeSelecionada == 'Todas'
        ? _medicos
        : _medicos
              .where((m) => m.especialidade == _especialidadeSelecionada)
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Especialidade:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _especialidades.map((esp) {
              final selecionado = _especialidadeSelecionada == esp;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(esp),
                  selected: selecionado,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _especialidadeSelecionada = esp);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Profissionais Disponíveis:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...medicosFiltrados.map((medico) {
          final isSelected = _medicoSelecionado == medico;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              elevation: isSelected ? 4 : 1,
              color: isSelected ? Colors.blue.shade50 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(medico.fotoUrl),
                  radius: 22,
                ),
                title: Text(
                  medico.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${medico.especialidade}\nR\$ ${medico.preco.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(medico.avaliacao.toString()),
                  ],
                ),
                onTap: () {
                  setState(() => _medicoSelecionado = medico);
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // ETAPA 2: Seleção de Data e Hora
  Widget _construirEtapaDataHora() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.blue),
            title: const Text('Data da Consulta'),
            subtitle: Text(
              '${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: TextButton(
              child: const Text('Alterar'),
              onPressed: () async {
                final data = await showDatePicker(
                  context: context,
                  initialDate: _dataSelecionada,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (data != null) {
                  setState(() => _dataSelecionada = data);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Horários Disponíveis:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _horariosDisponiveis.map((horario) {
            final selecionado = _horarioSelecionado == horario;
            return ChoiceChip(
              label: Text(
                horario,
                style: TextStyle(
                  color: selecionado ? Colors.white : Colors.black87,
                ),
              ),
              selected: selecionado,
              selectedColor: Colors.blue,
              onSelected: (selected) {
                setState(() {
                  _horarioSelecionado = selected ? horario : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ETAPA 3: Dados do Paciente
  Widget _construirEtapaDados() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nomeController,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              labelText: 'Nome Completo',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v!.isEmpty ? 'Informe seu nome' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cpfController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'CPF',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v!.isEmpty ? 'Informe seu CPF' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _telefoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefone/WhatsApp',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v!.isEmpty ? 'Informe seu telefone' : null,
          ),
        ],
      ),
    );
  }

  // ETAPA 4: Tela de Confirmação Final
  Widget _construirEtapaConfirmacao() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 60),
        const SizedBox(height: 8),
        const Text(
          'Agendamento Confirmado!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(_nomeController.text),
                  subtitle: Text('CPF: ${_cpfController.text}'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.medical_services_outlined),
                  title: Text(_medicoSelecionado?.nome ?? ''),
                  subtitle: Text(_medicoSelecionado?.especialidade ?? ''),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    '${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year} às $_horarioSelecionado',
                  ),
                  subtitle: Text(
                    'Valor: R\$ ${_medicoSelecionado?.preco.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _reiniciarAgendamento,
          child: const Text('Novo Agendamento'),
        ),
      ],
    );
  }

  // Lógica de navegação do Stepper
  void _avancarEtapa() {
    if (_etapaAtual == 0) {
      if (_medicoSelecionado == null) {
        _mostrarAlerta('Por favor, selecione um médico.');
        return;
      }
    } else if (_etapaAtual == 1) {
      if (_horarioSelecionado == null) {
        _mostrarAlerta('Por favor, selecione um horário.');
        return;
      }
    } else if (_etapaAtual == 2) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() => _etapaAtual += 1);
  }

  void _voltarEtapa() {
    if (_etapaAtual > 0) {
      setState(() => _etapaAtual -= 1);
    }
  }

  void _mostrarAlerta(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
    );
  }

  void _reiniciarAgendamento() {
    setState(() {
      _etapaAtual = 0;
      _medicoSelecionado = null;
      _horarioSelecionado = null;
      _nomeController.clear();
      _cpfController.clear();
      _telefoneController.clear();
    });
  }
}
