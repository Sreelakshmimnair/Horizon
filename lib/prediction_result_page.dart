import 'package:flutter/material.dart';

class PredictionResultPage extends StatelessWidget {
  final Map<String, dynamic> predictionData;

  const PredictionResultPage({Key? key, required this.predictionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate predicted college list based on input data
    List<Map<String, dynamic>> predictedColleges = _generatePredictedColleges();

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Predicted Colleges for You",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: predictedColleges.length,
                itemBuilder: (context, index) {
                  return _buildCollegeCard(predictedColleges[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollegeCard(Map<String, dynamic> college, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              image: DecorationImage(
                image: AssetImage(college['image']),
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
                        college['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Match: ${college['matchPercentage']}%",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  college['location'],
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.school, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 4),
                    Text(
                      "Course: ${college['course']}",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 4),
                    Text(
                      "Tuition: ${college['tuition']}",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.stars, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 4),
                    Text(
                      "Requirements: ${college['requirements']}",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Show more details if needed
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

  List<Map<String, dynamic>> _generatePredictedColleges() {
    // This is where you would implement your actual prediction algorithm
    // For now, returning mock data based on the input

    String country = predictionData['country'] ?? 'Germany';
    String course = predictionData['course'] ?? 'Computer Science';
    
    // Sample logic to determine colleges based on country
    List<Map<String, dynamic>> colleges = [];
    
    if (country == 'Germany') {
      colleges = [
        {
          'name': 'Technical University of Munich',
          'location': 'Munich, Germany',
          'image': 'assets/images/tum.jpg',
          'matchPercentage': 95,
          'course': course,
          'tuition': '€1,500/semester',
          'requirements': 'IELTS 6.5+',
        },
        {
          'name': 'RWTH Aachen University',
          'location': 'Aachen, Germany',
          'image': 'assets/images/rwth.jpg',
          'matchPercentage': 88,
          'course': course,
          'tuition': '€1,200/semester',
          'requirements': 'IELTS 6.0+',
        },
        {
          'name': 'Humboldt University of Berlin',
          'location': 'Berlin, Germany',
          'image': 'assets/images/humboldt.jpg',
          'matchPercentage': 82,
          'course': course,
          'tuition': '€1,300/semester',
          'requirements': 'IELTS 6.5+',
        },
      ];
    } else if (country == 'Canada') {
      colleges = [
        {
          'name': 'University of Toronto',
          'location': 'Toronto, Canada',
          'image': 'assets/images/toronto.jpg',
          'matchPercentage': 91,
          'course': course,
          'tuition': 'CAD 55,000/year',
          'requirements': 'IELTS 6.5+',
        },
        {
          'name': 'University of British Columbia',
          'location': 'Vancouver, Canada',
          'image': 'assets/images/ubc.jpg',
          'matchPercentage': 87,
          'course': course,
          'tuition': 'CAD 49,000/year',
          'requirements': 'IELTS 6.5+',
        },
        {
          'name': 'McGill University',
          'location': 'Montreal, Canada',
          'image': 'assets/images/mcgill.jpg',
          'matchPercentage': 84,
          'course': course,
          'tuition': 'CAD 51,000/year',
          'requirements': 'IELTS 6.5+',
        },
      ];
    } else if (country == 'UK') {
      colleges = [
        {
          'name': 'Imperial College London',
          'location': 'London, UK',
          'image': 'assets/images/imperial.jpg',
          'matchPercentage': 93,
          'course': course,
          'tuition': '£35,000/year',
          'requirements': 'IELTS 7.0+',
        },
        {
          'name': 'University of Oxford',
          'location': 'Oxford, UK',
          'image': 'assets/images/oxford.jpg',
          'matchPercentage': 90,
          'course': course,
          'tuition': '£38,000/year',
          'requirements': 'IELTS 7.0+',
        },
        {
          'name': 'University of Manchester',
          'location': 'Manchester, UK',
          'image': 'assets/images/manchester.jpg',
          'matchPercentage': 85,
          'course': course,
          'tuition': '£28,000/year',
          'requirements': 'IELTS 6.5+',
        },
      ];
    }
    
    // You would implement more sophisticated logic here to match colleges
    // based on all the user inputs like test scores, preferences, etc.
    
    return colleges;
  }
}
