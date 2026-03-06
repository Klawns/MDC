import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mdc_card.dart';
import '../../core/widgets/primary_button.dart';
import '../rides/ride_form_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(ridesProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mohamed Delivery Control'),
      ),
      body: ridesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Erro: $err')),
        data: (rides) {
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          
          // Calculate start of the week (assuming Monday is start)
          final weekday = now.weekday; // 1 = Monday, 7 = Sunday
          final weekStart = todayStart.subtract(Duration(days: weekday - 1));

          final todayRides = rides.where((r) => r.date.isAfter(todayStart) || r.date.isAtSameMomentAs(todayStart)).toList();
          final weekRides = rides.where((r) => r.date.isAfter(weekStart) || r.date.isAtSameMomentAs(weekStart)).toList();

          final todayTotal = todayRides.fold(0.0, (sum, item) => sum + item.value);
          final weekTotal = weekRides.fold(0.0, (sum, item) => sum + item.value);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Hoje',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              MdcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFormatter.format(todayTotal),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${todayRides.length} corridas',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Semana',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              MdcCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFormatter.format(weekTotal),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weekRides.length} corridas',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Nova Corrida',
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RideFormScreen()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
