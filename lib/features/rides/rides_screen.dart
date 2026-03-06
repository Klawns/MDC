import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/ride.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mdc_card.dart';
import 'ride_form_screen.dart';

class RidesScreen extends ConsumerWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(ridesProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final timeFormatter = DateFormat('dd/MM HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corridas'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RideFormScreen()),
              );
            },
          )
        ],
      ),
      body: ridesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Erro: $err')),
        data: (rides) {
          if (rides.isEmpty) {
            return const Center(child: Text('Nenhuma corrida registrada.'));
          }

          return clientsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => const SizedBox(),
            data: (clients) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  // Encontrar nome do cliente
                  // Pode ser null caso tenha sido excluído, então trata gracefully
                  final clientIndex = clients.indexWhere((c) => c.id == ride.clientId);
                  final clientName = clientIndex >= 0 ? clients[clientIndex].name : 'Cliente Excluído';

                  final isPaid = ride.isPaid;
                  final statusColor = isPaid ? AppTheme.statusPaid : AppTheme.statusPending;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: MdcCard(
                      borderColor: statusColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(clientName, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormatter.format(ride.value),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${isPaid ? 'Pago' : 'Pendente'} • ${timeFormatter.format(ride.date)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (!isPaid)
                                IconButton(
                                  icon: const Icon(LucideIcons.checkCircle, color: AppTheme.statusPaid),
                                  tooltip: 'Marcar como pago',
                                  onPressed: () {
                                    ref.read(ridesProvider.notifier).togglePaidStatus(ride);
                                  },
                                ),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, color: AppTheme.statusCanceled, size: 20),
                                onPressed: () {
                                  _confirmDelete(context, ref, ride);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Nova Corrida', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RideFormScreen()),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Ride ride) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Corrida'),
        content: const Text('Tem certeza que deseja excluir esta corrida?'),
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

    if (result == true && ride.id != null) {
      ref.read(ridesProvider.notifier).deleteRide(ride.id!);
    }
  }
}
