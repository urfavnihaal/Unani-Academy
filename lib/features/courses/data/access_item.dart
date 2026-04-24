enum PurchaseType { course, bundle }

class AccessItem {
  final String id;
  final String displayName;
  final PurchaseType purchaseType;
  final DateTime purchasedDate;
  final DateTime expiryDate;
  final List<String>? bundleCourseNames;

  AccessItem({
    required this.id,
    required this.displayName,
    required this.purchaseType,
    required this.purchasedDate,
    required this.expiryDate,
    this.bundleCourseNames,
  });

  bool get isActive => DateTime.now().isBefore(expiryDate);

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;

  factory AccessItem.fromMap(Map<String, dynamic> map) {
    // Map 'type' from DB to PurchaseType enum
    final typeStr = map['type'] as String? ?? 'course';
    final purchaseType = typeStr == 'bundle' ? PurchaseType.bundle : PurchaseType.course;

    // Handle bundleCourseNames from JSONB
    List<String>? bundleCourses;
    if (map['bundle_course_names'] != null) {
      bundleCourses = List<String>.from(map['bundle_course_names']);
    }

    return AccessItem(
      id: map['id'] as String,
      displayName: map['display_name'] as String? ?? (map['courses']?['title'] ?? 'Course'),
      purchaseType: purchaseType,
      purchasedDate: DateTime.parse(map['purchased_at']),
      expiryDate: DateTime.parse(map['expires_at']),
      bundleCourseNames: bundleCourses,
    );
  }
}
