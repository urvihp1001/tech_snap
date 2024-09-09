import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String title;
  String description;
  String status;
  DateTime created_at;
  DateTime deadline;
  String assignedTo;
  String explanation;
  String building;
  String floor;
  String room;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.created_at,
    required this.deadline,
    required this.assignedTo,
    required this.building,
    required this.floor,
    required this.room,
    this.explanation = '',
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      status: data['status'],
      created_at: (data['created_at'] as Timestamp).toDate(),
      deadline: (data['deadline'] as Timestamp).toDate(),
      assignedTo: data['assignedTo'],
      building: data['building'],
      floor: data['floor'],
      room: data['room'],
      explanation: data['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'created_at': Timestamp.fromDate(created_at),
      'deadline': Timestamp.fromDate(deadline),
      'assignedTo': assignedTo,
      'building': building,
      'floor': floor,
      'room': room,
      'explanation': explanation,
    };
  }
}
