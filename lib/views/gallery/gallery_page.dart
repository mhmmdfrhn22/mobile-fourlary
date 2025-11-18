import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Untuk meng-decode response JSON
import 'gallery_detail.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Map<String, dynamic>> galleryPosts = [];
  bool isLoading = true;

  // URL API yang digunakan untuk mengambil data
  final String API_URL =
      'https://backend-fourlary-production.up.railway.app/api/foto';

  // Fungsi untuk mengambil data galeri dari API
  Future<void> fetchGallery() async {
    try {
      final response = await http.get(Uri.parse(API_URL));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          galleryPosts = data.map((item) {
            return {
              'id_foto': item['id_foto'], // Pastikan id_foto ada dan diteruskan
              'username': item['uploader'] ?? 'Admin',
              'profile':
                  'https://i.pravatar.cc/150?img=5', // Ganti dengan gambar profil sesungguhnya
              'image': item['url_foto'],
              'likes': item['like_count'] ?? 0,
              'comments': 0, // Sesuaikan jika API menyediakan jumlah komentar
              'isLiked': false,
              'caption': item['deskripsi'] ?? 'Tanpa Deskripsi',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load gallery');
      }
    } catch (e) {
      print('Error fetching gallery: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGallery(); // Memanggil API saat halaman pertama kali dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jelajahi Seluruh\nGaleri Fourlary 📸',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
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
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari galeri...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Feed posts
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: galleryPosts.map<Widget>((post) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔸 Header profil post
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      post['profile'],
                                    ),
                                    radius: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    post['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🔸 Gambar utama + Hero animation
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        GalleryDetailPage(post: post),
                                  ),
                                );
                              },
                              
                              child: Hero(
                                tag:
                                    'image-${post['image']}', // Memastikan tag unik
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.network(
                                    post['image'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),

                            // 🔸 Caption
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
                              child: Text(
                                post['caption'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            // 🔸 Like & Comment bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        post['isLiked'] = !post['isLiked'];
                                        post['likes'] += post['isLiked']
                                            ? 1
                                            : -1;
                                      });
                                    },
                                    icon: Icon(
                                      post['isLiked']
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: post['isLiked']
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                  // Hanya menggunakan icon tanpa jumlah like
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              GalleryDetailPage(post: post),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.comment,
                                      size: 22,
                                    ), // Menggunakan icon comment
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  
          ],
        ),
      ),
    );
  }
}
