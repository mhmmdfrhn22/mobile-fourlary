import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for json decoding

class PembinatDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PembinatDetailPage({super.key, required this.post});

  @override
  _PembinatDetailPageState createState() => _PembinatDetailPageState();
}

class _PembinatDetailPageState extends State<PembinatDetailPage> {
  late Future<Map<String, dynamic>> pembimbingFuture;

  @override
  void initState() {
    super.initState();
    pembimbingFuture = fetchPembimbingData();
  }

  // Fetch Pembimbing data from the API
  Future<Map<String, dynamic>> fetchPembimbingData() async {
    final response = await http.get(
      Uri.parse(
        'https://backend-fourlary-production.up.railway.app/api/pembimbing',
      ),
    );

    if (response.statusCode == 200) {
      // Decode the JSON response
      final List<dynamic> pembimbingData = json.decode(response.body);

      // Check if data exists and return the first pembimbing
      return pembimbingData.isNotEmpty
          ? pembimbingData[0]
          : {}; // Fetch the first pembimbing from the list
    } else {
      throw Exception('Failed to load pembimbing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.post['nama_pekerjaan']),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: FutureBuilder<Map<String, dynamic>>(
          future: pembimbingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Pembimbing data not available.'),
              );
            }

            final pembimbing = snapshot.data!;
            final pembimbingImage =
                pembimbing['foto_pembimbing'] ??
                'https://res.cloudinary.com/dprywyfwm/image/upload/vdefault/default-user.png';
            final pembimbingName = pembimbing['nama'] ?? 'Tidak ada pembimbing';
            final pembimbingDescription =
                pembimbing['deskripsi'] ?? 'Deskripsi pembimbing tidak tersedia.';
            final pembimbingContact =
                pembimbing['link_wa'] ?? 'https://wa.me/6280000000000';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.post['gambar_pekerjaan'],
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Job Title
                  Text(
                    widget.post['nama_pekerjaan'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Job Description
                  Text(
                    widget.post['deskripsi'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pembimbing Info
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Pembimbing:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(pembimbingImage),
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(  // Wrap the column inside an Expanded widget for dynamic sizing
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pembimbingName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,  // Allow the text to expand as needed
                              child: Text(
                                pembimbingDescription,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.5, // Adjusted height for better readability
                                ),
                                maxLines: 3, // Limit text to 3 lines
                                overflow: TextOverflow.ellipsis, // Prevent overflow
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Contact Button (Contact via WhatsApp)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.08,
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Open link (i.e., WhatsApp chat with the pembimbing)
                          final link = pembimbingContact;
                          launchUrl(Uri.parse(link));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green.shade600, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                        ),
                        child: const Text(
                          'Kontak Pembimbing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
