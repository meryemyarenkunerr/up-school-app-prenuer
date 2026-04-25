import "dart:convert";

import "package:crypto/crypto.dart";

/// Cihaz kimligini dogrudan depolamak yerine hash degeri uretir.
String generateDeviceHash({
  required String rawDeviceId,
  required String appSalt,
}) {
  final bytes = utf8.encode("$appSalt:$rawDeviceId");
  return sha256.convert(bytes).toString();
}
