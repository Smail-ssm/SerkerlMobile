class Staff {
  String id; // Unique identifier for the staff member
  String firstName; // First name of the staff member
  String lastName; // Last name of the staff member
  String email; // Email address of the staff member
  String phone; // Phone number of the staff member
  String roleId; // ID of the role assigned to the staff member
  String departmentId; // ID of the department to which the staff member belongs
  DateTime startDate; // Start date of the staff member's employment
  String status; // Status of the staff member (e.g., Active, Inactive)

  Staff({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.roleId,
    required this.departmentId,
    required this.startDate,
    required this.status,
  });

  // Factory constructor for creating a Staff from a JSON object
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      roleId: json['roleId'],
      departmentId: json['departmentId'],
      startDate: DateTime.parse(json['startDate']),
      status: json['status'],
    );
  }

  // Method for converting a Staff instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'roleId': roleId,
      'departmentId': departmentId,
      'startDate': startDate.toIso8601String(),
      'status': status,
    };
  }
}
