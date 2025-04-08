import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  // Function to perform the search
  Future<void> _searchMarkets() async {
    String query = _searchController.text;
    QuerySnapshot querySnapshot;
    if (query.isNotEmpty) {
      querySnapshot = await FirebaseFirestore.instance
          .collection('businesses')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('businesses')
          .get();
    }
    setState(() {
      _searchResults = querySnapshot.docs;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchMarkets);
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchMarkets);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search EcoMarkets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search EcoMarkets...',
                hintText: 'Type the market name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            // Display Search Results
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(child: Text('No results found'))
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var data = _searchResults[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Icon(Icons.shopping_bag, color: Colors.green),
                      title: Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['description'] ?? 'No description available'),
                      onTap: () {
                        // Optionally, you can navigate to a detail page
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => MarketDetailPage(marketData: data)));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}