import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _filterScrollController = ScrollController();
  List<DocumentSnapshot> _searchResults = [];
  bool _isFilterExpanded = false;

  final Map<String, String> _filterCategories = {
    'Alimentos': '🍏',
    'Roupas': '👗',
    'Itens Colecionáveis': '🎁',
    'Decoração': '🏡',
    'Eletrónicos': '📱',
    'Brinquedos': '🧸',
    'Saúde & Beleza': '💄',
    'Artesanato': '🧵',
    'Livros': '📚',
    'Desportos & Lazer': '⚽',
  };

  final List<String> _selectedFilterCategories = [];

  Future<void> _searchMarkets() async {
    String query = _searchController.text.toLowerCase().trim();
    QuerySnapshot querySnapshot;
    if (query.isNotEmpty) {
      querySnapshot =
          await FirebaseFirestore.instance
              .collection('businesses')
              .where('name_lowercase', isGreaterThanOrEqualTo: query)
              .where('name_lowercase', isLessThanOrEqualTo: '$query\uf8ff')
              .get();
    } else {
      querySnapshot =
          await FirebaseFirestore.instance.collection('businesses').get();
    }

    List<DocumentSnapshot> docs =
        querySnapshot.docs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if (_selectedFilterCategories.isEmpty) return true;

          List<dynamic>? docCats = data['primaryCategories'];

          return docCats != null &&
              _selectedFilterCategories.any((cat) => docCats.contains(cat));
        }).toList();

    setState(() {
      _searchResults = docs;
    });
  }

  Widget _buildFilterList() {
    return Column(
      children:
          _filterCategories.entries.map((entry) {
            bool selected = _selectedFilterCategories.contains(entry.key);
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('${entry.value} ${entry.key}'),
              trailing: Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: selected ? Colors.green : null,
              ),
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedFilterCategories.remove(entry.key);
                  } else {
                    _selectedFilterCategories.add(entry.key);
                  }
                });
              },
            );
          }).toList(),
    );
  }

  Widget _buildFilterPanel() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isFilterExpanded ? 300 : 0,
      child: Scrollbar(
        controller: _filterScrollController,
        thumbVisibility: true,
        scrollbarOrientation: ScrollbarOrientation.left,
        child: SingleChildScrollView(
          controller: _filterScrollController,
          child: Padding(
            padding: EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                _buildFilterList(),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _searchMarkets();
                    setState(() {
                      _isFilterExpanded = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3E8E4D),
                  ),
                  child: Text('Apply'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchMarkets);
    _searchMarkets();
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchMarkets);
    _searchController.dispose();
    _filterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search EcoMarkets'),
        backgroundColor: Color(0xFF3E8E4D),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search EcoMarkets...',
                hintText: 'Type the market name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 8),
            _buildFilterPanel(),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var data =
                      _searchResults[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: Icon(Icons.shopping_bag, color: Colors.green),
                      title: Text(
                        data['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        data['description'] ?? 'No description available',
                      ),
                      onTap: () {},
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
