import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_dropd/shared/nav_bar.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AddConcertReview extends StatefulWidget {
  final String userId;
  const AddConcertReview({super.key, required this.userId});

  @override
  State<AddConcertReview> createState() => _AddConcertReviewState();
}

class _AddConcertReviewState extends State<AddConcertReview> {
  final TextEditingController artistController = TextEditingController();
  final TextEditingController albumController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();
  final List<Uint8List> selectedImages = [];

  double rating = 0.0; // initial rating that is displayed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(userId: widget.userId,), // nav bar
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("Add a Concert Review",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Container(
                //width: 282,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 28),
                color: Colors.white,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    bool isDesktop = constraints.maxWidth >= 600;
                    double fieldWidth = isDesktop ? (constraints.maxWidth / 2) - 20 : constraints.maxWidth;

                    return Wrap(spacing: 20, runSpacing: 15, 
                      children:[
                        SizedBox(
                          width: fieldWidth,
                          child: buildTextField("Artist Name:", artistController),
                        ),

                        SizedBox(
                          width: fieldWidth,
                          child: buildTextField("Tour/Album Name:", albumController),

                        ),

                        SizedBox(
                          width: fieldWidth,
                          child: buildTextField("Date:", dateController),
                        ),

                        SizedBox(
                          width: fieldWidth,
                          child: buildTextField("Location:", locationController),
                        ),

                        SizedBox(
                          width: fieldWidth,
                          child: buildStarRatingField(),
                        ),
                        
                        SizedBox(
                          width: fieldWidth,
                          child: buildLongTextField("Review:", reviewController),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: buildImageUploadField(),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(onPressed: submitConcertReview, child: const Text("Post Concert Review")), 
                        )
                      ], // wrap children
                    );
                  }, // builder
                ),
              ),
            ], // column children
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD8D8D8), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD8D8D8), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStarRatingField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rating:",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            IconData icon;
            if (rating >= index + 1) {
              icon = Icons.star; // full star
            } else if (rating > index && rating < index + 1) {
              icon = Icons.star_half; // half star
            } else {
              icon = Icons.star_border; // empty star
            }

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: (details) {
                  // Detect if tapped left or right half
                  double tappedPosition = details.localPosition.dx;
                  double starWidth = 40; // approximate width of each star
                  setState(() {
                    if (tappedPosition <= starWidth / 2) {
                      rating = index + 0.5;
                    } else {
                      rating = index + 1.0;
                    }
                  });
                },
                  child: Icon(icon, color: Colors.amber, size: 40),
              ),
            );
          }),
        ),
      ],
    );
  }
  
  Widget buildLongTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: null,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10), // padding inside the text box
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                width: 1,
                color: Color(0xFFD8D8D8),
              ),
            ),
          enabledBorder: OutlineInputBorder( // border when not focused
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder( // border when focused
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 1.5,
            ),
          ),
          ),
        ),
      ],
    );
  }

  Widget buildImageUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Images (max 5):",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: pickImages,
          child: const Text("Select Images"),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...selectedImages.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), 
                    child: Image.memory(entry.value, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Positioned(top: 2, right: 2, 
                    child: GestureDetector(
                      onTap: () => setState(() =>
                        selectedImages.removeAt(entry.key)),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (selectedImages.length < 5) 
              GestureDetector(
                onTap: pickImages,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.grey),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage(limit: 5);
    final List<Uint8List> newSelectedImages = [];
    
    if (images == null || images.isEmpty) return;
    for (final xfile in images) {
      if (selectedImages.length >= 5) break; 
      final bytes = await xfile.readAsBytes();
      newSelectedImages.add(bytes);
      setState(() {
        selectedImages.addAll(newSelectedImages);
      });
    }
  }

  Future<void> submitConcertReview() async {
    if (artistController.text.trim().isEmpty || albumController.text.trim().isEmpty || reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    } 

    final url = Uri.parse("http://localhost:3000/concert-reviews");
    final request = http.MultipartRequest('POST', url); // replace with your backend URL

    request.fields.addAll({
      "userId": widget.userId,
      "artist_name": artistController.text.trim(),
      "title": albumController.text.trim(),
      "date": dateController.text.trim(),
      "location": locationController.text.trim(),
      "rating": rating.toString(),
      "review_text": reviewController.text.trim(),
    });

    // Attach images
    for (int i=0; i<selectedImages.length; i++) {
      request.files.add(http.MultipartFile.fromBytes('images', selectedImages[i], filename: 'image_$i.jpg',),);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully!")),
        );
        // Optionally, clear the form or navigate away
        // Optional: Clear form after submission
        artistController.clear();
        albumController.clear();
        locationController.clear();
        dateController.clear();
        reviewController.clear();
        setState(() {
          rating = 0;
          selectedImages.clear();
        });
      } else {
        print("Status code: ${response.statusCode}, Body: ${response.body}"); // for debugging

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit review. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while submitting the review.")),
      );
    }
  }

  @override
  void dispose() {
    artistController.dispose();
    albumController.dispose();
    locationController.dispose();
    dateController.dispose();
    reviewController.dispose();
    super.dispose();
  }
}