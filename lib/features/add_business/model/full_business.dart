class SustainableBusiness {
  String id;
  String name;
  String description;
  double latitude;
  double longitude;
  List<String> primaryCategories;
  Map<String, dynamic> subcategories;
  String address;
  String contactPhone;
  String website;
  List<String> certifications;
  String uid;
  String imageUrl;

  SustainableBusiness({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.primaryCategories,
    required this.subcategories,
    required this.address,
    required this.contactPhone,
    required this.website,
    required this.certifications,
    required this.uid,
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'name_lowercase': name.toLowerCase(),
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'primaryCategories': primaryCategories,
      'subcategories': subcategories,
      'address': address,
      'contactPhone': contactPhone,
      'website': website,
      'certifications': certifications,
      'imageUrl': imageUrl,
      'uid': uid,
    };
  }
}
