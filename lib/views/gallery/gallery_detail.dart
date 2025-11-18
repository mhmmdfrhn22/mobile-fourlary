import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GalleryDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const GalleryDetailPage({super.key, required this.post});

  @override
  State<GalleryDetailPage> createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  TextEditingController commentController = TextEditingController();

  // URL API untuk mengambil komentar berdasarkan foto
  final String API_URL =
      'https://backend-fourlary-production.up.railway.app/api/komentar-foto'; // URL yang sesuai dengan backend

  // Fungsi untuk mengambil komentar dari API
  Future<void> fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$API_URL/${widget.post['id_foto']}',
        ), // Mengambil komentar berdasarkan id foto
      );
      print('ID Foto: ${widget.post['id_foto']}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          comments = data.map((item) {
            return {
              'user': item['username']?.toString() ?? 'User',
              'comment':
                  item['isi_komentar']?.toString() ?? 'Tidak ada komentar',
              'replies': item['replies'] ?? [], // Memastikan balasan tersedia
            };
          }).toList();
          isLoading = false;
        });
      } else {
        print('Failed to load comments. Status code: ${response.statusCode}');
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mengirim komentar baru
  Future<void> sendComment(String comment) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://backend-fourlary-production.up.railway.app/api/komentar-foto',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_foto': widget.post['id'],
          'id_user': 1, // Ganti dengan ID user yang aktif
          'isi_komentar': comment,
          'parent_id': null, // Ganti jika komentar ini adalah balasan
        }),
      );

      if (response.statusCode == 200) {
        fetchComments(); // Refresh komentar setelah berhasil kirim
        commentController.clear(); // Clear input field
      } else {
        throw Exception('Failed to send comment');
      }
    } catch (e) {
      print('Error sending comment: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComments(); // Memanggil API saat halaman pertama kali dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Komentar"),
        backgroundColor: Colors.white,
        elevation: 0.3,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🔹 Hero Image
          Hero(
            tag: widget.post['image'],
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                widget.post['image'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),

          // 🔹 Caption
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.post['profile']),
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: "${widget.post['username']} ",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: widget.post['caption'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 🔹 List komentar
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                c['user'][0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text.rich(
                              TextSpan(
                                text: '${c['user']} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: c['comment'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(Iconsax.heart, size: 18),
                          ),
                          // 🔹 Menampilkan balasan jika ada
                          if (c['replies'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                children: c['replies'].map<Widget>((reply) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        reply['user'][0].toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text.rich(
                                      TextSpan(
                                        text: '${reply['user']} ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: reply['comment'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

          // 🔹 Input komentar bawah
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=15',
                  ),
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: "Tambahkan komentar...",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.send1, size: 20),
                  onPressed: () {
                    String comment = commentController.text.trim();
                    if (comment.isNotEmpty) {
                      sendComment(comment); // Kirim komentar
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
