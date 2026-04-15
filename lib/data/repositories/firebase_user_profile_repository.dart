import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memoirly/domain/entities/user_profile.dart';
import 'package:memoirly/domain/repositories/user_profile_repository.dart';

class FirebaseUserProfileRepository implements UserProfileRepository {
  FirebaseUserProfileRepository({
    required FirebaseFirestore firestore,
    required this.userIdResolver,
  }) : _db = firestore;

  final FirebaseFirestore _db;
  final Future<String?> Function() userIdResolver;

  DocumentReference<Map<String, dynamic>> _profileRef(String uid) =>
      _db.collection('users').doc(uid).collection('userProfile').doc('settings');

  CollectionReference<Map<String, dynamic>> _historyCol(String uid) =>
      _db.collection('users').doc(uid).collection('displayNameHistory');

  UserProfile _fromDoc(Map<String, dynamic>? d) {
    if (d == null) return const UserProfile();
    return UserProfile(
      firstName: (d['firstName'] as String?) ?? '',
      lastName: (d['lastName'] as String?) ?? '',
      email: (d['email'] as String?) ?? '',
      phone: (d['phone'] as String?) ?? '',
    );
  }

  @override
  Stream<UserProfile> watchProfile() async* {
    final uid = await userIdResolver();
    if (uid == null) {
      yield const UserProfile();
      return;
    }
    yield* _profileRef(uid).snapshots().map((s) => _fromDoc(s.data()));
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final uid = await userIdResolver();
    if (uid == null) throw StateError('No user');
    final nf = profile.firstName.trim();
    final nl = profile.lastName.trim();
    final ne = profile.email.trim();
    final np = profile.phone.trim();
    final ref = _profileRef(uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final cur = _fromDoc(snap.data());
      final nameChanged = cur.firstName != nf || cur.lastName != nl;
      final otherChanged = cur.email != ne || cur.phone != np;
      if (!nameChanged && !otherChanged) return;

      if (nameChanged &&
          (cur.firstName.trim().isNotEmpty || cur.lastName.trim().isNotEmpty)) {
        final histRef = _historyCol(uid).doc();
        tx.set(histRef, {
          'firstName': cur.firstName,
          'lastName': cur.lastName,
          'recordedAt': FieldValue.serverTimestamp(),
        });
      }

      tx.set(
        ref,
        {
          'firstName': nf,
          'lastName': nl,
          'email': ne,
          'phone': np,
        },
        SetOptions(merge: true),
      );
    });
  }
}
