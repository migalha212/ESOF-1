import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/features/bookmarks/model/bookmark.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Bookmark>> getUserBookmarks() async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw 'User not logged in';
    }

    try {
      DocumentSnapshot doc =
          await _firestore
              .collection('bookmarks')
              .doc(AuthService().getCurrentUser()?.uid)
              .get();
      if (!doc.exists) {
        return [];
      }

      List<Bookmark> bookmarks = [];
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        for (var id in data['shopIds'] ?? []) {
          DocumentReference ref = _firestore.collection('businesses').doc(id);

          bookmarks.add(Bookmark(id: id, reference: ref,));
        }
      }

      return bookmarks;
    } catch (e) {
      print('Error fetching bookmarks: $e');
      throw 'Failed to fetch bookmarks';
    }
  }

  Future<void> toggleBookmark(String shopId) async {
    User? user = _auth.currentUser;
    if (user == null) throw 'User not logged in';

    DocumentReference userBookmarkRef = _firestore
        .collection('bookmarks')
        .doc(user.uid);

    try {
      DocumentSnapshot snapshot = await userBookmarkRef.get();
      List<String> shopIds = [];

      // If the document exists, get the existing list of shop IDs
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        shopIds = List<String>.from(data['shopIds'] ?? []);
      }

      // Toggle the bookmark
      if (shopIds.contains(shopId)) {
        shopIds.remove(shopId);
      } else {
        shopIds.add(shopId);
      }

      // Create or update the document with the modified list
      await userBookmarkRef.set({'shopIds': shopIds}, SetOptions(merge: true));
    } catch (e) {
      print('Error toggling bookmark: $e');
      throw 'Could not update bookmarks';
    }
  }

  Future<bool> isBookmarked(String shopId) async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    DocumentSnapshot snapshot =
        await _firestore.collection('bookmarks').doc(user.uid).get();

    if (!snapshot.exists) return false;

    List<String> shopIds = List<String>.from(snapshot['shopIds'] ?? []);
    return shopIds.contains(shopId);
  }
}
