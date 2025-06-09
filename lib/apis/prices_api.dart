import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_ticketing/providers/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sports_ticketing/models/prices_model.dart';

final pricesAPIProvider = Provider((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PricesAPI(supabase: supabase);
});

class PricesAPI {
  final SupabaseClient _supabase;

  PricesAPI({required SupabaseClient supabase}) : _supabase = supabase;

  Stream<Prices> getPrices(String matchId) {
    return _supabase
        .from('prices')
        .stream(primaryKey: ['id'])
        .eq('matchId', matchId)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('No prices found for matchId: $matchId');
          }
          return Prices.fromMap(data.first);
        });
  }
}
