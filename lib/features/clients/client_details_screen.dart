import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/client.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mdc_card.dart';
import '../rides/ride_form_screen.dart';
import 'client_form_screen.dart';

class ClientDetailsScreen extends ConsumerWidget {
  final Client client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(ridesProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientFormScreen(client: client),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Client Info Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MdcCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.user, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          client.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (client.phone != null && client.phone!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(LucideIcons.phone, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          client.phone!,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (client.notes != null && client.notes!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.fileText, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            client.notes!,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const Divider(),
          
          // Header for Rides
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Histórico de Corridas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RideFormScreen(initialClient: client),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Nova'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // List of Rides
          Expanded(
            child: ridesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Erro: $err')),
              data: (rides) {
                final clientRides = rides.where((r) => r.clientId == client.id).toList();
                // Sort by date descending
                clientRides.sort((a, b) => b.date.compareTo(a.date));

                if (clientRides.isEmpty) {
                  return const Center(child: Text('Nenhuma corrida registrada para este cliente.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: clientRides.length,
                  itemBuilder: (context, index) {
                    final ride = clientRides[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: MdcCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currencyFormatter.format(ride.value),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ride.isPaid ? AppTheme.statusPaid.withOpacity(0.1) : AppTheme.statusPending.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ride.isPaid ? 'Pago' : 'Pendente',
                                    style: TextStyle(
                                      color: ride.isPaid ? AppTheme.statusPaid : AppTheme.statusPending,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(LucideIcons.calendar, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  dateFormatter.format(ride.date),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            if (ride.note != null && ride.note!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                ride.note!,
                                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                              ),
                            ],
                            const SizedBox(height: 12),
                            // Quick acton to toggle payment
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    final updated = ride.copyWith(
                                      isPaid: !ride.isPaid,
                                      isCompleted: !ride.isPaid,
                                    );
                                    ref.read(ridesProvider.notifier).updateRide(updated);
                                  },
                                  icon: Icon(
                                    ride.isPaid ? LucideIcons.xCircle : LucideIcons.checkCircle,
                                    size: 16,
                                  ),
                                  label: Text(ride.isPaid ? 'Marcar Pendente' : 'Marcar Recebido'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: ride.isPaid ? AppTheme.statusPending : AppTheme.statusPaid,
                                  ),
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
}
