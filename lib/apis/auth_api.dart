import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sports_ticketing/providers/supabase_providers.dart';
import 'package:sports_ticketing/utils/failure.dart';
import 'package:sports_ticketing/utils/type_defs.dart';

final authAPIProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthAPI(client: client);
});

class AuthAPI {
  final SupabaseClient _client;

  AuthAPI({required SupabaseClient client}) : _client = client;

  Stream<User?> get authStateChange => _client.auth.onAuthStateChange.map((event) => event.session?.user);

  FutureEither<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(email: email, password: password);
      if (response.user == null) {
        return left(Failure('Registration failed: user is null', StackTrace.current));
      }
      return right(response);
    } on AuthException catch (e, stackTrace) {
      return left(Failure(e.message, stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEither<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      if (response.user == null) {
        return left(Failure('Login failed: user is null', StackTrace.current));
      }
      return right(response);
    } on AuthException catch (e, stackTrace) {
      return left(Failure(e.message, stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEitherVoid logout() async {
    try {
      await _client.auth.signOut();
      return right(null);
    } on AuthException catch (e, stackTrace) {
      return left(Failure(e.message, stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEitherVoid deleteAccount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return left(Failure("No user found", StackTrace.current));
      }

      // Delete user-related data from 'users' table
      await _client.from('users').delete().eq('uid', user.id);

      // Optionally delete posts or other content
      await _client.from('posts').delete().eq('userId', user.id);

      return right(null);
    } on PostgrestException catch (e, stackTrace) {
      return left(Failure(e.message, stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEitherVoid sendEmailVerification() async {
    try {
      final email = _client.auth.currentUser?.email;
      if (email == null) {
        return left(Failure('No email found', StackTrace.current));
      }
      await _client.auth.resend(email: email, type: OtpType.email);
      return right(null);
    } on AuthException catch (e, stackTrace) {
      return left(Failure(e.message, stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEitherVoid changePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return right(null);
    } on AuthException catch (e, stackTrace) {
      return left(Failure(e.message, stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  FutureEitherVoid changeEmail(String newEmail) async {
    try {
      await _client.auth.updateUser(UserAttributes(email: newEmail));
      return right(null);
    } on AuthException catch (e, stackTrace) {
      return left(Failure(e.message, stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
