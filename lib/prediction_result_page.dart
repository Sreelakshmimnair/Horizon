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
      print("Sending request to API...");
      print("Request Data: ${jsonEncode(widget.predictionData)}");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.predictionData),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Parse the response based on its structure
        final jsonResponse = jsonDecode(response.body);
        
        // Check if the response is a map or a list
        if (jsonResponse is Map<String, dynamic>) {
          // Handle single college response
          setState(() {
            predictedColleges = [jsonResponse]; // Wrap single object in a list
            isLoading = false;
          });
        } else if (jsonResponse is List) {
          // Handle list of colleges
          setState(() {
            predictedColleges = List<Map<String, dynamic>>.from(jsonResponse);
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch predictions: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching predictions: $e';
      });
      print('Error fetching predictions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prediction Results"),
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
                ? _buildErrorView()
                : predictedColleges.isEmpty
                    ? Center(
                        child: Text(
                          "No predictions found",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : _buildPredictionList(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _fetchPredictions,
            child: Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Predicted Colleges for You",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: predictedColleges.length,
            itemBuilder: (context, index) {
              return _buildCollegeCard(predictedColleges[index]);
            },
            separatorBuilder: (context, index) => SizedBox(height: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCollegeCard(Map<String, dynamic> college) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              image: DecorationImage(
                image: NetworkImage(college['image']?.toString().isNotEmpty == true
                    ? college['image']
                    : 'https://via.placeholder.com/150'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        college['name'] ?? college['college'] ?? 'Unknown College',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Match: ${college['matchPercentage'] ?? college['match'] ?? 90}%",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(college['location'] ?? '${college['Country'] ?? widget.predictionData['Country']}', 
                     style: TextStyle(color: Colors.grey.shade600)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.school, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text("Course: ${college['course'] ?? college['Course'] ?? widget.predictionData['Course'] ?? 'Unknown'}", 
                           style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 4),
                    Text("Tuition: ${college['tuition'] ?? college['fees'] ?? 'Contact university'}",
                         style: TextStyle(fontSize: 14)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.stars, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text("Requirements: ${_getRequirements(college)}",
                           style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {}, // Add navigation or action here
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("View Details", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to extract requirements from the response
  String _getRequirements(Map<String, dynamic> college) {
    if (college.containsKey('requirements') && college['requirements'] != null) {
      return college['requirements'];
    }
    
    List<String> reqs = [];
    
    if (college.containsKey('IELTS') && college['IELTS'] != null) {
      reqs.add("IELTS: ${college['IELTS']}");
    }
    
    if (college.containsKey('Plustwo') && college['Plustwo'] != null) {
      reqs.add("Plus Two: ${college['Plustwo']}%");
    }
    
    if (reqs.isEmpty) {
      return "Contact university for details";
    }
    
    return reqs.join(", ");
  }
}