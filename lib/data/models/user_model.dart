/// Model untuk pengguna/User
class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? profilePicture;
  final String? profilePictureUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.profilePicture,
    this.profilePictureUrl,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: (json['phoneNumber'] ?? json['phone_number'])?.toString(),
      dateOfBirth: (json['dateOfBirth'] ?? json['date_of_birth'])?.toString(),
      gender: json['gender']?.toString(),
      profilePicture: (json['profilePicture'] ?? json['profile_picture'])
          ?.toString(),
      profilePictureUrl:
          (json['profilePictureUrl'] ?? json['profile_picture_url'])
              ?.toString(),
      isVerified: json['isVerified'] == true || json['is_verified'] == true,
      createdAt: DateTime.parse(
        (json['createdAt'] ??
                json['created_at'] ??
                DateTime.now().toIso8601String())
            as String,
      ),
      updatedAt: DateTime.parse(
        (json['updatedAt'] ??
                json['updated_at'] ??
                DateTime.now().toIso8601String())
            as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'profilePicture': profilePicture,
      'profilePictureUrl': profilePictureUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // CopyWith untuk update data
  User copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? profilePicture,
    String? profilePictureUrl,
    bool? isVerified,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profilePicture: profilePicture ?? this.profilePicture,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
