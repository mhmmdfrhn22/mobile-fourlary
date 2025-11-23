import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'pembinat_detail.dart';

class PembinatPage extends StatefulWidget {
  const PembinatPage({super.key});

  @override
  _PembinatPageState createState() => _PembinatPageState();
}

class _PembinatPageState extends State<PembinatPage> {
  int selectedIndex = 0;
  List<String> categories = []; // List kategori yang diambil dari API
  List<Map<String, dynamic>> pembinatList = [];
  String searchTerm = '';
  String jurusanFilter = 'Semua';
  bool isLoading = true;

  final String API_URL =
      'https://backend-fourlary-production.up.railway.app/api/pembinat';

  @override
  void initState() {
    super.initState();
    fetchPembinatData(); // Fetch Pembinat data
  }

  Future<void> fetchPembinatData() async {
    try {
      final response = await http.get(Uri.parse(API_URL));
      if (response.statusCode == 200) {
        final List<dynamic> result = json.decode(response.body);
        setState(() {
          pembinatList = result.map((item) {
            return {
              'id_pekerjaan': item['id_pekerjaan'],
              'nama_pekerjaan': item['nama_pekerjaan'],
              'deskripsi': item['deskripsi'],
              'gambar_pekerjaan': item['gambar_pekerjaan'],
              'nama_jurusan': item['nama_jurusan'],
            };
          }).toList();
          categories = [
            'All',
            ...result.map((item) => item['nama_jurusan']).toSet().toList(),
          ];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load pembinat data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  List<Map<String, dynamic>> get filteredData {
    return pembinatList.where((item) {
      final searchMatch =
          item['nama_pekerjaan'].toLowerCase().contains(
            searchTerm.toLowerCase(),
          ) ||
          item['deskripsi'].toLowerCase().contains(searchTerm.toLowerCase());
      final jurusanMatch =
          jurusanFilter == 'Semua' || item['nama_jurusan'] == jurusanFilter;
      return searchMatch && jurusanMatch;
    }).toList();
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
                'Cari Minat & Bakatmu\nDengan Pembinat 💼',
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

              // 🔹 Categories (Category filter)
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          jurusanFilter = categories[index];
                        });
                      },
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

              // 🔹 Pembinat List (Display Pembinat data)
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final item = filteredData[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PembinatDetailPage(post: item),
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
                                      item['gambar_pekerjaan'],
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nama_jurusan'],
                                            style: const TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['nama_pekerjaan'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Shortened description
                                          Text(
                                            item['deskripsi'].length > 50
                                                ? item['deskripsi'].substring(
                                                        0,
                                                        50,
                                                      ) +
                                                      '...'
                                                : item['deskripsi'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
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
