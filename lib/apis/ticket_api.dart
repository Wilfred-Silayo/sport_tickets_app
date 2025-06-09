import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sports_ticketing/models/ticket_model.dart';
import 'package:sports_ticketing/providers/supabase_providers.dart';
import 'package:sports_ticketing/utils/failure.dart';
import 'package:sports_ticketing/utils/type_defs.dart';

final ticketAPIProvider = Provider((ref) {
  return TicketAPI(
    supabase: ref.watch(supabaseClientProvider),
  );
});

class TicketAPI {
  final SupabaseClient _supabase;

  TicketAPI({required SupabaseClient supabase}) : _supabase = supabase;

  FutureEitherVoid payTicket(TicketModel ticket) async {
    try {
      final response = await _supabase
          .from('tickets')
          .upsert(ticket.toMap(), onConflict: 'ticketNo');
      if (response.error != null) {
        return left(Failure(response.error!.message, StackTrace.current));
      }
      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  FutureEitherVoid deleteTicket(TicketModel ticket) async {
    try {
      final response = await _supabase
          .from('tickets')
          .delete()
          .eq('ticketNo', ticket.ticketNo);
      if (response.error != null) {
        return left(Failure(response.error!.message, StackTrace.current));
      }
      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  FutureEitherVoid cancelTicket(TicketModel ticket) async {
    try {
      final response = await _supabase
          .from('tickets')
          .update(ticket.toMap())
          .eq('ticketNo', ticket.ticketNo);
      if (response.error != null) {
        return left(Failure(response.error!.message, StackTrace.current));
      }
      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  Future<bool> checkTicketAvailability(String id) async {
    final response = await _supabase
        .from('tickets')
        .select()
        .eq('ticketNo', id)
        .maybeSingle();
    return response != null;
  }

  Stream<List<TicketModel>> getUserTickets(String uid) {
    return _supabase
        .from('tickets')
        .stream(primaryKey: ['ticketNo'])
        .eq('uid', uid)
        .order('timestamp', ascending: false)
        .map((data) => (data as List)
            .map((e) => TicketModel.fromMap(e as Map<String, dynamic>))
            .toList());
  }

  Stream<TicketModel> getTicket(String id) {
    return _supabase
        .from('tickets')
        .stream(primaryKey: ['ticketNo'])
        .eq('ticketNo', id)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('Ticket not found');
          }
          return TicketModel.fromMap(data.first);
        });
  }
}
