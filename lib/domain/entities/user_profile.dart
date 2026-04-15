import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  /// Trimmed "Ad Soyad" for greetings; empty if both blank.
  String get fullNameForGreeting {
    final t = '${firstName.trim()} ${lastName.trim()}'.trim();
    return t;
  }

  @override
  List<Object?> get props => [firstName, lastName, email, phone];
}
