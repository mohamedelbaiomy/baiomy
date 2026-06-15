import 'package:baiomy/utils/logger_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baiomy/firebase/firestore_repo.dart';

class BaiomyAuthRepo {
  BaiomyAuthRepo._();

  static final BaiomyAuthRepo instance = BaiomyAuthRepo._();

  static final FirebaseAuth auth = FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------------------------

  User? get currentUser => auth.currentUser;

  /// Returns the current user's UID, or null if no user is signed in.
  String? get uid => currentUser?.uid;

  /// Returns true if a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  /// Returns true if the current user is anonymous (guest).
  bool get isGuest => currentUser?.isAnonymous ?? false;

  /// Stream that emits whenever the auth state changes (sign in / sign out).
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // SIGN UP / SIGN IN
  // ---------------------------------------------------------------------------

  /// Creates a new account with [email] and [password].
  /// Throws [FirebaseAuthException] on failure — handle in the provider/caller.
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async => await auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  /// Signs in an existing user with [email] and [password].
  /// Throws [FirebaseAuthException] on failure — handle in the provider/caller.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async =>
      await auth.signInWithEmailAndPassword(email: email, password: password);

  /// Signs in anonymously (guest mode).
  /// Throws [FirebaseAuthException] on failure — handle in the provider/caller.
  Future<UserCredential> signInAnonymously() async =>
      await auth.signInAnonymously();

  // ---------------------------------------------------------------------------
  // EMAIL VERIFICATION
  // ---------------------------------------------------------------------------

  /// Sends a verification email to the current user.
  /// Throws if no user is signed in or the request fails.
  Future<void> sendEmailVerification() async =>
      await currentUser!.sendEmailVerification();

  /// Reloads the current user's data from Firebase, then returns
  /// whether their email is verified.
  Future<bool> checkEmailVerification() async {
    await currentUser!.reload();
    return auth.currentUser?.emailVerified ?? false;
  }

  // ---------------------------------------------------------------------------
  // PROFILE UPDATES
  // ---------------------------------------------------------------------------

  /// Reloads the current user's profile data from Firebase.
  Future<void> reloadUserData() async => await currentUser!.reload();

  /// Updates the current user's display name.
  Future<void> updateUserName(String displayName) async =>
      await currentUser!.updateDisplayName(displayName);

  /// Updates the current user's password.
  /// Throws [FirebaseAuthException] on failure — handle in the provider/caller.
  Future<void> updateUserPassword(String newPassword) async =>
      await currentUser!.updatePassword(newPassword);

  // ---------------------------------------------------------------------------
  // PASSWORD RESET
  // ---------------------------------------------------------------------------

  /// Sends a password reset email to [email].
  /// Throws [FirebaseAuthException] on failure — handle in the provider/caller.
  Future<void> sendPasswordResetEmail(String email) async =>
      await auth.sendPasswordResetEmail(email: email);

  /// Re-authenticates the current user with [email] and [password] to verify
  /// their old password. Returns true if successful, false otherwise.
  Future<bool> checkOldPassword(String email, String password) async {
    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final UserCredential result = await currentUser!
          .reauthenticateWithCredential(credential);
      return result.user != null;
    } on FirebaseAuthException catch (e) {
      BaiomyLogger.error('checkOldPassword failed: ${e.code} — ${e.message}');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // SIGN OUT
  // ---------------------------------------------------------------------------

  /// Signs out the current user.
  Future<void> logOut() async => await auth.signOut();

  // ---------------------------------------------------------------------------
  // GUEST → PERMANENT ACCOUNT UPGRADE
  // ---------------------------------------------------------------------------

  /// Upgrades an anonymous (guest) account to a permanent email/password account.
  ///
  /// Steps:
  /// 1. Validates that a guest user is currently signed in.
  /// 2. Links the guest account with an [email] / [password] credential.
  /// 3. Updates the display name to [name].
  /// 4. Sends an email verification.
  /// 5. Reloads the user to get the latest state.
  /// 6. Updates the Firestore user document with the new account details.
  ///
  /// ⚠️ NOTE: Storing plain-text passwords in Firestore is a security risk.
  /// Consider removing the 'password' field and relying on Firebase Auth only.
  ///
  /// Throws [FirebaseAuthException] or [Exception] on failure —
  /// handle toasts and UI feedback in the provider/caller.
  Future<void> upgradeGuestToUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final User? user = auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    if (!user.isAnonymous) {
      throw Exception('Current user is not a guest account.');
    }

    // 1. Link the guest account with the email/password credential
    final AuthCredential emailCredential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final UserCredential userCredential = await user.linkWithCredential(
      emailCredential,
    );
    final User upgradedUser = userCredential.user!;

    // 2. Update display name
    await upgradedUser.updateDisplayName(name);

    // 3. Send email verification
    await upgradedUser.sendEmailVerification();

    // 4. Reload to get the latest user state
    await upgradedUser.reload();

    // 5. Update the Firestore user document
    // ⚠️ Avoid storing plain-text passwords — remove 'password' field when possible.
    await BaiomyFirestoreRepo.instance.updateData(
      collectionName: 'users',
      docName: upgradedUser.uid,
      data: <String, dynamic>{
        'email': email,
        'name': name,
        'uid': upgradedUser.uid,
        'phone': phone,
        'role': 'user',
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  /// Maps a [FirebaseAuthException] code from an upgrade attempt to a
  /// user-friendly message.
  String getUpgradeErrorMessage(FirebaseAuthException e) => switch (e.code) {
    'email-already-in-use' => 'This email is already registered',
    'invalid-email' => 'Please enter a valid email address',
    'weak-password' => 'Password should be at least 6 characters',
    'requires-recent-login' => 'Session expired. Please sign in again',
    _ => 'Account upgrade failed: ${e.message}',
  };

  /// Maps any [FirebaseAuthException] code to a user-friendly message.
  String getAuthErrorMessage(FirebaseAuthException e) => switch (e.code) {
    'user-not-found' => 'No account found with this email',
    'wrong-password' => 'Incorrect password',
    'invalid-email' => 'Please enter a valid email address',
    'user-disabled' => 'This account has been disabled',
    'email-already-in-use' => 'This email is already registered',
    'weak-password' => 'Password should be at least 6 characters',
    'network-request-failed' => 'Check your internet connection',
    'too-many-requests' => 'Too many attempts. Please try again later',
    'requires-recent-login' => 'Session expired. Please sign in again',
    _ => e.message ?? 'An unexpected error occurred',
  };
}
