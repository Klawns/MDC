import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mdc_card.dart';
import '../../core/widgets/primary_button.dart';
import 'pdf_generator.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(ridesProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
      ),
      body: ridesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Erro: $err')),
        data: (rides) {
          return clientsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => const SizedBox(),
            data: (clients) {
              final now = DateTime.now();
              final todayStart = DateTime(now.year, now.month, now.day);
              final weekday = now.weekday;
              final weekStart = todayStart.subtract(Duration(days: weekday - 1));

              final todayRides = rides.where((r) => r.date.isAfter(todayStart) || r.date.isAtSameMomentAs(todayStart)).toList();
              final weekRides = rides.where((r) => r.date.isAfter(weekStart) || r.date.isAtSameMomentAs(weekStart)).toList();

              final todayTotal = todayRides.fold(0.0, (sum, item) => sum + item.value);
              final weekTotal = weekRides.fold(0.0, (sum, item) => sum + item.value);
              
              final avgToday = todayRides.isNotEmpty ? todayTotal / todayRides.length : 0.0;
              final avgWeek = weekRides.isNotEmpty ? weekTotal / weekRides.length : 0.0;

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text('Fechamento Diário', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  MdcCard(
                    child: Column(
                      children: [
                        _buildStatRow('Total Corridas:', '${todayRides.length}'),
                        const SizedBox(height: 8),
                        _buildStatRow('Total Ganho:', currencyFormatter.format(todayTotal), isBold: true, color: AppTheme.statusPaid),
                        const SizedBox(height: 8),
                        _buildStatRow('Média por corrida:', currencyFormatter.format(avgToday)),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Gerar PDF do Dia',
                          icon: LucideIcons.fileText,
                          onPressed: () {
                            if (todayRides.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nenhuma corrida para gerar relatório.')),
                              );
                              return;
                            }
                            PdfGenerator.generateAndPrintReport(
                              rides: todayRides,
                              clients: clients,
                              startDate: todayStart,
                              endDate: DateTime.now(),
                              title: 'Relatório Diário - ${DateFormat('dd/MM/yyyy').format(now)}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text('Fechamento Semanal', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  MdcCard(
                    child: Column(
                      children: [
                        _buildStatRow('Total Corridas:', '${weekRides.length}'),
                        const SizedBox(height: 8),
                        _buildStatRow('Total Ganho:', currencyFormatter.format(weekTotal), isBold: true, color: AppTheme.statusPaid),
                        const SizedBox(height: 8),
                        _buildStatRow('Média por corrida:', currencyFormatter.format(avgWeek)),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Gerar PDF da Semana',
                          icon: LucideIcons.fileText,
                          onPressed: () {
                            if (weekRides.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nenhuma corrida para gerar relatório.')),
                              );
                              return;
                            }
                            PdfGenerator.generateAndPrintReport(
                              rides: weekRides,
                              clients: clients,
                              startDate: weekStart,
                              endDate: DateTime.now(),
                              title: 'Relatório Semanal - ${DateFormat('dd/MM/yyyy').format(weekStart)} a ${DateFormat('dd/MM/yyyy').format(now)}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
