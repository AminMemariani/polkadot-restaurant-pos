import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../pages/sign_in_page.dart';

/// Renders [child] only when a Supabase session exists; shows [SignInPage]
/// otherwise. When Supabase is unconfigured, lets [child] through unchanged
/// — this keeps blockchain/cash flows working in environments without auth.
///
/// Listens to [SupabaseClient.auth.onAuthStateChange] so sign-in / sign-out
/// updates the UI without manual navigation.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isSupabaseConfigured) return child;

    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Use the live session, not the snapshot event payload — that way
        // we render correctly on the very first frame (before any event).
        final session = auth.currentSession;
        if (session == null) return const SignInPage();
        return child;
      },
    );
  }
}
