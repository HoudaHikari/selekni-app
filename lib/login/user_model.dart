class UserModel {
  String name;
  String prename;
  String email;
  String wilaya;
  String phoneNumber;
  String uid;

  UserModel(
      {required this.name,
      required this.prename,
      required this.email,
      required this.wilaya,
      required this.phoneNumber,
      required this.uid});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        wilaya: map['wilaya'] ?? '',
        prename: map['prename'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        uid: map['uid'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "prename": prename,
      "email": email,
      "wilaya": wilaya,
      "phoneNumber": phoneNumber,
      "uid": uid,
    };
  }
}
