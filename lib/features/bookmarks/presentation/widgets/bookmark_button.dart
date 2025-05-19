import 'package:eco_finder/features/authentication/data/auth_service.dart';
import 'package:eco_finder/features/authentication/presentation/widgets/login_prompt.dart';
import 'package:eco_finder/features/bookmarks/data/bookmark_service.dart';
import 'package:flutter/material.dart';

class BookmarkButton extends StatefulWidget {
  final String shopId;

  const BookmarkButton({
    super.key,
    required this.shopId,
    required shopReference,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  final BookmarksService _bookmarksService = BookmarksService();
  bool _isBookmarked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      bool isBookmarked = await _bookmarksService.isBookmarked(widget.shopId);
      setState(() {
        _isBookmarked = isBookmarked;
      });
    } catch (e) {
      print('Error checking bookmark status: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() => _isLoading = true);
    if (AuthService().getCurrentUser() == null) {
      // Show login prompt if user is not logged in
      LoginPromptDialog.show(context);
      setState(() => _isLoading = false);
      return;
    }
    try {
      await _bookmarksService.toggleBookmark(widget.shopId);
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
    } catch (e) {
      print('Error toggling bookmark: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      onPressed: _isLoading ? null : _toggleBookmark,
      backgroundColor: _isBookmarked ? Colors.red : Colors.green,
      tooltip: _isBookmarked ? 'Remove from Bookmarks' : 'Add to Bookmarks',
      child:
          _isLoading
              ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
              : Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
    );
  }
}
