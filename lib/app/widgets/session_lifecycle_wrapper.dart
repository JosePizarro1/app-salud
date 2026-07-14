import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/session_service.dart';

class SessionLifecycleWrapper extends StatefulWidget {
  final Widget child;

  const SessionLifecycleWrapper({super.key, required this.child});

  @override
  State<SessionLifecycleWrapper> createState() => _SessionLifecycleWrapperState();
}

class _SessionLifecycleWrapperState extends State<SessionLifecycleWrapper> with WidgetsBindingObserver {
  Timer? _pingTimer;
  final _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Si ya hay un usuario al iniciar la app, empezamos sesión
    if (Supabase.instance.client.auth.currentUser != null) {
      _startSession();
    }

    // Escuchar cambios en el estado de autenticación
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _startSession();
      } else if (event == AuthChangeEvent.signedOut) {
        _stopSession();

        // Evitar deslogeo/redirección si está en modo admin
        final prefs = await SharedPreferences.getInstance();
        final isAdmin = prefs.getBool('is_admin_mode') ?? false;
        if (isAdmin) return;

        if (mounted) {
          final router = GoRouter.of(context);
          final currentPath = router.routeInformationProvider.value.uri.path;
          if (currentPath != '/login' && currentPath != '/register' && currentPath != '/welcome') {
            router.go('/login');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopSession();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Al volver a la app, si no hay sesión activa pero sí usuario, iniciamos
      if (_sessionService.currentSessionId == null && Supabase.instance.client.auth.currentUser != null) {
        _startSession();
      } else {
        _sessionService.pingSession();
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Al salir o minimizar la app
      _stopSession();
    }
  }

  void _startSession() {
    _sessionService.startSession();
    // Iniciar ping cada 5 minutos
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _sessionService.pingSession();
    });
  }

  void _stopSession() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _sessionService.endSession();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
