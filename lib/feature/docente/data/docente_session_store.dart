import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DocenteSession {
  final String sessionId;
  final String userAgent;

  const DocenteSession({required this.sessionId, required this.userAgent});
}

/// Keeps the SPID/CIE web session in secure storage. No credentials are
/// stored: when the session expires the user signs in again.
class DocenteSessionStore {
  static const _sessionKey = 'docente_web_session_id';
  static const _userAgentKey = 'docente_web_user_agent';

  final FlutterSecureStorage storage;

  DocenteSessionStore(this.storage);

  Future<DocenteSession?> read() async {
    final sessionId = await storage.read(key: _sessionKey);
    final userAgent = await storage.read(key: _userAgentKey);
    if (sessionId == null || sessionId.isEmpty || userAgent == null) {
      return null;
    }
    return DocenteSession(sessionId: sessionId, userAgent: userAgent);
  }

  Future<void> write(DocenteSession session) async {
    await storage.write(key: _sessionKey, value: session.sessionId);
    await storage.write(key: _userAgentKey, value: session.userAgent);
  }

  Future<void> clear() async {
    await storage.delete(key: _sessionKey);
    await storage.delete(key: _userAgentKey);
  }
}
