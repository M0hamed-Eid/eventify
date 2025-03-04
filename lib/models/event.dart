class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String? imageUrl;
  final String? registrationLink;
  final bool isOnline;
  final bool isAccMembersOnly;
  final String? meetingId;
  final String? passcode;
  final String? timeRange;
  final List<String> guidelines;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    this.imageUrl,
    this.registrationLink,
    required this.isOnline,
    required this.isAccMembersOnly,
    this.meetingId,
    this.passcode,
    required this.timeRange,
    required this.guidelines,
  });
}