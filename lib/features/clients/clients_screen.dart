import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/client.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mdc_card.dart';
import '../rides/ride_form_screen.dart';
import 'client_details_screen.dart';
import 'client_form_screen.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientsAsyncValue = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Clientes'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientFormScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          Expanded(
            child: clientsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erro: $err')),
              data: (clients) {
                final filteredClients = clients.where((c) {
                  return c.name.toLowerCase().contains(_searchQuery) ||
                      (c.phone != null && c.phone!.contains(_searchQuery));
                }).toList();

                if (filteredClients.isEmpty) {
                  return const Center(child: Text('Nenhum cliente encontrado.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: MdcCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClientDetailsScreen(client: client),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (client.phone != null && client.phone!.isNotEmpty)
                                  const SizedBox(height: 4),
                                if (client.phone != null && client.phone!.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.phone, size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        client.phone!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.plusCircle, size: 20, color: AppTheme.primaryBlue),
                                  tooltip: 'Nova Corrida',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RideFormScreen(initialClient: client),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.edit2, size: 20, color: AppTheme.secondaryBlue),
                                  tooltip: 'Editar Cliente',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ClientFormScreen(client: client),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 20, color: AppTheme.statusCanceled),
                                  tooltip: 'Excluir Cliente',
                                  onPressed: () {
                                    _confirmDelete(context, client);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Client client) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: Text('Tem certeza que deseja excluir ${client.name}? Todas as corridas atreladas serão removidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.statusCanceled),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (result == true && client.id != null) {
      ref.read(clientsProvider.notifier).deleteClient(client.id!);
    }
  }
}
