class User {
  String userId;
  String email;
  String username;
  String fullName;
  String profilePictureUrl;
  DateTime? dateOfBirth;
  String phoneNumber;
  String address;
  String role;
  DateTime creationDate;

  User({
    required this.userId,
    required this.email,
    required this.username,
    required this.fullName,
    required this.profilePictureUrl,
    this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.creationDate,
  });
}
