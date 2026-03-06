import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/client.dart';
import '../../core/models/ride.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mdc_input.dart';
import '../../core/widgets/primary_button.dart';

class RideFormScreen extends ConsumerStatefulWidget {
  final Client? initialClient;

  const RideFormScreen({super.key, this.initialClient});

  @override
  ConsumerState<RideFormScreen> createState() => _RideFormScreenState();
}

class _RideFormScreenState extends ConsumerState<RideFormScreen> {
  Client? _selectedClient;
  double? _selectedValue;
  bool _isPaid = false;
  final TextEditingController _noteController = TextEditingController();

  final List<double> _defaultValues = [10.0, 15.0, 20.0, 25.0];

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.initialClient;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveRide() {
    if (_selectedClient == null || _selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente e um valor.')),
      );
      return;
    }

    final newRide = Ride(
      clientId: _selectedClient!.id!,
      value: _selectedValue!,
      note: _noteController.text.trim(),
      date: DateTime.now(),
      isPaid: _isPaid,
      isCompleted: _isPaid, // If paid, consider it completed generally
    );

    ref.read(ridesProvider.notifier).addRide(newRide);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Corrida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Cliente
            Text('Cliente', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            clientsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, st) => Text('Erro ao carregar clientes: $err'),
              data: (clients) {
                if (clients.isEmpty) {
                  return const Text('Cadastre um cliente primeiro.');
                }
                return DropdownButtonFormField<Client>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  hint: const Text('Selecione o Cliente'),
                  initialValue: _selectedClient,
                  items: clients.map((client) {
                    return DropdownMenuItem(
                      value: client,
                      child: Text(client.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedClient = val;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // 2. Valor
            Text('Valor', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _defaultValues.map((val) {
                final isSelected = _selectedValue == val;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedValue = val;
                    });
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 40) / 2, // 2 cols
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.white,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'R\$ ${val.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 3. Status Pagamento
            Row(
              children: [
                Text('Já foi pago?', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Switch(
                  value: _isPaid,
                  activeThumbColor: AppTheme.statusPaid,
                  onChanged: (val) {
                    setState(() {
                      _isPaid = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Observação
            Text('Observação', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            MdcInput(
              hintText: 'Detalhes (opcional)',
              controller: _noteController,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // 5. Salvar
            PrimaryButton(
              text: 'Salvar Corrida',
              onPressed: _saveRide,
            ),
            const SizedBox(height: 40), // padding bottom
          ],
        ),
      ),
    );
  }
}
