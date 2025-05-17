import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gadgetzilla/screens/My_Listing_Screen.dart';
import 'package:gadgetzilla/screens/Account_Screen.dart';
import 'package:gadgetzilla/screens/navbar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:gadgetzilla/screens/notification.dart';

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
        .where('publish', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            // Preserve old saved states if possible
            final oldSavedMap = {
              for (var p in _allProducts) p['id']: p['isSaved'] ?? false,
            };

            _allProducts =
                snapshot.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final id = doc.id;
                  return {
                    'id': id,
                    'name': data['name'] ?? '',
                    'description': data['description'] ?? '',
                    'category': data['category'] ?? 'Other',
                    'isSaved': oldSavedMap[id] ?? false,
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
    return _allProducts.where((product) => product['isSaved'] == true).toList();
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
    final imageUrl = product['imageUrl'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
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
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Center(child: Icon(Icons.image)),
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Category: $category',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const Divider(height: 30),
                    ListTile(
                      leading: const Icon(Icons.open_in_browser),
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
                      leading: const Icon(Icons.copy),
                      title: const Text('Copy URL'),
                      onTap: () {
                        if (url != null) {
                          Clipboard.setData(ClipboardData(text: url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('URL copied to clipboard'),
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('Share Product'),
                      onTap: () {
                        if (url != null) {
                          Share.share('Check this product: $url');
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex == 0) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Exit App?'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
      );
      return shouldExit ?? false;
    } else {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const NotificationScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
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
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildProductGrid(_filteredProducts)),
        ],
      ),
    );
  }

  Widget _buildSearchScreen() {
    return SafeArea(
      child: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildProductGrid(_filteredProducts)),
        ],
      ),
    );
  }

  Widget _buildSavedScreen() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saved Items',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(child: _buildProductGrid(_savedProducts)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search...',
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                  : const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _onCategorySelected(category),
              selectedColor: Colors.black,
              backgroundColor: Colors.grey.shade300,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> products) {
    if (products.isEmpty) {
      IconData icon;
      String title;
      String message;

      if (_currentIndex == 1 && _searchQuery.isNotEmpty) {
        // Search page empty state
        icon = Icons.search_off;
        title = 'No results found!';
        message = 'Try a similar word or something more general.';
      } else if (_currentIndex == 2) {
        // Saved items empty state
        icon = Icons.favorite_border;
        title = 'No saved item';
        message =
            "You don't have any saved items.\nGo to Discover and add some.";
      } else {
        // Home or default fallback
        icon = Icons.inventory_2_outlined;
        title = 'No products found';
        message = 'Try changing the filter or check back later.';
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 17),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        final id = product['id'] as String;
        final name = product['name'] as String? ?? '';
        final description = product['description'] as String? ?? '';
        final category = product['category'] as String? ?? '';
        final isSaved = product['isSaved'] as bool? ?? false;
        final imageUrl = product['imageUrl'] as String? ?? '';

        return GestureDetector(
          onTap: () => _showOptions(product),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child:
                      imageUrl.isNotEmpty
                          ? Image.network(
                            imageUrl,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    Container(color: Colors.grey[300]),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 140,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          )
                          : Container(
                            height: 140,
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.image)),
                          ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleSaved(id),
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
