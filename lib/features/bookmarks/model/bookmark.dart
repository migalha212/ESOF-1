import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String id;
  final DocumentReference reference;

  Bookmark({required this.id, required this.reference});

  factory Bookmark.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bookmark(
      id: doc.id,
      reference: doc.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }
}
