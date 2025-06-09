import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sports_ticketing/providers/auth_provider.dart';

final storageAPIProvider = Provider((ref) {
  final supabase = Supabase.instance.client;
  final currentUser = ref.watch(currentUserAccountProvider).value;
  return StorageAPI(supabase: supabase, uid: currentUser?.id);
});

class StorageAPI {
  final SupabaseClient _supabase;
  final String? _uid;

  StorageAPI({required SupabaseClient supabase, String? uid})
      : _supabase = supabase,
        _uid = uid;

  Future<List<String>> uploadImage(String bucket, List<File> files) async {
    List<String> imageLinks = [];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final filePath =
          '$bucket/${_uid ?? 'anonymous'}-${DateTime.now().millisecondsSinceEpoch}-$i.jpg';

      final fileBytes = await file.readAsBytes();

      final response = await _supabase.storage.from(bucket).uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      if (response.isEmpty) {
        throw Exception('Image upload failed');
      }

      final url = _supabase.storage.from(bucket).getPublicUrl(filePath);
      imageLinks.add(url);
    }

    return imageLinks;
  }
}
