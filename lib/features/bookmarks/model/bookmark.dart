import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String id;
  final DocumentReference reference;

  Bookmark({required this.id, required this.reference});

  factory Bookmark.fromDocument(DocumentSnapshot doc) {
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
