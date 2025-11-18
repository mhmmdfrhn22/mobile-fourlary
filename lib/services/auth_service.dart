import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login(String username, String password) async {
    // sementara pakai dummy
    await Future.delayed(const Duration(seconds: 2));

    if (username == 'admin' && password == '123456') {
      return UserModel(
        id: 1,
        username: 'admin',
        roleId: 1,
        token: 'dummy_token',
      );
    } else {
      throw Exception('Username atau password salah');
    }
  }
}