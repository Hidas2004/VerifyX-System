import 'package:flutter/material.dart';

/// Trang tìm kiếm sản phẩm
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm sản phẩm'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thanh tìm kiếm
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm, thương hiệu...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00BCD4)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                _handleSearch(value);
              },
            ),
            const SizedBox(height: 24),
            
            // Gợi ý tìm kiếm phổ biến
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tìm kiếm phổ biến',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSearchChip('iPhone'),
                _buildSearchChip('Samsung'),
                _buildSearchChip('Nike'),
                _buildSearchChip('Adidas'),
                _buildSearchChip('Louis Vuitton'),
              ],
            ),
            const SizedBox(height: 24),
            
            // Thông báo
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nhập từ khóa để tìm kiếm',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
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

  Widget _buildSearchChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: const Color(0xFF00BCD4).withValues(alpha: 0.1),
      side: const BorderSide(color: Color(0xFF00BCD4)),
      onPressed: () {
        _handleSearch(label);
      },
    );
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tìm kiếm: $query')),
    );
    
    // TODO: Implement search functionality
  }
}
