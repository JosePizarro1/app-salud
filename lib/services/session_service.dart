import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final _supabase = Supabase.instance.client;
  String? _currentSessionId;

  String? get currentSessionId => _currentSessionId;

  /// Inicia una nueva sesión para el usuario actual
  Future<void> startSession() async {
    final user = _supabase.auth.currentUser;
    if (user == null || _currentSessionId != null) return;

    try {
      final response = await _supabase.from('user_sessions').insert({
        'user_id': user.id,
        'login_at': DateTime.now().toIso8601String(),
        'last_ping_at': DateTime.now().toIso8601String(),
      }).select('id').single();

      _currentSessionId = response['id'];
      dev.log('Sesión iniciada: $_currentSessionId');
    } catch (e) {
      dev.log('Error al iniciar sesión: $e');
    }
  }

  /// Actualiza el último ping de la sesión actual
  Future<void> pingSession() async {
    if (_currentSessionId == null) return;

    try {
      await _supabase
          .from('user_sessions')
          .update({'last_ping_at': DateTime.now().toIso8601String()})
          .eq('id', _currentSessionId!);
      dev.log('Ping enviado para la sesión: $_currentSessionId');
    } catch (e) {
      dev.log('Error al enviar ping: $e');
    }
  }

  /// Finaliza la sesión actual
  Future<void> endSession() async {
    if (_currentSessionId == null) return;

    try {
      await _supabase
          .from('user_sessions')
          .update({
            'logout_at': DateTime.now().toIso8601String(),
            'last_ping_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentSessionId!);
      dev.log('Sesión finalizada: $_currentSessionId');
      _currentSessionId = null;
    } catch (e) {
      dev.log('Error al finalizar sesión: $e');
    }
  }
}
