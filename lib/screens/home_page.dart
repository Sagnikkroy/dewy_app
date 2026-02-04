import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search_results.dart';
import 'product_info_page.dart'; // Ensure you create this file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  double _scrollOffset = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearchActive = false;

  final Map<String, int> _cartQuantities = {};

  final Color topBarBottomColor = const Color(0xFFD2B48C);
  final Color topBarTopColor = const Color(0xFF78563C);

  final List<Map<String, String>> _allProducts = [
    {'name': 'Glow Vitamin C Serum with Hyaluronic Acid', 'category': 'Skincare', 'price': '₹899', 'oldPrice': '₹1,200'},
    {'name': 'Argan Oil Deep Conditioner', 'category': 'Haircare', 'price': '₹549', 'oldPrice': '₹650'},
    {'name': 'Zinc Skin Immunity Tablets', 'category': 'Supplements', 'price': '₹399', 'oldPrice': '₹499'},
    {'name': 'Velvet Matte Lip Tint Longwear', 'category': 'Beauty', 'price': '₹450', 'oldPrice': '₹550'},
    {'name': 'Gentle Foaming Cleanser', 'category': 'Skincare', 'price': '₹599', 'oldPrice': '₹799'},
    {'name': 'Biotin Hair Gummies', 'category': 'Supplements', 'price': '₹999', 'oldPrice': '₹1,299'},
  ];

  final List<String> _suggestions = ['Vitamin C Serum', 'Sunscreen SPF 50', 'Hyaluronic Acid', 'Face Wash', 'Retinol'];

  List<Map<String, String>> get _displayProducts {
    if (_selectedCategory == 'All') return _allProducts;
    return _allProducts.where((p) => p['category'] == _selectedCategory).toList();
  }

  List<String> get _filteredSuggestions => _suggestions
      .where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (mounted) setState(() => _isSearchActive = _searchFocusNode.hasFocus);
    });
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  void _navigateToResults(String query) {
    if (query.trim().isEmpty) return;
    _searchFocusNode.unfocus();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchResultsPage(query: query)));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (!_isSearchActive)
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [topBarTopColor, topBarBottomColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('DEWY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                    Row(
                      children: [
                        Icon(Icons.notifications_none, color: Colors.white),
                        SizedBox(width: 16),
                        Icon(Icons.favorite_border, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              scrollOffset: _scrollOffset,
              selectedCategory: _selectedCategory,
              isSearchActive: _isSearchActive,
              focusNode: _searchFocusNode,
              searchController: _searchController,
              onCategoryTap: (cat) => setState(() => _selectedCategory = cat),
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onSearchSubmitted: _navigateToResults,
              onCancelSearch: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
                setState(() {
                  _searchQuery = '';
                  _isSearchActive = false;
                });
              },
            ),
          ),

          if (!_isSearchActive)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  /// FEATURED PRODUCT
                  Container(
                    height: 400,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFFF5E6D3),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 60),
                    ),
                  ),

                  /// OFFER STRIP CARD
                  Container(
                    height: 90,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                    ),
                    child: const Center(
                      child: Text(
                        'Special Offer • Flat 30% Off',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  /// SPOTLIGHT SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spotlight',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: List.generate(4, (brandIndex) {
                            return Column(
                              children: [
                                // Brand Thumbnail with Explore text
                                Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: const Color(0xFFF5E6D3),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.image, color: Colors.grey, size: 50),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 12,
                                      child: Row(
                                        children: const [
                                          Text(
                                            'Explore',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(Icons.arrow_forward, size: 16, color: Colors.black87),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // 3 Square Cards Below Thumbnail
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(3, (cardIndex) {
                                    return Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: cardIndex < 2 ? 8 : 0,
                                        ),
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: const Color(0xFFF5E6D3),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.image, color: Colors.grey, size: 40),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }),
                        ),

                        /// EXPLORE BRANDS SECTION
                        const SizedBox(height: 8),
                        const Text(
                          'Explore Brands',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 150,
                                margin: EdgeInsets.only(right: index < 5 ? 12 : 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFFF5E6D3),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image, color: Colors.grey, size: 50),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        /// CURATED TITLE
                        const Text(
                          'Curated for You',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          /// EXISTING PRODUCT GRID (UNCHANGED)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _isSearchActive
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final term = _filteredSuggestions[index];
                        return ListTile(
                          leading: const Icon(Icons.search, size: 20),
                          title: Text(term),
                          trailing: IconButton(
                            icon: const Icon(Icons.north_west, size: 18),
                            onPressed: () {
                              _searchController.text = term;
                              _searchController.selection =
                                  TextSelection.fromPosition(TextPosition(offset: term.length));
                              setState(() => _searchQuery = term);
                              _searchFocusNode.requestFocus();
                            },
                          ),
                          onTap: () => _navigateToResults(term),
                        );
                      },
                      childCount: _filteredSuggestions.length,
                    ),
                  )
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildProductCard(_displayProducts[index]),
                      childCount: _displayProducts.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.63,
                    ),
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    String name = product['name']!;
    int qty = _cartQuantities[name] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductInfoPage(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey, size: 40),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.favorite_border, size: 18, color: topBarTopColor),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(product['price']!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(
                    product['oldPrice']!,
                    style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  qty == 0
                      ? GestureDetector(
                          onTap: () => setState(() => _cartQuantities[name] = 1),
                          child: Container(
                            height: 34,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                            child: const Center(
                              child: Text(
                                'Add',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 34,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () => setState(() {
                                  if (qty > 0) _cartQuantities[name] = qty - 1;
                                }),
                              ),
                              Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => setState(() => _cartQuantities[name] = qty + 1),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final double scrollOffset;
  final String selectedCategory;
  final bool isSearchActive;
  final FocusNode focusNode;
  final TextEditingController searchController;
  final Function(String) onCategoryTap;
  final Function(String) onSearchChanged;
  final Function(String) onSearchSubmitted;
  final VoidCallback onCancelSearch;

  _SearchBarDelegate({
    required this.scrollOffset,
    required this.selectedCategory,
    required this.isSearchActive,
    required this.focusNode,
    required this.searchController,
    required this.onCategoryTap,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onCancelSearch,
  });

  @override
  double get minExtent {
    final statusBarHeight =
        MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).padding.top;
    return (isSearchActive ? 60 : 95) + statusBarHeight;
  }

  @override
  double get maxExtent => minExtent + 2;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    double opacity = (scrollOffset / 80).clamp(0, 1);
    Color bgColor = Color.lerp(const Color(0xFFD2B48C), Colors.white, opacity)!;
    final double topPadding =
        isSearchActive ? statusBarHeight + 4 : 4 + (statusBarHeight * (shrinkOffset / 20).clamp(0, 1));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [bgColor, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: searchController,
                    focusNode: focusNode,
                    onChanged: onSearchChanged,
                    onSubmitted: onSearchSubmitted,
                    onTap: () => focusNode.requestFocus(),
                    cursorColor: Colors.black,
                    showCursor: true,
                    decoration: const InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
              ),
              if (isSearchActive)
                TextButton(
                  onPressed: onCancelSearch,
                  child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (!isSearchActive) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['All', 'Skincare', 'Haircare', 'Supplements', 'Makeup'].map((cat) {
                  bool isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => onCategoryTap(cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(cat,
                            style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) => true;
}