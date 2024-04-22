class ProfileModel {
  String? name;
  String? email;
  String? phoneNumber;
  String? profilePic;

  // Constructor for initializing the model with optional values
  ProfileModel({
    this.name,
    this.email,
    this.phoneNumber,
    this.profilePic,
  });

  // Factory constructor to create a ProfileModel from a map (e.g., Firebase document data)
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map['name'] as String?,
      email: map['email'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      profilePic: map['profilePic'] as String?,
    );
  }

  // Method to convert the ProfileModel to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      // Add other fields as needed
    };
  }
}
