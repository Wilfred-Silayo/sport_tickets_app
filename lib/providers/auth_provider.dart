import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sports_ticketing/apis/auth_api.dart';
import 'package:sports_ticketing/apis/user_api.dart';
import 'package:sports_ticketing/models/user_model.dart';
import 'package:sports_ticketing/pages/home_page.dart';
import 'package:sports_ticketing/pages/login_page.dart';
import 'package:sports_ticketing/utils/utils.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserDetailsProvider = StreamProvider((ref) {
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser == null) throw Exception("No current user");
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(currentUser.id);
});

final currentUserAccountProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;
  AuthController({
    required AuthAPI authAPI,
    required UserAPI userAPI,
  })  : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);

  Stream<User?> get authStateChange => _authAPI.authStateChange;

  void register({
    required String email,
    required String password,
    required String confirmedPassword,
    required String username,
    required BuildContext context,
  }) async {
    state = true;
    if (password != confirmedPassword) {
      showSnackBar(context, "Confirmed password does not match with password!");
      state = false;
      return;
    }
    final res = await _authAPI.register(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        state = true;
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;
        UserModel userModel = UserModel(
          email: email,
          username: username,
          profilePic: '',
          uid: user.id,
        );
        final res2 = await _userAPI.saveUserData(userModel);
        state = false;
        res2.fold(
          (l) => showSnackBar(context, l.message),
          (r) {
            showSnackBar(context, 'Account created successfully!');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        );
      },
    );
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.login(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      },
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _userAPI.getUserData(uid);
  }

  void logout(BuildContext context) async {
    state = true;
    final res = await _authAPI.logout();
    state = false;
    res.fold(
      (l) {
        print(l.message);
        showSnackBar(context, l.message);
      },
      (r) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      },
    );
  }

  void deleteAccount(BuildContext context) async {
    state = true;
    final res = await _authAPI.deleteAccount();
    state = false;
    res.fold(
      (l) => null,
      (r) {
        showSnackBar(context, 'Account Deleted successfully');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      },
    );
  }

  void changePassword(BuildContext context, String password) async {
    final res = await _authAPI.changePassword(password);
    res.fold((l) => null, (r) {
      showSnackBar(context, 'Password changed successfully');
    });
  }

  void verifyEmail(BuildContext context) async {
    state = true;
    final res = await _authAPI.sendEmailVerification();
    state = false;
    res.fold((l) => null, (r) {
      showSnackBar(context,
          'Verification email sent successfully. Please check your inbox');
    });
  }

  void changeEmail(BuildContext context, String newEmail) async {
    final res = await _authAPI.changeEmail(newEmail);
    res.fold((l) => null, (r) {
      showSnackBar(context, 'Email changed successfully');
    });
  }
}
