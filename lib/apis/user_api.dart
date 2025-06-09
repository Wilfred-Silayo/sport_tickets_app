import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sports_ticketing/models/user_model.dart';
import 'package:sports_ticketing/utils/failure.dart';
import 'package:sports_ticketing/utils/type_defs.dart';
import 'package:sports_ticketing/providers/supabase_providers.dart';

final userAPIProvider = Provider((ref) {
  return UserAPI(supabase: ref.watch(supabaseClientProvider));
});

class UserAPI {
  final SupabaseClient _supabase;
  UserAPI({required SupabaseClient supabase}) : _supabase = supabase;

  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      await _supabase.from('users').insert(userModel.toMap());
      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['uid'])
        .eq('uid', uid)
        .limit(1)
        .map((event) => UserModel.fromMap(event.first));
  }

  FutureEitherVoid updateUserData(UserModel userModel) async {
    try {
      await _supabase
          .from('users')
          .update(userModel.toMap())
          .eq('uid', userModel.uid);
      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
