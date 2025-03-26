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

  // Controladores para campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  // Lista de categorias selecionáveis
  final List<String> _allCategories = [
    'Organic',
    'Fair Trade',
    'Zero Waste',
    'Local Produce',
    'Renewable Energy',
    'Eco-Friendly Packaging',
    'Sustainable Fashion',
    'Green Restaurant',
    'Recycling',
  ];

  // Categorias selecionadas
  List<String> _selectedCategories = [];

  // Mapa de práticas de sustentabilidade
  Map<String, bool> _sustainabilityPractices = {
    'Solar Energy': false,
    'Composting': false,
    'Water Conservation': false,
    'Plastic-Free': false,
    'Local Sourcing': false,
    'Ethical Labor': false,
  };

  void _submitBusiness() async {
    if (_formKey.currentState!.validate()) {
      // Coletar práticas de sustentabilidade selecionadas
      Map<String, dynamic> sustainability = {};
      _sustainabilityPractices.forEach((key, value) {
        if (value) sustainability[key] = true;
      });

      SustainableBusiness business = SustainableBusiness(
        id: '', // Firestore gerará automaticamente
        name: _nameController.text,
        description: _descriptionController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        categories: _selectedCategories,
        address: _addressController.text,
        contactPhone: _phoneController.text,
        website: _websiteController.text,
        sustainability: sustainability,
      );

      try {
        await _businessService.addBusiness(business);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Negócio adicionado com sucesso!')),
        );
        Navigator.pop(context); // Voltar para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar negócio: $e')),
        );
      }
    }
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
              // Campos de texto para informações básicas
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Negócio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do negócio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Seleção de Categorias
              Text(
                'Categorias de Sustentabilidade',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: _allCategories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategories.contains(category),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              // Práticas de Sustentabilidade
              Text(
                'Práticas de Sustentabilidade',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                children: _sustainabilityPractices.keys.map((practice) {
                  return CheckboxListTile(
                    title: Text(practice),
                    value: _sustainabilityPractices[practice],
                    onChanged: (bool? value) {
                      setState(() {
                        _sustainabilityPractices[practice] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              // Campos de localização
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira a latitude';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira a longitude';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Campos de contato
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
  List<String> categories;
  String address;
  String contactPhone;
  String website;
  Map<String, dynamic> sustainability;

  SustainableBusiness({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.categories,
    required this.address,
    required this.contactPhone,
    required this.website,
    required this.sustainability,
  });

  // Converter para JSON antes de enviar para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'categories': categories,
      'address': address,
      'contactPhone': contactPhone,
      'website': website,
      'sustainability': sustainability,
    };
  }
}
