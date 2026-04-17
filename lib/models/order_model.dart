import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cart_item_model.dart';

enum OrderStatus {
  pending,
  accepted,
  ready,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case pending:
        return 'Pending';
      case accepted:
        return 'Taken';
      case ready:
        return 'Ready';
      case completed:
        return 'Completed';
      case cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'preparing' || normalized == 'taken') {
      return accepted;
    }
    if (normalized == 'collected' || normalized == 'given') {
      return completed;
    }
    return values.firstWhere(
      (e) => e.name == normalized,
      orElse: () => pending,
    );
  }
}

class OrderModel {
  final String id;
  final String orderId;
  final int tokenNumber;
  final String userId;
  final String userName;
  final String studentId;
  final String department;
  final String canteenDepartment;
  final List<CartItemModel> items;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? paymentMethod;
  final String paymentStatus;
  final String paymentReference;
  final String pickupCode;
  final int estimatedWaitTime;
  final int queuePosition;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.tokenNumber,
    required this.userId,
    required this.userName,
    required this.studentId,
    required this.department,
    required this.canteenDepartment,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentMethod,
    this.completedAt,
    this.cancelledAt,
    this.paymentStatus = 'Paid',
    required this.paymentReference,
    required this.pickupCode,
    this.estimatedWaitTime = 15,
    this.queuePosition = 1,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<CartItemModel> items = [];
    if (json['items'] != null) {
      items = (json['items'] as List).map((item) {
        return CartItemModel.fromJson(item as Map<String, dynamic>);
      }).toList();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderId:
          json['order_id']?.toString() ?? json['orderId']?.toString() ?? '',
      tokenNumber: json['token_number'] ?? json['tokenNumber'] ?? 0,
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName:
          json['user_name']?.toString() ?? json['userName']?.toString() ?? '',
      studentId:
          json['student_id']?.toString() ?? json['studentId']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      canteenDepartment: json['canteen_department']?.toString() ??
          json['canteenDepartment']?.toString() ??
          '',
      items: items,
      totalPrice: double.tryParse(json['total_price']?.toString() ??
              json['totalPrice']?.toString() ??
              '0') ??
          0.0,
      status: OrderStatus.fromString(json['status']?.toString() ?? 'pending'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : json['completedAt'] != null
              ? DateTime.parse(json['completedAt'])
              : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : json['cancelledAt'] != null
              ? DateTime.parse(json['cancelledAt'])
              : null,
      paymentMethod: json['payment_method'] ?? json['paymentMethod'],
      paymentStatus: json['payment_status']?.toString() ??
          json['paymentStatus']?.toString() ??
          'Paid',
      paymentReference: json['payment_reference']?.toString() ??
          json['paymentReference']?.toString() ??
          '',
      pickupCode: json['pickup_code']?.toString() ??
          json['pickupCode']?.toString() ??
          '',
      estimatedWaitTime:
          json['estimated_wait_time'] ?? json['estimatedWaitTime'] ?? 15,
      queuePosition: json['queue_position'] ?? json['queuePosition'] ?? 1,
    );
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<CartItemModel> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List).map((item) {
        return CartItemModel.fromJson(item as Map<String, dynamic>);
      }).toList();
    }

    return OrderModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      tokenNumber: data['tokenNumber'] ?? 0,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      studentId: data['studentId'] ?? '',
      department: data['department'] ?? '',
      canteenDepartment: data['canteenDepartment'] ?? '',
      items: items,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: OrderStatus.fromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'] ?? 'Paid',
      paymentReference: data['paymentReference'] ?? '',
      pickupCode: data['pickupCode'] ?? '',
      estimatedWaitTime: data['estimatedWaitTime'] ?? 15,
      queuePosition: data['queuePosition'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'tokenNumber': tokenNumber,
      'userId': userId,
      'userName': userName,
      'studentId': studentId,
      'department': department,
      'canteenDepartment': canteenDepartment,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentReference': paymentReference,
      'pickupCode': pickupCode,
      'estimatedWaitTime': estimatedWaitTime,
      'queuePosition': queuePosition,
    };
  }

  String get statusDisplay => status.displayName;

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.completed:
        return const Color(0xFF1B8A5A);
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  OrderModel copyWith({
    String? id,
    String? orderId,
    int? tokenNumber,
    String? userId,
    String? userName,
    String? studentId,
    String? department,
    String? canteenDepartment,
    List<CartItemModel>? items,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentReference,
    String? pickupCode,
    int? estimatedWaitTime,
    int? queuePosition,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      canteenDepartment: canteenDepartment ?? this.canteenDepartment,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentReference: paymentReference ?? this.paymentReference,
      pickupCode: pickupCode ?? this.pickupCode,
      estimatedWaitTime: estimatedWaitTime ?? this.estimatedWaitTime,
      queuePosition: queuePosition ?? this.queuePosition,
    );
  }
}
