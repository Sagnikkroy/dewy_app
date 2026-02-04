import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_service.dart';
import '../config.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final SearchService _searchService = SearchService();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;

  final Map<int, int> _cartQuantities = {};
  final Set<int> _wishlistedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadUserSelections();
  }

  Future<void> _fetchData() async {
    final results = await _searchService.performHybridSearch(widget.query);
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserSelections() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('wishlist_cart')
          .select('product_id, quantity, is_wishlist')
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          for (var item in data) {
            int pid = item['product_id'];
            if (item['is_wishlist'] == true) {
              _wishlistedIds.add(pid);
            } else {
              _cartQuantities[pid] = item['quantity'];
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading selections: $e");
    }
  }

  Future<void> _updateCartBackend(int productId, int quantity) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    try {
      if (quantity > 0) {
        await supabase.from('wishlist_cart').upsert({
          'user_id': user.id,
          'product_id': productId,
          'quantity': quantity,
          'is_wishlist': false,
        }, onConflict: 'user_id, product_id, is_wishlist');
      } else {
        await supabase.from('wishlist_cart').delete().match({
          'user_id': user.id,
          'product_id': productId,
          'is_wishlist': false,
        });
      }
    } catch (e) {
      debugPrint("DB Error: $e");
    }
  }

  Future<void> _toggleWishlist(int productId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final isAdding = !_wishlistedIds.contains(productId);

    setState(() {
      if (isAdding) {
        _wishlistedIds.add(productId);
      } else {
        _wishlistedIds.remove(productId);
      }
    });

    try {
      if (isAdding) {
        await supabase.from('wishlist_cart').upsert({
          'user_id': user.id,
          'product_id': productId,
          'is_wishlist': true,
        }, onConflict: 'user_id, product_id, is_wishlist');
      } else {
        await supabase.from('wishlist_cart').delete().match({
          'user_id': user.id,
          'product_id': productId,
          'is_wishlist': true,
        });
      }
    } catch (e) {
      debugPrint("Wishlist Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search Results',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
            Text(widget.query,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _results.isEmpty
              ? _buildEmptyState()
              : _buildProductGrid(),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.52,
      ),
      itemBuilder: (context, index) =>
          _buildProductCard(_results[index]),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final int productId = product['id'];
    final String name = product['name'] ?? 'No Name';
    final String brandName = product['brand_name'] ?? 'DEWY';
    final int qty = _cartQuantities[productId] ?? 0;
    final bool isWishlisted = _wishlistedIds.contains(productId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              (product['image_paths'] as List).isNotEmpty
                  ? AppConfig.getProductImageUrl(
                      product['image_paths'][0])
                  : '',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[100],
                child:
                    const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brandName.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 8),
                  Text("₹${product['main_sale_price']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  const Spacer(),
                  qty == 0
                      ? _buildInitialActions(productId, isWishlisted)
                      : _buildQuantitySelector(productId, qty),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialActions(int productId, bool isWishlisted) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _toggleWishlist(productId),
          child: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isWishlisted
                  ? Icons.favorite
                  : Icons.favorite_border,
              size: 18,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _cartQuantities[productId] = 1);
              _updateCartBackend(productId, 1);
            },
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8)),
              child: const Center(
                child: Text('Add to Bag',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(int productId, int qty) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () {
              setState(() =>
                  _cartQuantities[productId] = qty - 1);
              _updateCartBackend(productId, qty - 1);
            },
          ),
          Text('$qty',
              style:
                  const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () {
              setState(() =>
                  _cartQuantities[productId] = qty + 1);
              _updateCartBackend(productId, qty + 1);
            },
          ),
        ],
      ),
    );
  }

  // ---------------- SHIMMER ONLY CHANGE ----------------

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.52,
      ),
      itemBuilder: (_, __) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, width: 60, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 120, color: Colors.white),
                    const SizedBox(height: 10),
                    Container(height: 14, width: 80, color: Colors.white),
                    const Spacer(),
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() =>
      const Center(child: Text("No products found"));
}
