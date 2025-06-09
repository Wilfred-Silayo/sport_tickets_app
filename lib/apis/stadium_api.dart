import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sports_ticketing/models/stadium_model.dart';
import 'package:sports_ticketing/providers/supabase_providers.dart';

final stadiumAPIProvider = Provider((ref) {
  return StadiumAPI(
    supabase: ref.watch(supabaseClientProvider),
  );
});

class StadiumAPI {
  final SupabaseClient _supabase;

  StadiumAPI({required SupabaseClient supabase}) : _supabase = supabase;

  Stream<Stadium> getStadiums(String id) {
    return _supabase
        .from('stadiums')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
          if (data.isEmpty) {
            // Return some default or throw if needed
            throw Exception('Stadium not found');
          }
          // data is List<Map<String, dynamic>>, take first record
          return Stadium.fromMap(data.first);
        });
  }
}
