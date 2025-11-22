import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int currentUserId = 0;
  String currentMode = 'new'; // 'new', 'edit', or 'reply'
  Map<String, dynamic>? targetComment; // Used for editing or replying
  String currentUsername = ''; // Store the current user's username

  final String API_URL =
      'https://backend-fourlary-production.up.railway.app/api/komentar-foto';

  // Function to get user data from SharedPreferences
  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userId') ?? 0; // Get userId from SharedPreferences
      currentUsername = prefs.getString('username') ?? ''; // Get username from SharedPreferences
    });
  }

  Future<void> fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/${widget.post['id_foto']}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          comments = data.map((item) {
            return {
              'user': item['username'] ?? 'User',
              'comment': item['isi_komentar'] ?? 'Tidak ada komentar',
              'replies': item['replies'] ?? [],
              'commentDate': item['tanggal_komentar'] ?? '',
              'id_user': item['id_user'],
              'id_komentar': item['id_komentar'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendComment(String comment, {int? parentId}) async {
    try {
      print('Mengirim komentar...');
      print('Komentar: $comment');
      print('parentId: $parentId');
      print('ID Foto: ${widget.post['id_foto']}');  // Pastikan id_foto ada di sini

      final response = await http.post(
        Uri.parse(API_URL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_foto': widget.post['id_foto'],
          'id_user': currentUserId,
          'isi_komentar': comment,
          'parent_id': parentId,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Gantilah pengecekan status code 200 dengan 201
      if (response.statusCode == 201) {
        print('Komentar berhasil dikirim');
        fetchComments(); // Refresh comments after send
        commentController.clear(); // Clear input field
        setState(() {
          currentMode = 'new'; // Reset mode back to 'new' after sending reply
        });
      } else {
        print('Gagal mengirim komentar. Status code: ${response.statusCode}');
        throw Exception('Failed to send comment');
      }
    } catch (e) {
      print('Error sending comment: $e');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final response = await http.delete(Uri.parse('$API_URL/$commentId'));
      if (response.statusCode == 200) {
        fetchComments(); // Refresh comments after delete
      } else {
        throw Exception('Failed to delete comment');
      }
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  Future<void> editComment(int commentId, String newComment) async {
    try {
      final response = await http.put(
        Uri.parse('$API_URL/$commentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isi_komentar': newComment}),
      );
      if (response.statusCode == 200) {
        fetchComments(); // Refresh comments after edit
      } else {
        throw Exception('Failed to edit comment');
      }
    } catch (e) {
      print('Error editing comment: $e');
    }
  }

  String formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    print('ID Foto di DetailPage: ${widget.post['id_foto']}'); // Memastikan ID foto diterima dengan benar
    _getUserData(); // Get user data when the page is opened
    fetchComments(); // Fetch comments
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
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                CircleAvatar(
                  child: Text(
                    widget.post['username'][0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                          ),
                          // Tanggal Komentar
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              formatDate(c['commentDate']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          // Balasan dengan format "Balasan dari @username"
                          if (c['replies'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: c['replies'].map<Widget>((reply) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Iconsax.repeat,
                                          size: 14,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Balas @${reply['username']}: ${reply['isi_komentar']}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          // Tombol Balas, Edit, Hapus
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              children: [
                                if (currentMode == 'new')
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        currentMode = 'reply';
                                        targetComment = c;
                                      });
                                    },
                                    child: const Text(
                                      "Balas",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                if (c['id_user'] == currentUserId) ...[
                                  // Hanya bisa edit atau hapus komentar milik pengguna
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        currentMode = 'edit';
                                        targetComment = c;
                                        commentController.text = c['comment'];
                                      });
                                    },
                                    child: const Text(
                                      "Edit",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteComment(c['id_komentar']);
                                    },
                                    child: const Text(
                                      "Hapus",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
          // Input komentar (mode baru, reply, atau edit)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  child: Text(
                    currentUsername.isNotEmpty ? currentUsername[0].toUpperCase() : '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: currentMode == 'reply'
                          ? 'Balas @${targetComment?['user']}...'
                          : currentMode == 'edit'
                              ? 'Edit komentar...'
                              : 'Tambahkan komentar...',
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
                      if (currentMode == 'reply' && targetComment != null) {
                        sendComment(
                          comment,
                          parentId: targetComment?['id_komentar'],
                        );
                      } else if (currentMode == 'edit' &&
                          targetComment != null) {
                        editComment(targetComment?['id_komentar'], comment);
                      } else {
                        sendComment(comment); // Send new comment
                      }
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
