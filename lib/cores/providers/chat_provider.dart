import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository(supabase));
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessageModel>, String>(
      (ref, bookingId) =>
          ref.read(chatRepositoryProvider).watchMessages(bookingId),
    );
