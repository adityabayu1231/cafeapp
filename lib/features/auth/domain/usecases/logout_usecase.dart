import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  final SecureStorage secureStorage;

  LogoutUseCase(this.repository, this.secureStorage);

  Future<Either<Failure, void>> call() async {
    final result = await repository.logout();
    // Token lokal tetap dihapus meski API call gagal (misal token
    // sudah invalid di server) — logout harus tetap berhasil secara lokal.
    await secureStorage.deleteToken();
    return result;
  }
}