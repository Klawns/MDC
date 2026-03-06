import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/client_repository.dart';
import '../database/ride_repository.dart';
import '../models/client.dart';
import '../models/ride.dart';

final clientRepositoryProvider = Provider((ref) => ClientRepository());
final rideRepositoryProvider = Provider((ref) => RideRepository());

class ClientsNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() async {
    return ref.read(clientRepositoryProvider).getAll();
  }

  Future<void> addClient(Client client) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(clientRepositoryProvider).create(client);
      return ref.read(clientRepositoryProvider).getAll();
    });
  }

  Future<void> updateClient(Client client) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(clientRepositoryProvider).update(client);
      return ref.read(clientRepositoryProvider).getAll();
    });
  }

  Future<void> deleteClient(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(clientRepositoryProvider).delete(id);
      return ref.read(clientRepositoryProvider).getAll();
    });
  }
}

final clientsProvider = AsyncNotifierProvider<ClientsNotifier, List<Client>>(() {
  return ClientsNotifier();
});

class RidesNotifier extends AsyncNotifier<List<Ride>> {
  @override
  Future<List<Ride>> build() async {
    return ref.read(rideRepositoryProvider).getAll();
  }

  Future<void> addRide(Ride ride) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(rideRepositoryProvider).create(ride);
      return ref.read(rideRepositoryProvider).getAll();
    });
  }

  Future<void> updateRide(Ride ride) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(rideRepositoryProvider).update(ride);
      return ref.read(rideRepositoryProvider).getAll();
    });
  }

  Future<void> togglePaidStatus(Ride ride) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedRide = ride.copyWith(
        isPaid: !ride.isPaid,
        isCompleted: !ride.isPaid,
      );
      await ref.read(rideRepositoryProvider).update(updatedRide);
      return ref.read(rideRepositoryProvider).getAll();
    });
  }

  Future<void> deleteRide(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(rideRepositoryProvider).delete(id);
      return ref.read(rideRepositoryProvider).getAll();
    });
  }
}

final ridesProvider = AsyncNotifierProvider<RidesNotifier, List<Ride>>(() {
  return RidesNotifier();
});
