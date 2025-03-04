import 'event.dart';

class UserProfile {
  final String name;
  final String email;
  final String membershipStatus;
  final String? profileImage;
  final List<Event> savedEvents;

  UserProfile({
    required this.name,
    required this.email,
    required this.membershipStatus,
    this.profileImage,
    required this.savedEvents,
  });
}