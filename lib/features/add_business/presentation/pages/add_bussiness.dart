import 'package:eco_finder/features/add_business/model/full_business.dart';
import 'package:eco_finder/features/authentication/presentation/widgets/login_prompt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eco_finder/features/add_business/presentation/widgets/location_picker_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_finder/features/notifications/data/notifications_service.dart';

class AddBusinessPage extends StatefulWidget {
  const AddBusinessPage({super.key});

  @override
  State<StatefulWidget> createState() => _AddBusinessPageState();
}

class BusinessService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  Future<void> addBusiness(SustainableBusiness business) async {
    try {
      final DocumentReference businessRef =
      await _db.collection('businesses').add(business.toMap());
      await _notificationService.createStoreOpeningNotification(
          await _db.collection('businesses').doc(businessRef.id).get());
    } catch (e) {
      throw Exception('Error adding business: $e');
    }
  }
}

class _AddBusinessPageState extends State<AddBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final BusinessService _businessService = BusinessService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final Map<String, Map<String, dynamic>> _primaryCategories = {
    'Food': {
      'emoji': '🍏',
      'subcategories': ['Organic', 'Vegan', 'Biological'],
    },
    'Clothes': {
      'emoji': '👗',
      'subcategories': ['Recycled', 'Eco-Friendly', 'Second-Hand'],
    },
    'Collectibles': {
      'emoji': '🎁',
      'subcategories': ['Vintage', 'Limited edition', 'Antiques'],
    },
    'Decoration': {
      'emoji': '🏡',
      'subcategories': ['Furniture', 'Lighting', 'Art'],
    },
    'Eletronics': {
      'emoji': '📱',
      'subcategories': ['Smartphones', 'Computers', 'Accessories'],
    },
    'Toys': {
      'emoji': '🧸',
      'subcategories': ['Artisan', 'Second-Hand', 'Recycled'],
    },
    'Beauty and Hygiene': {
      'emoji': '💄',
      'subcategories': ['Cosmetics', 'Personal care', 'Fitness'],
    },
    'Artisanship': {
      'emoji': '🧵',
      'subcategories': ['Handmade', 'Reciycled', 'Regional'],
    },
    'Books': {
      'emoji': '📚',
      'subcategories': ['Romance', 'Second-Hand', "Children's"],
    },
    'Sports and Leisure': {
      'emoji': '⚽',
      'subcategories': ['Gym', 'Outdoors', 'Indoor'],
    },
  };

  final List<String> _selectedPrimaryCategories = [];
  final Map<String, List<String>> _selectedSubcategories = {};

  final Map<String, bool> _certifications = {
    'Organic Certificate': false,
    'Fair Trade Certified': false,
    'Green Business Award': false,
  };

  void _submitBusiness() async {
    if (_formKey.currentState!.validate() &&
        _selectedPrimaryCategories.isNotEmpty) {
      List<String> primaries = List.from(_selectedPrimaryCategories);
      Map<String, dynamic> subs = {};
      _selectedSubcategories.forEach((k, v) => subs[k] = v);
      List<String> certs = [];
      _certifications.forEach((k, v) {
        if (v) certs.add(k);
      });

      if (FirebaseAuth.instance.currentUser == null) {
        LoginPromptDialog.show(context);
        return;
      }
      SustainableBusiness business = SustainableBusiness(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        primaryCategories: primaries,
        subcategories: subs,
        address: _addressController.text,
        contactPhone: _phoneController.text,
        website: _websiteController.text,
        certifications: certs,
        imageUrl: _imageUrlController.text,
        uid: FirebaseAuth.instance.currentUser!.uid,
      );
      try {
        await _businessService.addBusiness(business);
        final user = FirebaseFirestore.instance.
          collection('profiles').
          doc(FirebaseAuth.instance.currentUser!.uid);
        await user.set({'business_owner': true}, SetOptions(merge: true));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Business added successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding Business: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select at least one primary category')),
      );
    }
  }

  Widget _buildPrimaryCategoryTile(String category, Map<String, dynamic> data) {
    bool selected = _selectedPrimaryCategories.contains(category);
    return Card(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: ExpansionTile(
          key: PageStorageKey(category),
          initiallyExpanded: selected,
          title: Row(
            children: [
              Text('${data['emoji']} $category'),
              Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedPrimaryCategories.remove(category);
                      _selectedSubcategories.remove(category);
                    } else {
                      if (_selectedPrimaryCategories.length < 3) {
                        _selectedPrimaryCategories.add(category);
                        _selectedSubcategories[category] = [];
                      }
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank,
                    color: selected ? Colors.green : null,
                  ),
                ),
              ),
            ],
          ),
          onExpansionChanged: (expanded) {
            if (expanded && !selected) {
              if (_selectedPrimaryCategories.length < 2) {
                setState(() {
                  _selectedPrimaryCategories.add(category);
                  _selectedSubcategories[category] = [];
                });
              }
            }
          },
          children: [
            Wrap(
              spacing: 8,
              children:
                  List<String>.from(data['subcategories']).map((sub) {
                    bool subSelected =
                        _selectedSubcategories[category]?.contains(sub) ??
                        false;
                    return ChoiceChip(
                      label: Text(sub),
                      selected: subSelected,
                      onSelected: (bool sel) {
                        setState(() {
                          if (sel) {
                            if (_selectedSubcategories[category] == null) {
                              _selectedSubcategories[category] = [sub];
                            } else {
                              _selectedSubcategories[category]!.add(sub);
                            }
                          } else {
                            _selectedSubcategories[category]?.remove(sub);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPrimaryCategories.remove(category);
                    _selectedSubcategories.remove(category);
                  });
                },
                child: Text('Desselect'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para visualizar a imagem do URL
  Widget _buildImagePreview() {
    if (_imageUrlController.text.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image preview:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              _imageUrlController.text,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'Error loading image',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3E8E4D),
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Eco-Business'),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF3E8E4D),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please, enter a name'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please, enter a description'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Business Image URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image, color: Color(0xFF3E8E4D)),
                  hintText: 'https://example.com/image.jpg',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _imageUrlController.clear();
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  // Atualiza a pré-visualização quando o URL muda
                  setState(() {});
                },
              ),
              SizedBox(height: 8),
              _buildImagePreview(),
              SizedBox(height: 16),
              Text(
                'Primary Categories (Max. 3)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._primaryCategories.entries.map(
                (entry) => _buildPrimaryCategoryTile(entry.key, entry.value),
              ),
              SizedBox(height: 16),
              Text(
                'Certificates / Awards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                children:
                    _certifications.keys.map((cert) {
                      return CheckboxListTile(
                        title: Text(cert),
                        value: _certifications[cert],
                        onChanged: (bool? value) {
                          setState(() {
                            _certifications[cert] = value!;
                          });
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 16),
              LocationPicker(
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
                addressController: _addressController,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitBusiness,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3E8E4D),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 8,
                ),
                child: Text(
                  'Add business',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
