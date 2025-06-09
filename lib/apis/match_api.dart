import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sports_ticketing/models/match_model.dart';
import 'package:sports_ticketing/providers/supabase_providers.dart';
import 'package:rxdart/rxdart.dart';

final matchAPIProvider = Provider((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return MatchAPI(supabase: supabase);
});

class MatchAPI {
  final SupabaseClient _supabase;

  MatchAPI({required SupabaseClient supabase}) : _supabase = supabase;

  Stream<List<MatchModel>> getMatches() {
    final now = DateTime.now().toIso8601String();
    return _supabase
        .from('matches')
        .select()
        .gt('timestamp', now)
        .order('timestamp', ascending: true)
        .asStream()
        .map((data) => (data as List)
            .map((e) => MatchModel.fromMap(e as Map<String, dynamic>))
            .toList());
  }

  Stream<List<MatchModel>> getNextMatches(MatchModel match) {
    final now = DateTime.now().toIso8601String();
    return _supabase
        .from('matches')
        .select()
        .eq('is_active', true)
        .gt('timestamp', now)
        .order('timestamp', ascending: true)
        .asStream() // convert Future to Stream
        .map((response) {
      final data = response;
      return data
          .map((e) => MatchModel.fromMap(e))
          .where((m) =>
              m.homeTeam == match.homeTeam || m.awayTeam == match.awayTeam)
          .toList();
    });
  }

  Future<MatchModel> getMatch(String id) async {
    final response =
        await _supabase.from('matches').select().eq('id', id).single();
    return MatchModel.fromMap(response);
  }

  Stream<List<MatchModel>> searchMatch(String query) {
    final capitalizedQuery = query.isEmpty
        ? ''
        : '${query[0].toUpperCase()}${query.substring(1).toLowerCase()}';

    final lowerBound = capitalizedQuery;
    final upperBound = '${capitalizedQuery}z';

    final homeQuery = _supabase
        .from('matches')
        .select()
        .gte('homeTeam', lowerBound)
        .lt('homeTeam', upperBound)
        .asStream()
        .map((response) =>
            (response).map((e) => MatchModel.fromMap(e)).toList());

    final awayQuery = _supabase
        .from('matches')
        .select()
        .gte('awayTeam', lowerBound)
        .lt('awayTeam', upperBound)
        .asStream()
        .map((response) =>
            (response).map((e) => MatchModel.fromMap(e)).toList());

    return Rx.combineLatest2<List<MatchModel>, List<MatchModel>,
        List<MatchModel>>(
      homeQuery,
      awayQuery,
      (homeMatches, awayMatches) => [...homeMatches, ...awayMatches],
    );
  }
}
