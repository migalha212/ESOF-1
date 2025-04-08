import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBusinessPage extends StatefulWidget {
  @override
  _AddBusinessPageState createState() => _AddBusinessPageState();
}

class BusinessService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> addBusiness(SustainableBusiness business) async {
    try {
      await _db.collection('businesses').add(business.toMap());
    } catch (e) {
      throw Exception('Erro ao adicionar negócio: $e');
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

  final Map<String, Map<String, dynamic>> _primaryCategories = {
    'Alimentos': {
      'emoji': '🍏',
      'subcategories': ['Orgânicos', 'Vegan', 'Biológicos'],
    },
    'Roupas': {
      'emoji': '👗',
      'subcategories': ['Reciclada', 'Eco-Friendly', 'Segunda Mão'],
    },
    'Itens Colecionáveis': {
      'emoji': '🎁',
      'subcategories': ['Vintage', 'Edição Limitada', 'Antiguidades'],
    },
    'Decoração': {
      'emoji': '🏡',
      'subcategories': ['Móveis', 'Iluminação', 'Arte'],
    },
    'Eletrónicos': {
      'emoji': '📱',
      'subcategories': ['Smartphones', 'Computadores', 'Acessórios'],
    },
    'Brinquedos': {
      'emoji': '🧸',
      'subcategories': ['Artesanais', 'Segunda Mão', 'Reciclados'],
    },
    'Saúde & Beleza': {
      'emoji': '💄',
      'subcategories': ['Cosméticos', 'Cuidados Pessoais', 'Fitness'],
    },
    'Artesanato': {
      'emoji': '🧵',
      'subcategories': ['Feito à mão', 'Reciclado', 'Regional'],
    },
    'Livros': {
      'emoji': '📚',
      'subcategories': ['Romance', 'Segunda Mão', 'Infantis'],
    },
    'Desportos & Lazer': {
      'emoji': '⚽',
      'subcategories': ['Ginasio', 'Ao ar livre', 'Indoor'],
    },
  };

  List<String> _selectedPrimaryCategories = [];
  Map<String, List<String>> _selectedSubcategories = {};

  Map<String, bool> _certifications = {
    'Certificado Orgânico': false,
    'Fair Trade Certified': false,
    'Green Business Award': false,
  };

  void _submitBusiness() async {
    if (_formKey.currentState!.validate() && _selectedPrimaryCategories.isNotEmpty) {
      List<String> primaries = List.from(_selectedPrimaryCategories);
      Map<String, dynamic> subs = {};
      _selectedSubcategories.forEach((k, v) => subs[k] = v);
      List<String> certs = [];
      _certifications.forEach((k, v) {
        if (v) certs.add(k);
      });
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
      );
      try {
        await _businessService.addBusiness(business);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Negócio adicionado com sucesso!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao adicionar negócio: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecione pelo menos uma categoria primária')));
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
              children: List<String>.from(data['subcategories']).map((sub) {
                bool subSelected = _selectedSubcategories[category]?.contains(sub) ?? false;
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
                child: Text('Desselecionar'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Negócio Sustentável'),
        backgroundColor: Color(0xFF3E8E4D),
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
                  labelText: 'Nome do Negócio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Por favor, insira o nome do negócio'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Por favor, insira uma descrição'
                    : null,
              ),
              SizedBox(height: 16),
              Text(
                'Categorias Primárias (Max. 3)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._primaryCategories.entries
                  .map((entry) => _buildPrimaryCategoryTile(entry.key, entry.value))
                  .toList(),
              SizedBox(height: 16),
              Text(
                'Certificações / Prêmios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                children: _certifications.keys.map((cert) {
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      (value == null || value.isEmpty) ? 'Insira a latitude' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      (value == null || value.isEmpty) ? 'Insira a longitude' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone de Contato',
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
                child: Text('Adicionar Negócio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3E8E4D),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SustainableBusiness {
  String id;
  String name;
  String description;
  double latitude;
  double longitude;
  List<String> primaryCategories;
  Map<String, dynamic> subcategories;
  String address;
  String contactPhone;
  String website;
  List<String> certifications;

  SustainableBusiness({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.primaryCategories,
    required this.subcategories,
    required this.address,
    required this.contactPhone,
    required this.website,
    required this.certifications,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'primaryCategories': primaryCategories,
      'subcategories': subcategories,
      'address': address,
      'contactPhone': contactPhone,
      'website': website,
      'certifications': certifications,
    };
  }
}
