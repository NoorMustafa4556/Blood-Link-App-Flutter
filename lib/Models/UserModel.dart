class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String bloodGroup;
  final String area;
  final bool isAvailable;
  final String role; // 'user' (dono use kar sakta hai)

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.area,
    this.isAvailable = true,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'area': area,
      'isAvailable': isAvailable,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      area: map['area'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      role: map['role'] ?? 'user',
    );
  }
}
