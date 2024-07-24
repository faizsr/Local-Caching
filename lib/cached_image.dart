import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_caching/database.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;

  const CachedImage({super.key, required this.imageUrl});

  Future<Uint8List?> _fetchImage() async {
    Uint8List? cachedImage = await DatabaseHelper().getImage(imageUrl);
    if (cachedImage != null) {
      return cachedImage;
    } else {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        DatabaseHelper().insertImage(imageUrl, response.bodyBytes);
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _fetchImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else {
          return Image.memory(snapshot.data!);
        }
      },
    );
  }
}
