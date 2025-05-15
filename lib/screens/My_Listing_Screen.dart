import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String _selectedCategory = 'Tshirts';
  String? _imagePath;

  final List<String> _categories = ['Tshirts', 'Jeans', 'Shoes', 'Other'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Simulate image picking
    setState(() {
      _imagePath = 'assets/placeholder_product.png';
    });
  }

  void _submitProduct() {
    if (_formKey.currentState!.validate() && _imagePath != null) {
      final newProduct = {
        'name': _titleController.text,
        'description': _descriptionController.text,
        'image': _imagePath!,
        'url': _urlController.text,
        'category': _selectedCategory,
        'isPublished': true,
        'isSaved': false,
      };
      Navigator.pop(context, newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Listing'),
        actions: [
          TextButton(
            onPressed: _submitProduct,
            child: const Text('Publish', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      _imagePath == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                'Add Product Image',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _imagePath!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Title',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a title'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a description'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Product URL',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a URL'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Publish Listing',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset('assets/home.png', width: 24),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              IconButton(
                icon: Image.asset('assets/search.png', width: 24),
                onPressed: () {},
              ),
              const SizedBox(width: 40), // Space for FAB
              IconButton(
                icon: Image.asset('assets/heart.png', width: 24),
                onPressed: () {
                  Navigator.pushNamed(context, '/saved');
                },
              ),
              IconButton(
                icon: Image.asset('assets/profile.png', width: 24),
                onPressed: () {
                  Navigator.pushNamed(context, '/account');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyListingsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  const MyListingsScreen({super.key, required this.products});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  Widget build(BuildContext context) {
    final myProducts =
        widget.products.where((p) => p['isPublished'] == true).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body:
          myProducts.isEmpty
              ? const Center(child: Text('You have no published listings'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: myProducts.length,
                itemBuilder: (context, index) {
                  final product = myProducts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Switch(
                                value: product['isPublished'],
                                onChanged: (value) {
                                  setState(() {
                                    product['isPublished'] = value;
                                  });
                                },
                              ),
                              Text(
                                product['isPublished'] ? 'Published' : 'Paused',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              product['image'],
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(product['description']),
                          const SizedBox(height: 8),
                          Text(
                            'Category: ${product['category']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // TODO: Track Order
                            },
                            child: const Text('Track Order'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset('assets/home.png', width: 24),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              IconButton(
                icon: Image.asset('assets/search.png', width: 24),
                onPressed: () {},
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Image.asset('assets/heart.png', width: 24),
                onPressed: () {
                  Navigator.pushNamed(context, '/saved');
                },
              ),
              IconButton(
                icon: Image.asset('assets/profile_filled.png', width: 24),
                onPressed: () {
                  Navigator.pushNamed(context, '/account');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
