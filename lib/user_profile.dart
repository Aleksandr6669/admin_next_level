class UserProfile {
  final String avatarUrl;
  final String firstName;
  final String lastName;
  final String role;
  final String dateOfBirth;
  final String specialty;
  final List<String> skills;
  final String aboutMe;
  final String position;
  final String organization;
  final bool isEditing;

  UserProfile({
    required this.avatarUrl,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.dateOfBirth,
    required this.specialty,
    required this.skills,
    required this.aboutMe,
    required this.position,
    required this.organization,
    required this.isEditing,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      avatarUrl: data['avatarUrl'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: data['role'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      specialty: data['specialty'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      aboutMe: data['aboutMe'] ?? '',
      position: data['position'] ?? '',
      organization: data['organization'] ?? '',
      isEditing: data['isEditing'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avatarUrl': avatarUrl,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'dateOfBirth': dateOfBirth,
      'specialty': specialty,
      'skills': skills,
      'aboutMe': aboutMe,
      'position': position,
      'organization': organization,
      'isEditing': isEditing,
    };
  }

  UserProfile copyWith({
    String? avatarUrl,
    String? firstName,
    String? lastName,
    String? role,
    String? dateOfBirth,
    String? specialty,
    List<String>? skills,
    String? aboutMe,
    String? position,
    String? organization,
    bool? isEditing,
  }) {
    return UserProfile(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      specialty: specialty ?? this.specialty,
      skills: skills ?? this.skills,
      aboutMe: aboutMe ?? this.aboutMe,
      position: position ?? this.position,
      organization: organization ?? this.organization,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}
