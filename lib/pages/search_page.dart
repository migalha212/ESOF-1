import 'package:eco_finder/common_widgets/navbar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/map/presentation/pages/map_page.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:string_similarity/string_similarity.dart';
import 'dart:math';
import 'package:location/location.dart';

class SearchPage extends StatefulWidget {
  final double? hoveredLatitude;
  final double? hoveredLongitude;

  const SearchPage({super.key, this.hoveredLatitude, this.hoveredLongitude});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _filterScrollController = ScrollController();

  double? _userLat;
  double? _userLng;

  double? _hoveredLat;
  double? _hoveredLng;
  List<DocumentSnapshot> _searchResults = [];
  bool _isFilterExpanded = false;
  static const int _maxSearchResults = 10;
  final int _index = 0;
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

  Future<void> _getUserLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      _userLat = locationData.latitude;
      _userLng = locationData.longitude;
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // km
    final dLat = (lat2 - lat1) * (3.141592653589793 / 180);
    final dLon = (lon2 - lon1) * (3.141592653589793 / 180);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * (3.141592653589793 / 180)) *
            cos(lat2 * (3.141592653589793 / 180)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double getSimilarityThreshold(String query) {
    int len = query.length;

    if (len <= 1) return 0.05; // Accept anything for ultra-short input
    if (len <= 2) return 0.1;
    if (len <= 4) return 0.15;
    if (len <= 6) return 0.25;

    return (0.3 + (len - 6) * 0.05).clamp(
      0.0,
      0.6,
    ); // cap at 0.6 for broader reach
  }

  Future<void> _searchMarkets() async {
    String query = _searchController.text.toLowerCase().trim();
    QuerySnapshot querySnapshot;

    querySnapshot =
        await FirebaseFirestore.instance
            .collection('businesses')
            .get(); // Wide search

    final threshold = getSimilarityThreshold(query);

    List<DocumentSnapshot> docs =
        querySnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name_lowercase'] ?? '';

          if (query.isNotEmpty) {
            final similarity = StringSimilarity.compareTwoStrings(query, name);

            if (!name.contains(query) && similarity < threshold) {
              return false;
            }
          }

          if (_selectedFilterCategories.isNotEmpty) {
            final List<dynamic>? docCats = data['primaryCategories'];
            if (docCats == null ||
                !_selectedFilterCategories.any(
                  (cat) => docCats.contains(cat),
                )) {
              return false;
            }
          }

          return true;
        }).toList();

    // Sort by similarity if there's a query, else by popularity
    if (query.isNotEmpty) {
      docs.sort((a, b) {
        final aName = (a.data() as Map<String, dynamic>)['name_lowercase'];
        final bName = (b.data() as Map<String, dynamic>)['name_lowercase'];
        final aSim = StringSimilarity.compareTwoStrings(query, aName);
        final bSim = StringSimilarity.compareTwoStrings(query, bName);
        return bSim.compareTo(aSim);
      });
    } else {
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        // Use hovered location if available, otherwise fallback to user location
        double referenceLat = _hoveredLat ?? _userLat ?? 0.0;
        double referenceLng = _hoveredLng ?? _userLng ?? 0.0;

        final aDist = _calculateDistance(
          referenceLat,
          referenceLng,
          aData['latitude'],
          aData['longitude'],
        );
        final bDist = _calculateDistance(
          referenceLat,
          referenceLng,
          bData['latitude'],
          bData['longitude'],
        );

        return aDist.compareTo(bDist);
      });
    }

    setState(() {
      _searchResults = docs.take(_maxSearchResults).toList();
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
    _getUserLocation();
    _hoveredLat = widget.hoveredLatitude;
    _hoveredLng = widget.hoveredLongitude;
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
      bottomNavigationBar: NavBar(selectedIndex: _index),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Search EcoMarkets'),
        backgroundColor: Color(0xFF3E8E4D),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MapPage(
                      initialPosition:
                          widget.hoveredLatitude != null &&
                                  widget.hoveredLongitude != null
                              ? LatLng(
                                widget.hoveredLatitude!,
                                widget.hoveredLongitude!,
                              )
                              : null,
                    ),
              ),
            );
          },
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
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
        padding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
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
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          NavigationItems.navSearchProfile.route,
                          arguments: _searchResults[index].reference,
                        );
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
