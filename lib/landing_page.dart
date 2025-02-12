import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CollegePredictorPage(),
    );
  }
}

class CollegePredictorPage extends StatefulWidget {
  @override
  _CollegePredictorPageState createState() => _CollegePredictorPageState();
}

class _CollegePredictorPageState extends State<CollegePredictorPage> {
  String? selectedCountry;
  final TextEditingController courseController = TextEditingController();
  final TextEditingController ieltsController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();
  final TextEditingController toeflController = TextEditingController();
  final TextEditingController pteController = TextEditingController();

  final List<Map<String, String>> countries = [
    {"name": "Germany", "flag": "assets/images/germany.png"},
    {"name": "Canada", "flag": "assets/images/canada.png"},
    {"name": "UK", "flag": "assets/images/uk.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "College Predictor",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildLabel("Select Country"),
                _buildDropdown(),
                _buildTextField("Course", courseController),
                _buildTextField("IELTS Score", ieltsController, keyboardType: TextInputType.number),
                _buildTextField("+2 Percentage", percentageController, keyboardType: TextInputType.number),
                _buildTextField("TOEFL Score (optional)", toeflController, keyboardType: TextInputType.number),
                _buildTextField("PTE Score (optional)", pteController, keyboardType: TextInputType.number),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _showPredictionResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      "Predict",
                      style: TextStyle(fontSize: 18, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Prediction Result:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        value: selectedCountry,
        hint: Text("Choose a country", style: TextStyle(color: Colors.white)),
        items: countries.map((country) {
          return DropdownMenuItem<String>(
            value: country["name"],
            child: Row(
              children: [
                Image.asset(
                  country["flag"]!,
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 10),
                Text(
                  country["name"]!,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedCountry = newValue;
          });
        },
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 10),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  void _showPredictionResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue.shade900,
        title: Text("Prediction Result", style: TextStyle(color: Colors.white)),
        content: Text("Your predicted college will be displayed here.", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
