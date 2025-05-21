import 'package:eco_finder/common_widgets/navbar_widget.dart';
import 'package:eco_finder/features/map/model/eco_market.dart';
import 'package:eco_finder/features/map/presentation/pages/map_page.dart';
import 'package:eco_finder/features/search/data/search_service.dart';
import 'package:eco_finder/features/search/presentation/widgets/filter_panel.dart';
import 'package:eco_finder/services/location_service.dart';
import 'package:eco_finder/utils/navigation_items.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchPage extends StatefulWidget {
  final double? hoveredLatitude;
  final double? hoveredLongitude;
  final double? zoomLevel;
  const SearchPage({
    super.key,
    this.hoveredLatitude,
    this.hoveredLongitude,
    this.zoomLevel,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _filterScrollController = ScrollController();

  LatLng? _hoveredLocation;
  double? _zoomLvl;
  List<EcoMarket> _searchResults = [];
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

  Future<void> _searchMarkets() async {
    SearchService searchService = SearchService();
    LatLng? referencePosition =
        _hoveredLocation ??
        await LocationService().getCurrentLocation() ??
        const LatLng(0, 0);
    var searchResults = await searchService.searchMarkets(
      query: _searchController.text,
      referencePosition: referencePosition,
      selectedCategories: _selectedFilterCategories,
      maxResults: _maxSearchResults,
    );
    setState(() {
      _searchResults = searchResults;
    });
  }

  @override
  void initState() {
    super.initState();
    _hoveredLocation = LatLng(
      widget.hoveredLatitude ?? 0.0,
      widget.hoveredLongitude ?? 0.0,
    );
    _zoomLvl = widget.zoomLevel ?? 18.0;

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
        foregroundColor: Colors.white,
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
                          _hoveredLocation,
                      initialZoom: _zoomLvl,
                    ),
              ),
            );
          },
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
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
            //_buildFilterPanel(),
            FilterPanel(
              categories: _filterCategories,
              selectedCategories: _selectedFilterCategories,
              onCategoryToggle: (category, isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedFilterCategories.remove(category);
                  } else {
                    _selectedFilterCategories.add(category);
                  }
                });
              },
              onApply: () {
                _searchMarkets();
                setState(() {
                  _isFilterExpanded = false;
                });
              },
              isExpanded: _isFilterExpanded,
              scrollController: _filterScrollController,
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var data = _searchResults[index];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: Icon(Icons.shopping_bag, color: Colors.green),
                      title: Text(
                        data.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        data.description ?? 'No description available',
                        maxLines: 4,
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
