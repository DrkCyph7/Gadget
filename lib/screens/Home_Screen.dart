import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gadgetzilla/screens/My_Listing_Screen.dart';
import 'package:gadgetzilla/screens/Account_Screen.dart';
import 'package:gadgetzilla/screens/navbar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showFilter = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  StreamSubscription<QuerySnapshot>? _productSubscription;

  final List<String> _categories = [
    'All',
    'Smart Tech',
    'Mobile Accessories',
    'Productivity Gadgets',
    'Desk Essential',
    'Kitchen & Life Hacks',
    'Travel Outdoors',
    'Trending & Viral',
  ];

  List<Map<String, dynamic>> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _listenToProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _productSubscription?.cancel();
    super.dispose();
  }

  void _listenToProducts() {
    _productSubscription = FirebaseFirestore.instance
        .collection('items')
        .snapshots()
        .listen((snapshot) {
          setState(() {
            _allProducts =
                snapshot.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'id': doc.id,
                    'name': data['name'] ?? '',
                    'description': data['description'] ?? '',
                    'category': data['category'] ?? 'Other',
                    'isSaved':
                        _allProducts.firstWhere(
                          (p) => p['id'] == doc.id,
                          orElse: () => {'isSaved': false},
                        )['isSaved'],
                    'imageUrl': data['imageUrl'] ?? '',
                    'url': data['url'] ?? '',
                  };
                }).toList();
          });
        });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' ||
          product['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Map<String, dynamic>> get _savedProducts {
    return _allProducts.where((product) => product['isSaved']).toList();
  }

  void _toggleSaved(String productId) {
    setState(() {
      final index = _allProducts.indexWhere((p) => p['id'] == productId);
      if (index != -1) {
        _allProducts[index]['isSaved'] = !_allProducts[index]['isSaved'];
      }
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showOptions(Map<String, dynamic> product) async {
    final url = product['url'] as String?;
    final name = product['name'] ?? 'Unnamed';
    final description = product['description'] ?? 'No description';
    final category = product['category'] ?? 'Uncategorized';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                'Category: $category',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const Divider(height: 30),
              ListTile(
                leading: const Icon(Icons.open_in_browser, color: Colors.black),
                title: const Text('Open Product'),
                onTap: () async {
                  Navigator.pop(context);
                  if (url != null && await canLaunchUrlString(url)) {
                    await launchUrlString(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to open URL')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.black),
                title: const Text('Copy URL'),
                onTap: () {
                  if (url != null) {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL copied to clipboard')),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.black),
                title: const Text('Share Product'),
                onTap: () {
                  if (url != null) {
                    Share.share('Check this product: $url');
                  }
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _currentIndex == 0
              ? _buildHomeAppBar()
              : (_currentIndex == 1 || _currentIndex == 2
                  ? null
                  : AppBar(
                    title: const Text("Account"),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    foregroundColor: Colors.black,
                  )),
      body: _buildCurrentScreen(),
      floatingActionButton:
          _currentIndex != 3
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyListingsScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.black,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabTapped,
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Discover',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return _buildSearchScreen();
      case 2:
        return _buildSavedScreen();
      case 3:
        return const AccountScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        _buildSearchBar(),
        if (_showFilter) _buildCategoryChips(),
        _buildProductGrid(_filteredProducts),
      ],
    );
  }

  Widget _buildSearchScreen() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildSearchBar(autofocus: true),
            if (_showFilter) _buildCategoryChips(),
            Expanded(
              child:
                  _filteredProducts.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 100,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No results found',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )
                      : _buildProductGrid(_filteredProducts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedScreen() {
    return _buildProductGrid(_savedProducts, emptyMessage: 'No Saved Items!');
  }

  Widget _buildSearchBar({bool autofocus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: autofocus,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search items...',
                  border: InputBorder.none,
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                          : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: _showFilter ? Colors.black : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: _showFilter ? Colors.white : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _showFilter = !_showFilter;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => _onCategorySelected(category),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(
    List<Map<String, dynamic>> products, {
    String emptyMessage = 'No products found',
  }) {
    if (products.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 100, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(emptyMessage, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () => _showOptions(product),
                child: ProductTile(
                  product: product,
                  onToggleSaved: () => _toggleSaved(product['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onToggleSaved;

  const ProductTile({
    super.key,
    required this.product,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? 'Unnamed';
    final description = product['description'] ?? '';
    final category = product['category'] ?? 'Uncategorized';
    final imageUrl = product['imageUrl'] as String?;
    final isSaved = product['isSaved'] == true;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                          imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                        )
                        : Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? Colors.red : Colors.black,
                  ),
                  onPressed: onToggleSaved,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: $category',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
