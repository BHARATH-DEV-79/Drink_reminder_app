import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id;
  final DateTime dateTime;
  final bool isAutomatic;
  final String message;

  const ReminderModel({
    required this.id,
    required this.dateTime,
    required this.isAutomatic,
    this.message = '💧 Time to Drink Water! Stay Hydrated.',
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'isAutomatic': isAutomatic,
      'message': message,
    };
  }

  // Create from JSON
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      isAutomatic: json['isAutomatic'] as bool,
      message: json['message'] as String? ?? '💧 Time to Drink Water! Stay Hydrated.',
    );
  }

  @override
  List<Object?> get props => [id, dateTime, isAutomatic, message];
}

  // Copy with method for updating
//   ReminderModel copyWith({
//     String? id,
//     DateTime? dateTime,
//     bool? isAutomatic,
//     String? title,
//     String? body,
//   }) {
//     return ReminderModel(
//       id: id ?? this.id,
//       dateTime: dateTime ?? this.dateTime,
//       isAutomatic: isAutomatic ?? this.isAutomatic,
//       title: title ?? this.title,
//       body: body ?? this.body,
//     );
//   }

//   @override
//   String toString() {
//     return 'ReminderModel(id: $id, dateTime: $dateTime, isAutomatic: $isAutomatic)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is ReminderModel && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;
// }