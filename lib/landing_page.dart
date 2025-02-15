import 'package:flutter/material.dart';
import 'homepage.dart'; // Import the HomePage
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String higherStudies = "Yes";
  String internshipAvailable = "Yes";
  String partTimeJob = "Yes";
  String stayBack = "Yes";
  String predictionResult = "";
  bool isLoading = false;
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
Future<void> predictCollege() async {
     setState(() {
      isLoading = true;  
    }); 
    final url = Uri.parse("http://192.168.43.253:5000/predict"); 
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Country": selectedCountry,
        "Course": courseController.text,
        "IELTS": double.tryParse(ieltsController.text) ?? 0.0,
        "Plustwo": double.tryParse(percentageController.text) ?? 0.0,
        "TOEFL": double.tryParse(toeflController.text) ?? 0.0,
        "PTE": double.tryParse(pteController.text) ?? 0.0,
        "Internship": internshipAvailable, 
        "Partime": partTimeJob,
        "Stayback": stayBack,
        "HigherStudies": higherStudies,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        predictionResult = result["college"];
      });
    } else {
      setState(() {
        predictionResult = "Error: Unable to predict.";
      });
    }

    setState(() {
      isLoading = false;  
    });
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("College Predictor"),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
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
                _buildTextField("+2 Percentage", percentageController, keyboardType: TextInputType.number),

                // IELTS, TOEFL, PTE in a single row
                _buildLabel("Language Scores"),
                Row(
                  children: [
                    Expanded(child: _buildSmallTextField("IELTS", ieltsController)),
                    SizedBox(width: 8),
                    Expanded(child: _buildSmallTextField("TOEFL", toeflController)),
                    SizedBox(width: 8),
                    Expanded(child: _buildSmallTextField("PTE", pteController)),
                  ],
                ),

                SizedBox(height: 20),
                _buildLabel("Higher Studies Possible?"),
                _buildYesNoDropdown((val) => setState(() => higherStudies = val ?? "Yes"), higherStudies),

                _buildLabel("Internship Available?"),
                _buildYesNoDropdown((val) => setState(() => internshipAvailable = val ?? "Yes"), internshipAvailable),

                _buildLabel("Part-time Job?"),
                _buildYesNoDropdown((val) => setState(() => partTimeJob = val ?? "Yes"), partTimeJob),

                _buildLabel("Stay Back?"),
                _buildYesNoDropdown((val) => setState(() => stayBack = val ?? "Yes"), stayBack),

                SizedBox(height: 20),
                Center(
  child: ElevatedButton(
    onPressed: () async {
      await predictCollege();  // Call the prediction API first
      _showPredictionResult(); // Then show the result
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 8,
    ),
    child: Text(
      isLoading ? "Loading..." : "Predict",
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

  Widget _buildSmallTextField(String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
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

  Widget _buildYesNoDropdown(ValueChanged<String?>? onChanged, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String?>(
        value: value,
        dropdownColor: Colors.white,
        onChanged: onChanged,
        items: ["Yes", "No"].map((option) {
          return DropdownMenuItem<String?>(
            value: option,
            child: Text(option, style: TextStyle(color: Colors.black)),
          );
        }).toList(),
        underline: SizedBox(),
      ),
    );
  }

  void _showPredictionResult() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.blue.shade900,
      title: Text("Prediction Result", style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold)),
      content: Text(
        predictionResult.isNotEmpty ? predictionResult : "No prediction available.",
        style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

}
