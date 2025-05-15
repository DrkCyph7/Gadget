import 'package:flutter/material.dart';
import 'package:gadgetzilla/screens/My_Listing_Screen.dart';
import 'package:gadgetzilla/screens/Account_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GadgetZilla',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Tshirts', 'Jeans', 'Shoes'];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Regular Fit Slogan',
      'image': 'assets/tshirt1.png',
      'category': 'Tshirts',
      'isSaved': false,
      'isPublished': true,
    },
    {
      'name': 'Regular Fit Polo',
      'image': 'assets/tshirt2.png',
      'category': 'Tshirts',
      'isSaved': false,
      'isPublished': true,
    },
    {
      'name': 'Regular Fit Black',
      'image': 'assets/tshirt3.png',
      'category': 'Tshirts',
      'isSaved': false,
      'isPublished': true,
    },
    {
      'name': 'Regular Fit V-Neck',
      'image': 'assets/tshirt4.png',
      'category': 'Tshirts',
      'isSaved': false,
      'isPublished': true,
    },
    {
      'name': 'Slim Fit Jeans',
      'image': 'assets/jeans1.png',
      'category': 'Jeans',
      'isSaved': false,
      'isPublished': true,
    },
    {
      'name': 'Running Shoes',
      'image': 'assets/shoes1.png',
      'category': 'Shoes',
      'isSaved': false,
      'isPublished': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          product['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<Map<String, dynamic>> get _savedProducts {
    return _products.where((product) => product['isSaved']).toList();
  }

  void _toggleSaved(int index) {
    setState(() {
      _products[index]['isSaved'] = !_products[index]['isSaved'];
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
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

  Widget _buildNavItem(IconData icon, IconData activeIcon, int index) {
    return IconButton(
      icon: Icon(
        _currentIndex == index ? activeIcon : icon,
        color: _currentIndex == index ? Colors.black : Colors.grey,
      ),
      onPressed: () => _onTabTapped(index),
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
                  : AppBar(title: const Text("Account"), centerTitle: true)),
      body: _buildCurrentScreen(),
      floatingActionButton:
          _currentIndex != 3
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MyListingsScreen(products: _products),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
                backgroundColor: Colors.black,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, 0),
              _buildNavItem(Icons.search_outlined, Icons.search, 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.favorite_border, Icons.favorite, 2),
              _buildNavItem(Icons.person_outline, Icons.person, 3),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Discover',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
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
        _buildCategoryChips(),
        _buildProductGrid(_filteredProducts),
      ],
    );
  }

  Widget _buildSearchScreen() {
    return Column(
      children: [
        _buildSearchBar(autofocus: true),
        _buildCategoryChips(),
        _buildProductGrid(_filteredProducts),
      ],
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
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search for clothes...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {},
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
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(product['image'], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    product['isSaved'] ? Icons.favorite : Icons.favorite_border,
                    color: product['isSaved'] ? Colors.red : Colors.black,
                  ),
                  onPressed:
                      () => _toggleSaved(
                        _products.indexWhere(
                          (p) => p['name'] == product['name'],
                        ),
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
