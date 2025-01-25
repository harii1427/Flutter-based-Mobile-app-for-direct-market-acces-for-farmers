// ignore_for_file: deprecated_member_use, use_build_context_synchronously, prefer_const_constructors, use_super_parameters, avoid_print, unused_import, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:far/utils/api.dart';
import 'package:far/Backend/details_functionality.dart';
import 'payment_gateway.dart'; // Import your payment gateway

class DetailsPage extends StatefulWidget {
  final Vegetable vegetable; // Replaced Animal with Vegetable
  final bool isEditMode;

  const DetailsPage({
    super.key,
    required this.vegetable,
    this.isEditMode = false,
    required Null Function(dynamic updatedVegetable) onVegetableUpdated, required animal,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isButtonVisible = true;

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _characteristicController;
  late TextEditingController _addressController;

  double _quantity = 0.25; // Quantity for the order, starting with 0.25/kg
  double _calculatedPrice = 0; // Calculated price based on quantity

  @override
  void initState() {
    super.initState();
    if (widget.vegetable.videos.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.vegetable.videos[0])
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
            _isButtonVisible = true;
          });
        });
    }

    // Initialize text controllers with vegetable data
    _nameController = TextEditingController(text: widget.vegetable.name);
    _priceController = TextEditingController(text: widget.vegetable.price);
    _descriptionController =
        TextEditingController(text: widget.vegetable.description);
    _characteristicController =
        TextEditingController(text: widget.vegetable.characteristic);
    _addressController = TextEditingController(text: widget.vegetable.address);

    // Initialize calculated price with initial price
    _calculatedPrice = double.parse(widget.vegetable.price) * 0.25; // Start with 0.25/kg
  }

  @override
  void dispose() {
    if (_isVideoInitialized) {
      _controller.dispose();
    }
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _characteristicController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity += 0.25; // Increment by 0.25/kg
      _calculatedPrice = (double.parse(widget.vegetable.price)) * _quantity;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 0.25) {
      setState(() {
        _quantity -= 0.25; // Decrement by 0.25/kg
        _calculatedPrice = (double.parse(widget.vegetable.price)) * _quantity;
      });
    }
  }

  Future<void> _launch(String url) async {
    await DetailsPageFunctions.launchUrl(context, url);
  }

  void _showFullScreenGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          images: widget.vegetable.images,
          videos: widget.vegetable.videos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Future<void> _updateVegetable() async {
    await DetailsPageFunctions.updateVegetable(
      context,
      widget.vegetable,
      _nameController.text,
      _priceController.text,
      _descriptionController.text,
      _characteristicController.text,
      _addressController.text,
    );
  }

  Future<void> _updateRoleAndAddToBuyerCollection(String newRole) async {
    await DetailsPageFunctions.updateRoleAndAddToBuyerCollection(
        context, widget.vegetable, newRole);
  }

  void _navigateToPaymentGateway() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentsGateway(
          paymentAmount: _calculatedPrice.toString(),
          orderId: "ORDER123", // Replace with actual order ID
          userId: "USER123", // Replace with actual user ID
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 83, 134, 72),
          ),
          child: AppBar(
            title: const Text(
              'Farmer',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: widget.isEditMode
                ? [
                    IconButton(
                      icon: Icon(Icons.save),
                      onPressed: _updateVegetable, // Call the update function
                    ),
                  ]
                : null,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: widget.vegetable.images.length +
                            (_isVideoInitialized ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < widget.vegetable.images.length) {
                            return GestureDetector(
                              onTap: () {
                                _showFullScreenGallery(index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        widget.vegetable.images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          } else if (_isVideoInitialized) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                    _isButtonVisible = true;
                                  } else {
                                    _controller.play();
                                    _isButtonVisible = false;
                                  }
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio:
                                        _controller.value.aspectRatio,
                                    child: VideoPlayer(_controller),
                                  ),
                                  if (_isButtonVisible)
                                    const Icon(
                                      Icons.play_circle_outline,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                            );
                          }
                          return Container(); // Fallback, should never reach here
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        widget.isEditMode
                            ? Expanded(
                                child: TextField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Price',
                                  ),
                                ),
                              )
                            : Text(
                                '₹${widget.vegetable.price}/kg',
                                style: const TextStyle(fontSize: 50),
                              ),
                        const Spacer(),
                        if (widget.vegetable.additionalFields
                            .containsKey('PHONE_NUMBER'))
                          GestureDetector(
                            onTap: () {
                              _launch(
                                  'tel:${widget.vegetable.additionalFields['PHONE_NUMBER']}');
                            },
                            child: const Icon(Icons.phone,
                                color: Colors.green, size: 40),
                          ),
                        const SizedBox(width: 16),
                        if (widget.vegetable.additionalFields
                            .containsKey('PHONE_NUMBER'))
                          GestureDetector(
                            onTap: () {
                              _launch(
                                  'https://wa.me/${widget.vegetable.additionalFields['PHONE_NUMBER']}');
                            },
                            child: Image.asset(
                              'images/whatsapp.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                        if (widget.vegetable.additionalFields
                            .containsKey('INSTAGRAM'))
                          const SizedBox(width: 16),
                        if (widget.vegetable.additionalFields
                            .containsKey('INSTAGRAM'))
                          GestureDetector(
                            onTap: () async {
                              await _updateRoleAndAddToBuyerCollection('Buyer');
                              _launch(widget.vegetable
                                  .additionalFields['INSTAGRAM']!);
                            },
                            child: Image.asset(
                              'images/insta.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    widget.isEditMode
                        ? TextField(
                            controller: _nameController,
                            decoration: InputDecoration(labelText: 'Name'),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'NAME: ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: widget.vegetable.name,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 8),
                    widget.isEditMode
                        ? TextField(
                            controller: _descriptionController,
                            decoration: InputDecoration(labelText: 'Description'),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'DESCRIPTION: ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: widget.vegetable.description,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 8),
                    widget.isEditMode
                        ? TextField(
                            controller: _characteristicController,
                            decoration: InputDecoration(
                                labelText: 'Characteristic'),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'CHARACTERISTIC: ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: widget.vegetable.characteristic,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 8),
                    widget.isEditMode
                        ? TextField(
                            controller: _addressController,
                            decoration: InputDecoration(labelText: 'Address'),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'ADDRESS: ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: widget.vegetable.address,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 8),
                    // Display additional fields except phone number and Instagram
                    ...widget.vegetable.additionalFields.entries.map((entry) {
                      if (entry.key != 'PHONE_NUMBER' &&
                          entry.key != 'INSTAGRAM' &&
                          entry.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${entry.key}: ',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: entry.value,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Container();
                    }),
                  ],
                ),
              ),
            ),
          ),
          // Bottom bar with quantity controls and Buy button, hidden in edit mode
          if (!widget.isEditMode)
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                      ),
                      Text(
                        '${_quantity}kg',
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total: ₹${_calculatedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: _navigateToPaymentGateway,
                        child: const Text('Buy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final List<String> videos;
  final int initialIndex;

  const FullScreenGallery({
    Key? key,
    required this.images,
    required this.videos,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenGalleryState createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late VideoPlayerController _videoController;
  late PageController _pageController;
  bool _isVideoInitialized = false;
  bool _isButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    if (widget.videos.isNotEmpty) {
      _videoController = VideoPlayerController.network(widget.videos[0])
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
            _isButtonVisible = true;
          });
        });

      _videoController.addListener(() {
        setState(() {
          _isButtonVisible = !_videoController.value.isPlaying;
        });
      });
    }
  }

  @override
  void dispose() {
    if (_isVideoInitialized) {
      _videoController.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleryItems = [
      ...widget.images.map((imageUrl) => GalleryItem(imageUrl: imageUrl)),
      ...widget.videos.map((videoUrl) => GalleryItem(videoUrl: videoUrl)),
    ];

    return Scaffold(
      body: PhotoViewGallery.builder(
        itemCount: galleryItems.length,
        builder: (context, index) {
          final item = galleryItems[index];
          if (item.imageUrl != null) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(item.imageUrl!),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          } else if (item.videoUrl != null) {
            return PhotoViewGalleryPageOptions.customChild(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoController.value.isPlaying) {
                      _videoController.pause();
                      _isButtonVisible = true;
                    } else {
                      _videoController.play();
                      _isButtonVisible = false;
                    }
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: VideoProgressIndicator(
                        _videoController,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          backgroundColor: Colors.grey,
                          playedColor: Colors.red,
                          bufferedColor: Colors.white,
                        ),
                      ),
                    ),
                    if (_isButtonVisible)
                      IconButton(
                        icon: Icon(
                          _videoController.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 64,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_videoController.value.isPlaying) {
                              _videoController.pause();
                              _isButtonVisible = true;
                            } else {
                              _videoController.play();
                              _isButtonVisible = false;
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          }
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(''),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        pageController: _pageController,
        scrollPhysics: BouncingScrollPhysics(),
      ),
    );
  }
}

class GalleryItem {
  final String? imageUrl;
  final String? videoUrl;

  GalleryItem({this.imageUrl, this.videoUrl});
}
