import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sports_ticketing/models/sales_model.dart';
import 'package:sports_ticketing/providers/supabase_providers.dart';
import 'package:sports_ticketing/utils/failure.dart';
import 'package:sports_ticketing/utils/type_defs.dart';

final salesAPIProvider = Provider(
  (ref) => SalesAPI(
    supabase: ref.watch(supabaseClientProvider),
  ),
);

class SalesAPI {
  final SupabaseClient _supabase;

  SalesAPI({required SupabaseClient supabase}) : _supabase = supabase;

  FutureEitherVoid markSeatAsSold(Sales sale) async {
    try {
      // Try to fetch existing row by id
      final response = await _supabase
          .from('sales')
          .select()
          .eq('id', sale.id)
          .maybeSingle();

      if (response != null) {
        // Document exists, update arrays with new values
        final seatNoList = List<int>.from(response['seatNo'] ?? []);
        final ticketNoList = List<String>.from(response['ticketNo'] ?? []);

        // Add new seatNo and ticketNo if not already present
        final updatedSeatNo = [...seatNoList];
        for (var seat in sale.seatNo) {
          if (!updatedSeatNo.contains(seat)) updatedSeatNo.add(seat);
        }
        final updatedTicketNo = [...ticketNoList];
        for (var ticket in sale.ticketNo) {
          if (!updatedTicketNo.contains(ticket)) updatedTicketNo.add(ticket);
        }

        final updateResponse = await _supabase.from('sales').update({
          'seatNo': updatedSeatNo,
          'ticketNo': updatedTicketNo,
        }).eq('id', sale.id);

        if (updateResponse.error != null) {
          throw updateResponse.error!;
        }
      } else {
        // Document doesn't exist, insert new row
        final insertResponse =
            await _supabase.from('sales').insert(sale.toMap());

        if (insertResponse.error != null) {
          throw insertResponse.error!;
        }
      }

      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  FutureEitherVoid releaseSeat(Sales sale) async {
    try {
      // Fetch existing record
      final response = await _supabase
          .from('sales')
          .select()
          .eq('id', sale.id)
          .maybeSingle();

      if (response == null) {
        // No record to update
        return right(null);
      }

      final seatNoList = List<int>.from(response['seatNo'] ?? []);
      final ticketNoList = List<String>.from(response['ticketNo'] ?? []);

      // Remove the seats and tickets in sale from the lists
      final updatedSeatNo = seatNoList.where((s) => !sale.seatNo.contains(s)).toList();
      final updatedTicketNo = ticketNoList.where((t) => !sale.ticketNo.contains(t)).toList();

      final updateResponse = await _supabase.from('sales').update({
        'seatNo': updatedSeatNo,
        'ticketNo': updatedTicketNo,
      }).eq('id', sale.id);

      if (updateResponse.error != null) {
        throw updateResponse.error!;
      }

      return right(null);
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  Stream<List<int>> checkSeat(String id) {
    // Supabase real-time subscriptions can be handled via `stream()`
    return _supabase
        .from('sales')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
      if (data.isEmpty) {
        return <int>[];
      }
      // data is List<Map<String, dynamic>>, we take first record's seatNo
      final seatNoDynamic = data.first['seatNo'];
      if (seatNoDynamic == null) return <int>[];

      return List<int>.from(seatNoDynamic);
    });
  }
}
