import 'package:eco_finder/common_widgets/navbar_widget.dart';
import 'package:eco_finder/features/authentication/presentation/widgets/login_prompt.dart';
import 'package:eco_finder/features/bookmarks/data/bookmark_service.dart';
import 'package:eco_finder/features/bookmarks/model/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/features/bookmarks/presentation/widgets/bookmark_card.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final BookmarksService _bookmarksService = BookmarksService();
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _bookmarks = await _bookmarksService.getUserBookmarks();
      if(!mounted) return;
    } catch (e) {
      if (e == 'User not logged in') {
        LoginPromptDialog.show(context);
        return;
      }
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(selectedIndex: 3),
      appBar: AppBar(
        title: const Text('Bookrmarks'),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF3E8E4D),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
        ),
      ),
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : _errorMessage != null
                ? Text(_errorMessage!)
                : _bookmarks.isEmpty
                ? const Text('No bookmarks found.')
                : ListView.builder(
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    return BookmarkCard(bookmark: _bookmarks[index],
                      onRefresh: _fetchBookmarks);
                  },
                ),
      ),
    );
  }
}
