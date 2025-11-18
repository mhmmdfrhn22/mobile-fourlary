import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'news_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  int selectedIndex = 0;
  List<String> categories = []; // List kategori yang diambil dari API
  List<Map<String, dynamic>> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNews(); // Memanggil fungsi untuk fetch data berita dari API
  }

  // Fungsi untuk mengambil data berita dan kategori dari API
  Future<void> fetchNews() async {
    try {
      final response = await http.get(Uri.parse('https://backend-fourlary-production.up.railway.app/api/posts'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Ambil kategori yang unik dari data
        final uniqueCategories = <String>[];
        for (var item in data) {
          if (item['kategori'] != null && !uniqueCategories.contains(item['kategori'])) {
            uniqueCategories.add(item['kategori']);
          }
        }

        setState(() {
          categories = ['All', ...uniqueCategories]; // Tambahkan "All" di depan daftar kategori
          newsList = data
              .where((item) => item['status']?.toLowerCase() == 'published')
              .map((item) {
                return {
                  'image': item['url_foto'] ?? 'https://res.cloudinary.com/dprywyfwm/image/upload/v1762822108/uploads/placeholder-berita.png',
                  'title': item['judul'],
                  'author': item['penulis'] ?? 'Unknown',
                  'date': item['created_at'] ?? 'No Date',
                  'category': item['kategori'] ?? 'Uncategorized',
                  'content': item['isi'] ?? '',
                };
              }).toList();
        });
      } else {
        throw Exception('Gagal mengambil data berita');
      }
    } catch (error) {
      print('Error fetching news: $error');
    }
  }

  // Fungsi untuk memformat tanggal
  String formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(date); // Format: 18 Nov 2025
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Berita Apa Yang Ingin\nAnda Baca? ✨',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              // 🔹 Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.search_normal, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari Sekarang',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.setting_4, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Categories (Menggunakan kategori yang diambil dari API)
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 News List
              Expanded(
                child: newsList.isEmpty
                    ? const Center(child: CircularProgressIndicator()) // Loading indicator
                    : ListView.builder(
                        itemCount: newsList.length,
                        itemBuilder: (context, index) {
                          final news = newsList[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NewsDetailPage(news: news),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    child: Image.network(
                                      news['image'],
                                      width: 110,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            news['category'],
                                            style: const TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            news['title'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                news['author'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '• ${formatDate(news['date'])}', // Memformat tanggal
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
