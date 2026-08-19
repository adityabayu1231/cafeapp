import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  /// Login tahap 1: kirim email+password, backend generate & kirim OTP.
  /// Return void di sisi kanan Either karena backend tidak mengembalikan
  /// data user/token pada tahap ini (sesuai spec §3: OTP dikirim ke email).
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });
}