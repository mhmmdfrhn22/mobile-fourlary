import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import 'gallery_detail.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Map<String, dynamic>> galleryPosts = [];
  bool isLoading = true;
  int? userId; // User ID for validating likes

  // URL API yang digunakan untuk mengambil data
  final String API_URL =
      'https://backend-fourlary-production.up.railway.app/api/foto';

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data (userId) from SharedPreferences
    fetchGallery(); // Fetch gallery data when the page loads
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId'); // Get the user ID from shared preferences
    });
  }

  // Function to fetch gallery data
  Future<void> fetchGallery() async {
    try {
      final response = await http.get(Uri.parse(API_URL));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Loop through each post and check if the user already liked the photo
        for (var post in data) {
          final likedResponse = await http.get(
            Uri.parse(
              'https://backend-fourlary-production.up.railway.app/api/like-foto/${post['id_foto']}/$userId',
            ),
          );
          final likedData = json.decode(likedResponse.body);

          // Update each post with the 'isLiked' status
          post['isLiked'] =
              likedData['liked'] ?? false; // Set isLiked based on the response
          print("Post ID: ${post['id_foto']}, Liked: ${post['isLiked']}");
        }

        setState(() {
          galleryPosts = data.map((item) {
            return {
              'id_foto': item['id_foto'],
              'username': item['uploader'] ?? 'Admin',
              'profile': 'https://i.pravatar.cc/150?img=5',
              'image': item['url_foto'],
              'likes': item['like_count'] ?? 0,
              'comments': item['comments_count'] ?? 0,
              'isLiked': item['isLiked'] ?? false, // Ensure isLiked is correctly set
              'caption': item['deskripsi'] ?? 'No Description',
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

  // Function to handle liking a post
  Future<void> _toggleLike(Map<String, dynamic> post) async {
    if (userId == null) {
      // User is not logged in, show an alert
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like posts.')),
      );
      return;
    }

    print("User ID: $userId");
    print("Post ID: ${post['id_foto']}");

    try {
      // 1. Optimistically update UI immediately when a user presses the like button
      setState(() {
        post['isLiked'] = !post['isLiked']; // Toggle the like status
        post['likes'] = post['isLiked']
            ? post['likes'] + 1
            : post['likes'] - 1; // Increment or decrement likes
      });

      // 2. Make the API call to add or remove the like in the backend
      final checkLikeResponse = await http.get(
        Uri.parse(
          'https://backend-fourlary-production.up.railway.app/api/like-foto/${post['id_foto']}/$userId',
        ),
      );

      if (checkLikeResponse.statusCode == 200) {
        final likeStatus = json.decode(checkLikeResponse.body);
        print("Like check response: $likeStatus");

        if (!likeStatus['liked']) {
          await _addLike(post); // Add like if not liked
        } else {
          await _removeLike(post); // Remove like if already liked
        }
      } else {
        print("Error checking like status: ${checkLikeResponse.statusCode}");
        throw Exception('Error checking like status');
      }
    } catch (e) {
      print("Error during like validation: $e");
      // Rollback UI change if error occurs (optional)
      setState(() {
        post['isLiked'] = !post['isLiked']; // Revert like status
        post['likes'] = post['isLiked']
            ? post['likes'] + 1
            : post['likes'] - 1; // Revert likes count
      });
    }
  }

  // Function to add a like to a photo
  Future<void> _addLike(Map<String, dynamic> post) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://backend-fourlary-production.up.railway.app/api/like-foto/',
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id_foto": post['id_foto'], "id_user": userId}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Add Like Response: $data");
      } else {
        print("Error adding like: ${response.statusCode}");
        throw Exception('Error adding like');
      }
    } catch (e) {
      print("Error adding like: $e");
    }
  }

  // Function to remove a like from a photo (using DELETE instead of POST)
  Future<void> _removeLike(Map<String, dynamic> post) async {
    try {
      final response = await http.delete(
        Uri.parse(
          'https://backend-fourlary-production.up.railway.app/api/like-foto/',
        ),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id_foto": post['id_foto'], "id_user": userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Remove Like Response: $data");
      } else {
        print("Error removing like: ${response.statusCode}");
        throw Exception('Error removing like');
      }
    } catch (e) {
      print("Error removing like: $e");
    }
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
                        const Icon(Icons.search, color: Colors.grey),
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
                          icon: const Icon(
                            Iconsax.setting_4,
                            color: Colors.grey,
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
                                  // Profile Photo with First Letter of Username
                                  CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    radius: 18,
                                    child: Text(
                                      post['username'][0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                                print(
                                  "Navigating to Detail Page with ID: ${post['id_foto']}",
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        GalleryDetailPage(post: post),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'image-${post['image']}',
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

                            // 🔸 Like, Comment, Share bar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  // Like Icon and Count
                                  IconButton(
                                    onPressed: () {
                                      _toggleLike(post);
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
                                  Text('${post['likes']} Suka'),

                                  const SizedBox(width: 18),

                                  // Comment Icon and "Komentar"
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
                                    child: const Icon(Icons.comment, size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("Komentar"),

                                  // Share Icon aligned to the right
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      // Logic to share the gallery (e.g., using share_plus package)
                                    },
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.black,
                                    ),
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
