import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, admin }

class UserModel {
  final String id;
  final String email;
  final String studentId;
  final String fullName;
  final String department;
  final String year;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.studentId,
    required this.fullName,
    required this.department,
    required this.year,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      studentId: data['studentId'] ?? '',
      fullName: data['fullName'] ?? '',
      department: data['department'] ?? '',
      year: data['year'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.student,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'studentId': studentId,
      'fullName': fullName,
      'department': department,
      'year': year,
      'role': role.name,
      'createdAt': createdAt,
    };
  }

  bool get isAdmin => role == UserRole.admin;

  static bool isValidCollegeEmail(String email) {
    return email.toLowerCase().endsWith('@nec.edu.in');
  }
}

class Department {
  static const List<String> departments = [
    'CSE',
    'IT',
    'ECE',
    'EEE',
    'Mechanical',
    'Civil',
    'Computer Application',
    'Data Science',
    'AI & ML',
    'Cyber Security',
  ];

  static const List<String> years = [
    'I Year',
    'II Year',
    'III Year',
    'IV Year',
  ];
}
