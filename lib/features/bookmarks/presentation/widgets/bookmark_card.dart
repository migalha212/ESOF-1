import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/bookmarks/model/bookmark.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';

class BookmarkCard extends StatefulWidget {
  final Bookmark bookmark;
  final VoidCallback onRefresh;

  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.onRefresh,
  });

  @override
  State<BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard> {
  String? shopName;
  String? shopDescription;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopData();
  }

  Future<void> _fetchShopData() async {
    try {
      DocumentSnapshot shopSnapshot = await widget.bookmark.reference.get();

      if (shopSnapshot.exists) {
        Map<String, dynamic> data = shopSnapshot.data() as Map<String, dynamic>;
        setState(() {
          shopName = data['name'] ?? 'Unnamed Shop';
          shopDescription = data['description'] ?? 'No description available.';
        });
      } else {
        setState(() {
          shopName = 'Shop not found';
          shopDescription = '';
        });
      }
    } catch (e) {
      print('Error fetching shop data: $e');
      setState(() {
        shopName = 'Error';
        shopDescription = 'Unable to load data.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToShop(BuildContext context) async {
    await Navigator.pushNamed(
      context,
      NavigationItems.navBookmarksProfile.route,
      arguments: widget.bookmark.reference,
    );
    widget.onRefresh(); // Refresh bookmarks after returning
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.shopping_bag, color: Colors.green),
        title:
            isLoading
                ? const Text('Loading...')
                : Text(
                  shopName ?? 'Unnamed Shop',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        subtitle:
            isLoading
                ? null
                : Text(shopDescription ?? 'No description available.',
                        maxLines: 4,
            ),
        onTap: () => _navigateToShop(context),
      ),
    );
  }
}
