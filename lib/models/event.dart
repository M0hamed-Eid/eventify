import 'package:cloud_firestore/cloud_firestore.dart';

class Event {

  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final bool isOnline;
  final bool isAccMembersOnly;
  final String timeRange;
  final String? registrationLink;
  final String? meetingId;
  final String? passcode;
  final String? imageUrl;
  final String? presenter;
  final String? presenterTitle;
  final List<String> guidelines;
  final String category;
  final String? series;
  final int currentParticipants;
  final int maxParticipants;


  final DateTime? endDateTime;
  final List<String> requirements;
  final DateTime? applicationDeadline;
  final bool requiresRegistration;
  final String? targetAudience;
  final List<String> technicalRequirements;
  final List<String> programEtiquette;
  final String? contactEmail;
  final String? programType;
  final bool isCertificateAvailable;
  final String? certificateRequirements;
  final bool notificationSent;
  final DateTime? notificationSentAt;


  // New fields for ACC guidelines
  final List<String> entryGuidelines;
  final int? minimumAge;
  final List<String> allowedIdentificationTypes;
  final DateTime? openingTime;
  final DateTime? closingTime;
  final bool noEntryAfterTime;
  final List<String> securityRestrictions;
  final List<String> electronicRestrictions;
  final bool requireConfirmationEmail;
  final bool mediaConsent;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.isOnline,
    required this.isAccMembersOnly,
    required this.timeRange,
    this.registrationLink,
    this.meetingId,
    this.passcode,
    this.imageUrl,
    this.presenter,
    this.presenterTitle,
    required this.guidelines,
    required this.category,
    this.series,
    this.currentParticipants = 0 ,
    this.maxParticipants = 50,

    this.endDateTime,
    this.requirements = const [],
    this.applicationDeadline,
    this.requiresRegistration = false,
    this.targetAudience,
    this.technicalRequirements = const [],
    this.programEtiquette = const [],
    this.contactEmail,
    this.programType,
    this.isCertificateAvailable = false,
    this.certificateRequirements,

    this.notificationSent = false,
    this.notificationSentAt,


    // New optional parameters
    this.entryGuidelines = const [],
    this.minimumAge,
    this.allowedIdentificationTypes = const [
      'National Identity Card',
      'Passport',
      'Driver\'s License'
    ],
    this.openingTime,
    this.closingTime,
    this.noEntryAfterTime = false,
    this.securityRestrictions = const [],
    this.electronicRestrictions = const [
      'Mobile phones',
      'Computers',
      'Tablets',
      'Chargers',
      'Smart watches',
      'Flash drives',
      'Bluetooth devices'
    ],
    this.requireConfirmationEmail = false,
    this.mediaConsent = false,


  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: data['dateTime'] != null
          ? (data['dateTime'] as Timestamp).toDate()
          : DateTime.now(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      isOnline: data['isOnline'] ?? false,
      isAccMembersOnly: data['isAccMembersOnly'] ?? false,
      timeRange: data['timeRange'] ?? '',
      registrationLink: data['registrationLink'],
      meetingId: data['meetingId'],
      passcode: data['passcode'],
      presenter: data['presenter'],
      presenterTitle: data['presenterTitle'],
      guidelines: data['guidelines'] != null
          ? List<String>.from(data['guidelines'])
          : [],
      category: data['category'] ?? '',
      series: data['series'],
      currentParticipants: data['currentParticipants'] ?? 0,
      maxParticipants: data['maxParticipants'] ?? 50,



      notificationSent: data['notificationSent'] ?? false,
      notificationSentAt: (data['notificationSentAt'] as Timestamp?)?.toDate(),


      // New field mappings
      entryGuidelines: data['entryGuidelines'] != null
          ? List<String>.from(data['entryGuidelines'])
          : [],
      minimumAge: data['minimumAge'],
      allowedIdentificationTypes: data['allowedIdentificationTypes'] != null
          ? List<String>.from(data['allowedIdentificationTypes'])
          : ['National Identity Card', 'Passport', 'Driver\'s License'],
      openingTime: data['openingTime'] != null
          ? (data['openingTime'] as Timestamp).toDate()
          : null,
      closingTime: data['closingTime'] != null
          ? (data['closingTime'] as Timestamp).toDate()
          : null,
      noEntryAfterTime: data['noEntryAfterTime'] ?? false,
      securityRestrictions: data['securityRestrictions'] != null
          ? List<String>.from(data['securityRestrictions'])
          : [],
      electronicRestrictions: data['electronicRestrictions'] != null
          ? List<String>.from(data['electronicRestrictions'])
          : [
        'Mobile phones',
        'Computers',
        'Tablets',
        'Chargers',
        'Smart watches',
        'Flash drives',
        'Bluetooth devices'
      ],
      requireConfirmationEmail: data['requireConfirmationEmail'] ?? false,
      mediaConsent: data['mediaConsent'] ?? false,
    );
  }

  // Also update toMap method to match
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'imageUrl': imageUrl,
      'isOnline': isOnline,
      'isAccMembersOnly': isAccMembersOnly,
      'timeRange': timeRange,
      'registrationLink': registrationLink,
      'meetingId': meetingId,
      'passcode': passcode,
      'presenter': presenter,
      'presenterTitle': presenterTitle,
      'guidelines': guidelines,
      'category': category,
      'series': series,
      'currentParticipants': currentParticipants,
      'maxParticipants': maxParticipants,

      'notificationSent': notificationSent,
      'notificationSentAt': notificationSentAt != null ? Timestamp.fromDate(notificationSentAt!) : null,


// New field mappings
      'entryGuidelines': entryGuidelines,
      'minimumAge': minimumAge,
      'allowedIdentificationTypes': allowedIdentificationTypes,
      'openingTime': openingTime != null
          ? Timestamp.fromDate(openingTime!)
          : null,
      'closingTime': closingTime != null
          ? Timestamp.fromDate(closingTime!)
          : null,
      'noEntryAfterTime': noEntryAfterTime,
      'securityRestrictions': securityRestrictions,
      'electronicRestrictions': electronicRestrictions,
      'requireConfirmationEmail': requireConfirmationEmail,
      'mediaConsent': mediaConsent,
    };
  }

  static List empty() {
    return [];
  }
}