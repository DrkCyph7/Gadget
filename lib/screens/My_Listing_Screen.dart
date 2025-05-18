import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_product_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _deleteProduct(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(docId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product deleted')));
    } catch (e) {
      debugPrint('Error deleting product: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete product')));
    }
  }

  Future<void> _togglePublish(String docId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(docId).update({
        'publish': !currentStatus,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update publish status')),
      );
    }
  }

  Future<void> _updateProduct(
    String docId,
    String name,
    String description,
    String url,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('items').doc(docId).update({
        'name': name,
        'description': description,
        'url': url,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update product')));
    }
  }

  void _confirmUpdate(
    String docId,
    String name,
    String description,
    String url,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Update'),
            content: const Text(
              'Are you sure you want to update this product?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateProduct(docId, name, description, url);
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('items')
                .where('ownerId', isEqualTo: user!.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no published listings'));
          }

          final products = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = products[index];
              final product = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return EditableProductTile(
                docId: docId,
                product: product,
                onDelete: () => _deleteProduct(docId),
                onTogglePublish:
                    (val) => _togglePublish(docId, product['publish'] ?? true),
                onSave:
                    (name, description, url) =>
                        _confirmUpdate(docId, name, description, url),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class EditableProductTile extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> product;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTogglePublish;
  final Function(String, String, String) onSave;

  const EditableProductTile({
    super.key,
    required this.docId,
    required this.product,
    required this.onDelete,
    required this.onTogglePublish,
    required this.onSave,
  });

  @override
  State<EditableProductTile> createState() => _EditableProductTileState();
}

class _EditableProductTileState extends State<EditableProductTile> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _urlController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _descriptionController = TextEditingController(
      text: widget.product['description'],
    );
    _urlController = TextEditingController(text: widget.product['url'] ?? '');

    _nameController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);
    _urlController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final hasChanged =
        _nameController.text != (widget.product['name'] ?? '') ||
        _descriptionController.text != (widget.product['description'] ?? '') ||
        _urlController.text != (widget.product['url'] ?? '');
    if (hasChanged != _hasChanges) {
      setState(() {
        _hasChanges = hasChanged;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.product['category'] ?? 'Uncategorized';
    final imageUrl = widget.product['imageUrl'] as String?;
    final isPublished = widget.product['publish'] ?? false;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child:
                imageUrl != null
                    ? Image.network(
                      imageUrl,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                    )
                    : Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Product URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Category: $category',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Switch(
                            value: isPublished,
                            onChanged: (val) => widget.onTogglePublish(val),
                            activeColor: Colors.green,
                          ),
                          Text(isPublished ? 'Published' : 'Paused'),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                  if (_hasChanges)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed:
                            () => widget.onSave(
                              _nameController.text.trim(),
                              _descriptionController.text.trim(),
                              _urlController.text.trim(),
                            ),
                        child: const Text('Save'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
