import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.118.161:8000/api';

  // Fetch categories from the API
  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categoryFields'));
    if (response.statusCode == 200) {
      List<dynamic> categories = jsonDecode(response.body);
      return categories.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Fetch fields for a specific category by categoryId
  static Future<Map<String, dynamic>> fetchFieldsForCategory(
      String categoryId) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/categoryFields/$categoryId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> fieldsData = jsonDecode(response.body);
      return fieldsData;
    } else {
      throw Exception('Failed to load fields for category');
    }
  }

  // Pick image from gallery
  static Future<XFile?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  // Pick video from gallery
  static Future<XFile?> pickVideoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickVideo(source: ImageSource.gallery);
  }

  // Submit category fields to the API
  static Future<void> submitCategoryFields(
      Map<String, dynamic> formData) async {
    Uri url = Uri.parse('$_baseUrl/categoryFields');
    var request = http.MultipartRequest('POST', url);

    // Add category and subcategory to the request fields
    request.fields['category_id'] = formData['category_id'];
    request.fields['created_by'] = formData['created_by'];
    request.fields['updated_by'] = formData['updated_by'];
    request.fields['user_id'] = formData['user_id'];
    if (formData['subcategory'] != null) {
      request.fields['subcategory'] = formData['subcategory'];
    }

    // Add dynamic fields to the request fields
    formData['fields'].forEach((key, value) {
      request.fields['fields[$key]'] = value;
    });

    // Add images to the request files
    for (var image in formData['images']) {
      if (image is String) {
        request.files
            .add(await http.MultipartFile.fromPath('fields[images]', image));
      } else {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile('fields[images]', stream, length,
            filename: image.path.split('/').last);
        request.files.add(multipartFile);
      }
    }

    // Add videos to the request files
    for (var video in formData['videos']) {
      if (video is String) {
        request.files
            .add(await http.MultipartFile.fromPath('fields[videos]', video));
      } else {
        var stream = http.ByteStream(video.openRead());
        var length = await video.length();
        var multipartFile = http.MultipartFile('fields[videos]', stream, length,
            filename: video.path.split('/').last);
        request.files.add(multipartFile);
      }
    }

    // Send the request
    var response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to submit category fields');
    }
  }

  // Fetch vegetables and fruits from the API
  static Future<List<Vegetable>> fetchVegetables() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categoryFields'));
      if (response.statusCode == 200) {
        List<dynamic> vegetablesJson = jsonDecode(response.body);
        return vegetablesJson.map((json) => Vegetable.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load vegetables with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load vegetables: $e');
    }
  }

  // Update vegetable or fruit data in the API
  static Future<bool> updateVegetable(
      String id, String categoryId, Map<String, dynamic> updatedFields) async {
    final url = Uri.parse('$_baseUrl/categoryFields/$id/$categoryId');
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "fields": updatedFields,
    });

    final response = await http.patch(url, headers: headers, body: body);
    return response.statusCode == 200;
  }

  void setCoordinates(double? latitude, double? longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  // Variables to store the coordinates
  double? _longitude;
  double? _latitude;

  // Getters for coordinates
  double get longitude => _longitude ?? 0.0;
  double get latitude => _latitude ?? 0.0;
}

class Vegetable {
  final String id;
  final String categoryId; // Add this line
  final String description;
  final List<String> images;
  final String price;
  final String name;
  final String age;
  final String characteristic;
  final List<String> videos;
  final String pinCode;
  final String address;
  final Map<String, dynamic> additionalFields;
  final double latitude;
  final double longitude;

  Vegetable({
    required this.id,
    required this.categoryId, // Add this line
    required this.description,
    required this.images,
    required this.price,
    required this.name,
    required this.age,
    required this.characteristic,
    required this.videos,
    required this.pinCode,
    required this.address,
    required this.additionalFields,
    required this.latitude,
    required this.longitude,
  });

  factory Vegetable.fromJson(Map<String, dynamic> json) {
    return Vegetable(
      id: json['_id'] ?? 'No ID provided',
      categoryId: json['category_id']['_id'] ??
          'No Category ID provided', // Add this line
      description: json['fields']['DESCRIPTION'] ?? 'No description provided',
      images: List<String>.from(json['fields']['IMAGE'] ?? []),
      price: json['fields']['PRICE'] ?? 'No price provided',
      name: json['fields']['NAME'] ?? 'No name provided',
      age: json['fields']['AGE'] ?? 'No age provided',
      characteristic:
          json['fields']['CHARACTERISTIC'] ?? 'No characteristic provided',
      videos: List<String>.from(json['fields']['VIDEO'] ?? []),
      pinCode: json['fields']['PIN_CODE'] ?? 'No pin code provided',
      address: json['fields']['ADDRESS'] ?? 'No address provided',
      additionalFields:
          Map<String, dynamic>.from(json['fields']['additionalFields'] ?? {}),
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }

  Null get weight => null;
}
