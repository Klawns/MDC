import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/client.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/mdc_input.dart';
import '../../core/widgets/primary_button.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _notesController = TextEditingController(text: widget.client?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final notes = _notesController.text.trim();

      if (widget.client != null) {
        // Edit mode
        final updatedClient = widget.client!.copyWith(
          name: name,
          phone: phone,
          notes: notes,
        );
        ref.read(clientsProvider.notifier).updateClient(updatedClient);
      } else {
        // Add new
        final newClient = Client(
          name: name,
          phone: phone,
          notes: notes,
        );
        ref.read(clientsProvider.notifier).addClient(newClient);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client != null ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              MdcInput(
                controller: _phoneController,
                hintText: 'Telefone (Opcional)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              MdcInput(
                controller: _notesController,
                hintText: 'Observações (Opcional)',
                maxLines: 3,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Salvar',
                onPressed: _saveClient,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
