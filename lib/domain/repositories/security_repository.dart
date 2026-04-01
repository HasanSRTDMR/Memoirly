abstract class SecurityRepository {
  Stream<bool> watchLockEnabled();

  Future<void> setLockEnabled(bool enabled);

  Future<bool> hasPin();

  Future<void> setPin(String pin);

  Future<void> clearPin();

  Future<bool> verifyPin(String pin);

  /// Unlocks until app backgrounded — session flag in memory via notifier.
  void setSessionUnlocked(bool unlocked);

  bool get isSessionUnlocked;
}
