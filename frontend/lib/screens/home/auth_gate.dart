import 'package:flutter/material.dart';
import '../../data/api_client.dart';
import '../../models/water_models.dart';
import '../auth/login_screen.dart';
import 'water_home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _api = ApiClient();
  bool _checking = true;
  bool _signedIn = false;
  AccountUser? _account;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    if (await _api.hasSavedCredentials) {
      try {
        _account = await _api.me();
        _signedIn = true;
      } catch (_) {
        await _api.logout();
      }
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_signedIn) return LoginScreen(api: _api, onSignedIn: _completeSignIn);
    return WaterHomeScreen(
      api: _api,
      account: _account!,
      onLogout: () async {
        await _api.logout();
        if (mounted) {
          setState(() {
            _signedIn = false;
            _account = null;
          });
        }
      },
    );
  }

  Future<void> _completeSignIn() async {
    final account = await _api.me();
    if (mounted) {
      setState(() {
        _account = account;
        _signedIn = true;
      });
    }
  }
}

