import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final SupabaseClient client;
  ChatRepository(this.client);
  Stream<List<ChatMessageModel>> watchMessages(String bookingId) => client
      .from('chat_messages')
      .stream(primaryKey: ['id'])
      .eq('booking_id', bookingId)
      .order('created_at')
      .map((rows) => rows.map((e) => ChatMessageModel.fromMap(e)).toList());
  Future<void> send({
    required String bookingId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;
    await client.from('chat_messages').insert({
      'booking_id': bookingId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message.trim(),
    });
  }
}
