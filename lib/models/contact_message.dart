import 'package:cloud_firestore/cloud_firestore.dart';

class ContactMessage {
  final String? id;
  final String userId;
  final String name;
  final String email;
  final String inquiryType;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? assignedTo;
  final String? response;

  ContactMessage({
    this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.inquiryType,
    required this.subject,
    required this.message,
    this.status = 'new',
    DateTime? createdAt,
    this.updatedAt,
    this.assignedTo,
    this.response,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory ContactMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactMessage(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      inquiryType: data['inquiryType'] ?? '',
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'new',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      assignedTo: data['assignedTo'],
      response: data['response'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'inquiryType': inquiryType,
      'subject': subject,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'assignedTo': assignedTo,
      'response': response,
    };
  }

  ContactMessage copyWith({
    String? name,
    String? email,
    String? inquiryType,
    String? subject,
    String? message,
    String? status,
    DateTime? updatedAt,
    String? assignedTo,
    String? response,
  }) {
    return ContactMessage(
      id: this.id,
      userId: this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      inquiryType: inquiryType ?? this.inquiryType,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      response: response ?? this.response,
    );
  }
}