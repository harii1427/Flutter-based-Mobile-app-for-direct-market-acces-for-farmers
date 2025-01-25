// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, unnecessary_string_interpolations, use_build_context_synchronously

import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:far/Frontend/seller_page.dart';
import 'package:video_player/video_player.dart';
import 'utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:far/Frontend/Buyer_page.dart';
import 'package:far/Frontend/Explore_buy_page.dart'; // Import SellerDetails screen
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class Sell extends StatefulWidget {
  const Sell({super.key});

  @override
  _SellState createState() => _SellState();
}

class _SellState extends State<Sell> {
  final Map<String, TextEditingController> _fieldControllers = {};
  List<Map<String, dynamic>> _categories = [];
  final List<String> _subcategories = [];
  List<String> _dynamicFieldKeys = [];
  final List<dynamic> _images = [];
  String? _videoUrl;
  bool _isLoading = false;
  String? _selectedCategoryId;
  String? _selectedSubcategory;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;

  int _currentIndex = 1;
  String? _userId; // State variable to store user ID

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _getUserId(); // Fetch the user ID on initialization
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await ApiService.fetchCategories();

      final uniqueCategories = categories
          .fold<Map<String, Map<String, dynamic>>>({}, (map, item) {
            map[item['category_id']['_id']] = item;
            return map;
          })
          .values
          .toList();

      setState(() {
        _categories = uniqueCategories;
      });
    } catch (e) {
      setState(() {
        // Handle the error gracefully
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFieldsForCategory(String categoryId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fields = await ApiService.fetchFieldsForCategory(categoryId);

      setState(() {
        _dynamicFieldKeys = fields.keys
            .where((key) =>
                key != 'IMAGE' && key != 'VIDEO' && key != 'additionalFields')
            .toList();

        final additionalFields = fields['additionalFields'] ?? {};
        additionalFields.keys.forEach((key) {
          if (!_dynamicFieldKeys.contains(key)) {
            _dynamicFieldKeys.add(key);
          }
        });

        _fieldControllers.clear();
        for (var key in _dynamicFieldKeys) {
          _fieldControllers[key] = TextEditingController();
        }
      });
    } catch (e) {
      // Debugging output
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoPlayer(String path) async {
    _videoPlayerController?.dispose();
    _videoPlayerController = kIsWeb
        ? VideoPlayerController.network(path)
        : VideoPlayerController.file(io.File(path));

    await _videoPlayerController!.initialize();
    setState(() {
      _isVideoInitialized = true;
    });
  }

  Future<void> _pickVideoFromCamera() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(source: ImageSource.camera);
    if (pickedVideo != null) {
      setState(() {
        _videoUrl = pickedVideo.path;
        _initializeVideoPlayer(pickedVideo.path);
      });
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      setState(() {
        _videoUrl = pickedVideo.path;
        _initializeVideoPlayer(pickedVideo.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _images.add(kIsWeb ? pickedImage.path : io.File(pickedImage.path));
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _images.add(kIsWeb ? pickedImage.path : io.File(pickedImage.path));
      });
    }
  }

  void _showMediaOptionsDialog(
      String title, VoidCallback onCameraTap, VoidCallback onGalleryTap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Open camera'),
              onTap: () {
                Navigator.of(context).pop();
                onCameraTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                onGalleryTap();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions() {
    _showMediaOptionsDialog(
        'Choose Photo', _pickImageFromCamera, _pickImageFromGallery);
  }

  void _showVideoOptions() {
    _showMediaOptionsDialog(
        'Choose Video', _pickVideoFromCamera, _pickVideoFromGallery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 83, 134, 72),
              ),
              child: AppBar(
                title: const Text(
                  'far',
                  style: TextStyle(
                    color: Color.fromARGB(255, 201, 187, 29),
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: const Text('Select Category'),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['category_id']['_id'],
                        child: Text(category['category_id']['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        _fetchFieldsForCategory(value!);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_subcategories.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedSubcategory,
                      hint: const Text('Select Subcategory'),
                      items: _subcategories.map((subcategory) {
                        return DropdownMenuItem<String>(
                          value: subcategory,
                          child: Text(subcategory),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubcategory = value;
                        });
                      },
                    ),
                  const SizedBox(height: 20),
                  if (_dynamicFieldKeys.isNotEmpty)
                    ..._dynamicFieldKeys.map((fieldKey) {
                      return _buildInputContainer(context, fieldKey);
                    }),
                  const SizedBox(height: 20),
                  _buildPhotoUploadBoxes(
                    context,
                    _images,
                    _videoUrl,
                    _showImageOptions,
                    _showVideoOptions,
                  ),
                  const SizedBox(height: 50),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 83, 134, 72),
                          Color.fromARGB(255, 174, 212, 170)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: _submitCategoryFields,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(5),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildInputContainer(BuildContext context, String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _fieldControllers[fieldName],
            decoration: InputDecoration(
              hintText: '$fieldName',
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPhotoUploadBoxes(
    BuildContext context,
    List<dynamic> images,
    String? videoUrl,
    VoidCallback onAddImage,
    VoidCallback onAddVideo,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Photos and Videos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: onAddImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 20),
            if (images.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final image = images[index];
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: kIsWeb
                                ? Image.network(
                                    image,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    image,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  images.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: onAddVideo,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Icon(
                  Icons.video_camera_back_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 20),
            if (videoUrl != null && _isVideoInitialized)
              Expanded(
                child: AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_videoPlayerController!),
                      VideoProgressIndicator(_videoPlayerController!,
                          allowScrubbing: true),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _videoUrl = null;
                              _videoPlayerController?.dispose();
                              _videoPlayerController = null;
                              _isVideoInitialized = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitCategoryFields() async {
    if (_selectedCategoryId == null) {
      _showErrorDialog('Error', 'Please select a category.');
      return;
    }

    // Check if any fields are empty
    for (var key in _dynamicFieldKeys) {
      if (_fieldControllers[key]?.text.isEmpty ?? true) {
        _showErrorDialog('Error', 'Please fill all the fields.');
        return;
      }
    }

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.118.161:8000/api/categoryFields'));
    request.fields['category_id'] = _selectedCategoryId!;
    request.fields['created_by'] = 'Admin';
    request.fields['updated_by'] = 'Admin';

    // Include firebase_uid in the request if available
    if (_userId != null) {
      request.fields['user_id'] = _userId!;
    }

    _fieldControllers.forEach((key, controller) {
      request.fields['fields[$key]'] = controller.text;
    });

    for (var image in _images) {
      if (kIsWeb) {
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

    if (_videoUrl != null) {
      if (kIsWeb) {
        request.files.add(
            await http.MultipartFile.fromPath('fields[videos]', _videoUrl!));
      } else {
        var stream = http.ByteStream(io.File(_videoUrl!).openRead());
        var length = await io.File(_videoUrl!).length();
        var multipartFile = http.MultipartFile('fields[videos]', stream, length,
            filename: _videoUrl!.split('/').last);
        request.files.add(multipartFile);
      }
    }

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        _showSuccessDialog('Success', 'Animal data submitted successfully.');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const SellerDetails()), // Navigate to SellerDetails.dart
        );
      } else {
        var responseBody = await response.stream.bytesToString();
        throw Exception('Failed to submit category fields: $responseBody');
      }
    } catch (e) {
      _showErrorDialog('Error', e.toString());
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExploreBuy()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          label: 'India',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Buy',
        ),
      ],
    );
  }
}
