// lib/data/model/user_model.dart
class UserModel {
  String? usersId;
  String? usersName;
  String? usersEmail;
  String? usersPhone;
  String? usersDescription;
  String? usersImage;
  String? usersCreatedate;

  UserModel({
    this.usersId,
    this.usersName,
    this.usersEmail,
    this.usersPhone,
    this.usersDescription,
    this.usersImage,
    this.usersCreatedate,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    usersId = json['users_id'];
    usersName = json['users_name'];
    usersEmail = json['users_email'];
    usersPhone = json['users_phone'];
    usersDescription = json['users_description'];
    usersImage = json['users_image'];
    usersCreatedate = json['users_createdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['users_id'] = usersId;
    data['users_name'] = usersName;
    data['users_email'] = usersEmail;
    data['users_phone'] = usersPhone;
    data['users_description'] = usersDescription;
    data['users_image'] = usersImage;
    data['users_createdate'] = usersCreatedate;
    return data;
  }

  // نسخ الكائن مع تعديل بعض القيم
  UserModel copyWith({
    String? usersId,
    String? usersName,
    String? usersEmail,
    String? usersPhone,
    String? usersDescription,
    String? usersImage,
    String? usersCreatedate,
  }) {
    return UserModel(
      usersId: usersId ?? this.usersId,
      usersName: usersName ?? this.usersName,
      usersEmail: usersEmail ?? this.usersEmail,
      usersPhone: usersPhone ?? this.usersPhone,
      usersDescription: usersDescription ?? this.usersDescription,
      usersImage: usersImage ?? this.usersImage,
      usersCreatedate: usersCreatedate ?? this.usersCreatedate,
    );
  }

  @override
  String toString() {
    return 'UserModel(usersId: $usersId, usersName: $usersName, usersEmail: $usersEmail, usersPhone: $usersPhone, usersDescription: $usersDescription, usersImage: $usersImage, usersCreatedate: $usersCreatedate)';
  }
}
