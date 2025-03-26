import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionResultPage extends StatefulWidget {
  final Map<String, dynamic> predictionData;

  const PredictionResultPage({Key? key, required this.predictionData}) : super(key: key);

  @override
  _PredictionResultPageState createState() => _PredictionResultPageState();
}

class _PredictionResultPageState extends State<PredictionResultPage> {
  List<Map<String, dynamic>> predictedColleges = [];
  bool isLoading = true;
  String errorMessage = '';

  static const String apiUrl = 'https://flask-8v3h.onrender.com/predict';

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
  }

  Future<void> _fetchPredictions() async {
    try {
      print("🚀 Sending request to API...");
      print("Request Data: ${jsonEncode(widget.predictionData)}");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.predictionData),
      );

      print("✅ Response Status Code: ${response.statusCode}");
      print("📜 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        dynamic jsonResponse;
        try {
          jsonResponse = jsonDecode(response.body);
        } catch (e) {
          print("❌ Invalid JSON: $e");
          setState(() {
            predictedColleges = [{"name": "Invalid API Response", "message": response.body}];
            isLoading = false;
          });
          return;
        }

        List<Map<String, dynamic>> colleges = _extractCollegesFromResponse(jsonResponse);

        print("📌 Extracted Colleges: ${colleges.map((c) => c['name']).toList()}");

        setState(() {
          predictedColleges = colleges.take(5).toList(); // Display only top 5 colleges
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch predictions: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching predictions: $e';
      });
      print('❌ Error fetching predictions: $e');
    }
  }

  List<Map<String, dynamic>> _extractCollegesFromResponse(dynamic response) {
  List<Map<String, dynamic>> colleges = [];

  if (response is Map<String, dynamic> && response.containsKey("top_5_colleges")) {
    List<dynamic> topColleges = response["top_5_colleges"];
    
    for (var college in topColleges) {
      if (college is Map<String, dynamic> && college.containsKey("college")) {
        colleges.add({
          "name": college["college"], // Extract the college name
          "confidence": college["confidence"] ?? 0.0 // Confidence score (optional)
        });
      }
    }
  }

  return colleges;
}

  bool _isLikelyCollegeObject(Map<String, dynamic> map) {
    return map.containsKey('name') || map.containsKey('collegeName') || map.containsKey('location');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Your Best-Fit College"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Error", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text(errorMessage, style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = '';
                              });
                              _fetchPredictions();
                            },
                            child: Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildPredictionList(),
      ),
    );
  }

  Widget _buildPredictionList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Top Colleges Matching Your Profile",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: predictedColleges.length,
            itemBuilder: (context, index) {
              return _buildCollegeCard(predictedColleges[index]);
            },
            separatorBuilder: (context, index) => SizedBox(height: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildCollegeCard(Map<String, dynamic> college) {
    String collegeName = college['name'] ?? 'Unknown College';
    String location = college['location'] ?? 'N/A';
    String imageUrl = college['image'] ?? 'https://via.placeholder.com/150';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collegeName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Location: $location", style: TextStyle(color: Colors.grey.shade600)),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _showCollegeDetails(college),
                  child: Text("Explore College"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCollegeDetails(Map<String, dynamic> college) {
    // You can add more details inside this modal bottom sheet
  }
}
