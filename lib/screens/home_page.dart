import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final Color topBarBottomColor = const Color(0xFFD2B48C); // flat brown
  final Color topBarTopColor = const Color(0xFF78563C); // darker brown

  @override
  void initState() {
    super.initState();

    // Transparent status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double getTopBarOpacity() {
    return (1 - (_scrollOffset / 120)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final List<String> categories = [
      'All',
      'Skincare',
      'Haircare',
      'Supplements',
      'Beauty',
    ];

    final List<Map<String, String>> products = List.generate(
      10,
      (index) => {
        'name': 'Product ${index + 1}',
        'image': 'https://via.placeholder.com/150',
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Dewy top bar under transparent status bar
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, statusBarHeight + 16, 16, 8),
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
                  Text(
                    'Dewy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications_none, color: Colors.black),
                      SizedBox(width: 16),
                      Icon(Icons.favorite_border, color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Sticky search bar + categories with white drop shadow
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              categories: categories,
              scrollOffset: _scrollOffset,
            ),
          ),

          // Featured product hero section
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.brown[100],
              ),
              child: const Center(
                child: Text(
                  'Featured Product',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Product grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                product['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: const [
                                  Text(
                                    '₹499',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '₹599',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '16% off',
                                    style: TextStyle(fontSize: 11, color: Colors.green),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.favorite_border,
                                        color: Colors.red, size: 18),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(50, 28),
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Add',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: products.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sticky search bar + horizontal categories with white drop shadow
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final double scrollOffset;

  _SearchBarDelegate({required this.categories, required this.scrollOffset});

  @override
  double get minExtent {
    final statusBarHeight = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).padding.top;
    return 105 + statusBarHeight;
  }
  
  @override
  double get maxExtent {
    final statusBarHeight = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).padding.top;
    return 125 + statusBarHeight;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double opacity = (scrollOffset / 120).clamp(0, 1);
    Color bgColor = Color.lerp(const Color(0xFFD2B48C), Colors.white, opacity)!;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Add status bar padding only when the header is being pinned (shrinkOffset approaches maxExtent - minExtent)
    final double scrollProgress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final double topPadding = 8 + (statusBarHeight * scrollProgress);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          // White drop shadow to make content beneath fade out
          BoxShadow(
            color: Colors.white.withOpacity(1.0),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16, bottom: 8),
      child: Column(
        children: [
          // Search bar
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Search products',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Horizontal categories
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) => true;
}
