/// Lightweight view of the Firestore `users/{uid}` document.
///
/// Only fields relevant to access control and identity are modelled here — the
/// rest of the profile map is consumed ad-hoc elsewhere. The key addition for
/// the admin interface is [role], which drives [isAdmin].
class UserProfile {
  final String uid;
  final String username;
  final String? email;
  final String? photoUrl;

  /// Access-control role. Currently either `'admin'` or `'user'` (the default
  /// when the field is absent). Stored on the user document and enforced by
  /// Firestore security rules — see `firestore.rules`.
  final String role;

  const UserProfile({
    required this.uid,
    required this.username,
    required this.role,
    this.email,
    this.photoUrl,
  });

  /// Role string used for standard, non-privileged users.
  static const String roleUser = 'user';

  /// Role string that unlocks the in-app admin content tools.
  static const String roleAdmin = 'admin';

  /// Whether this user may access admin-only features.
  bool get isAdmin => role == roleAdmin;

  /// Build a profile from a raw Firestore document map. Returns a safe default
  /// (non-admin) when fields are missing so the UI never crashes on a partial
  /// or legacy document.
  factory UserProfile.fromMap(String uid, Map<String, dynamic>? data) {
    final Map<String, dynamic> map = data ?? const <String, dynamic>{};
    return UserProfile(
      uid: uid,
      username: (map['username'] as String?) ?? '',
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: (map['role'] as String?) ?? roleUser,
    );
  }
}
