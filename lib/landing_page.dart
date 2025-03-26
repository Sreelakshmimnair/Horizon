import 'package:flutter/material.dart';
import 'homepage.dart';
import 'prediction_result_page.dart';
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
  String? selectedStream;
  String? selectedCourse;
  String? selectedDuration;
  String higherStudies = "Yes";
  String internshipAvailable = "Yes";
  String partTimeJob = "Yes";
  String stayBack = "Yes";
  String predictionResult = "";
  bool isLoading = false;
  final TextEditingController percentageController = TextEditingController();
  final TextEditingController feesController = TextEditingController();
  
  // Sliders values for language tests
  double ieltsScore = 6.0;
  double toeflScore = 80.0;
  double pteScore = 50.0;

  // Streams available for selection
  final List<String> streams = [
    "Arts",
    "Commerce",
    "Engineering",
    "Medical",
    "Nursing",
    "Science",
    "Law",
    "Aviation"
  ];

  // Courses categorized by streams
  final Map<String, List<String>> coursesByStream = {
    "Arts": [
      "Honours Bachelor of Social Work",
      "Hospitality and Tourism Management BA",
      "International Business BA",
      "International Business Management BA (Hons)",
      "Marketing BA",
      "Philosophy and Economics BA",
      "Politics and International Relations BA",
      "Social Work BA (Hons)",
      "Sociology BA",
      "Statistics (BA)",
      "Tourism Management with Language, BA (Hons)",
      "UG Diploma in Journalism Communications",
      "Undergraduate Diploma in Digital Visual Effects",
      "Advanced Diploma in Graphic Design"
    ],
    "Commerce": [
      "International Business (BComm)",
      "Marketing (BComm)",
      "International Business Management BA (Hons)",
      "International Business with Marketing BSc",
      "International Management BSc (Hons)",
      "Marketing and Management BSc",
      "Marketing, BSc (Hons)",
      "Marketing, Business - Diploma"
    ],
    "Engineering": [
      "Mechanical Engineering (BEng)",
      "Mechanical Engineering BEng (Hons)",
      "Nuclear Engineering BEng (Hons)",
      "Mechatronics Engineering BEng",
      "Robotics BEng",
      "Robotics Engineering - BEng",
      "Software Engineering BEng",
      "Software Engineering BEng (Hons)",
      "Mechanical Engineering (B. Sc.)",
      "B.Sc. in Electrical Engineering and Information Systems Technology",
      "Bachelor of Science in Computer Science and Software Engineering",
      "Software Engineering BSc (Hons)",
      "Integrated Degree program in Architecture",
      "Integrated Degree program in Mechanical Engineering",
      "Mechanical Engineering Technology Advanced Diploma",
      "Mechanical Engineering Technology- Diploma",
      "Robotics and Artificial Intelligence Meng"
    ],
    "Medical": [
      "Medicine BM5 (BMBS)",
      "MBBS Medicine & Surgery",
      "Paramedic Science BSc",
      "Paramedic Science BSc (Hons)",
      "Pharmaceutical Sciences BSc",
      "Pharmaceutical and Chemical Sciences BSc (Hons)",
      "Pharmaceutical science BSc(Hons)",
      "Pharmaceutical and cosmetic science BSc",
      "Pharmacology BSc",
      "Pharmacology BSc/MSci",
      "Physiotherapy BSc",
      "MB, BChir Medicine",
      "MBBCH in Medicine",
      "MBBS Medicine",
      "MBBS/BSc Medicine",
      "MBChB",
      "MBChB Medicine",
      "Medicine and Surgery MBChB",
      "VetMB Veterinary Medicine"
    ],
    "Nursing": [
      "Practical Nursing - Diploma",
      "Adult Nursing BSc",
      "Adult Nursing, BN (Hons)",
      "BSc (Hons) Adult Nursing",
      "BSc (Hons) Nursing",
      "BSc (Hons) Nursing (Mental Health)",
      "BSc (Hons) Nursing Adult",
      "BSc (Hons) Nursing Science",
      "BN Nursing Studies",
      "BNurs in Nursing (Adult)",
      "BNurs in Nursing (Mental Health)",

    ],
    "Science": [
      "Jewellery & Metal Design BDes",
      "International Tourism Management BSc (Hons)",
      "Mathematics BSc (Hons)",
      "Microbiology BSc (Hons)",
      "Psychology BSc (Hons)",
      "Marine Biology, BSc (Hons)",
      "Psychology BSc Hons",
      "International Tourism and Hospitality Management BSc",
      "Logistics with Supply Chain Management BSc",
      "Marine & Freshwater Biology BSc",
      "Mathematics and Physics BSc",
      "Mathematics with Computer Science BSc",
      "Mathematics with Economics BSc",
      "Media and Communication BSc",
      "Medical Science Bmed Sci(Hons)",
      "Molecular Biotechnology",
      "Neuroscience (BSc)",
      "Physics (BSc)",
      "Physics and Astrophysics (International Study) BSc",
      "Psychology BSc",
      "Psychology and Cognitive Neuroscience BSc",
      "Psychology with Criminology BSc",
      "Psychology with Criminology BSc(Hons)",
      "Psychology with Education BSc",
      "Science and Engineering for Social Change BSc",
      "Statistics, Economics and Finance BSc",
      "Zoology BSc",
      "ZoologyBSc",
      "Honours Bachelor of Science in Computer Science Degree with Computer Programming Diploma",
      "Honours Bachelor of Technology (Construction Management)"
    ],
    "Law": [
      "LLB (Hons)",
      "LLB (Hons) Bachelor of Laws",
      "LLB (Hons) Business Law",
      "LLB (Hons) Law",
      "LLB (Hons) Law (Crime and Criminal Justice)",
      "LLB (Hons) Law and Criminal Justice",
      "LLB (Hons) in Law With Criminology",
      "LLB Bachelor of Laws",
      "LLB Law",
      "LLB Law with Business",
      "LLB Law with Criminology",
      "LLB(Hons) Law",
      "LLB/LLB (Hons) Law",
      "LLBLaw with Business Management",
      "LLBLaw with Criminology",
      "Law (Eng/NI) with Energy Law LLB",
      "Law (Individual Rights)LLB (Hons)",
      "Law (LLB)",
      "Law LLB",
      "Law LLB (Hons)",
      "Law LLB Hons",
      "Law LLB(Hons)",
      "Law with Criminal Justice LLB",
      "Law with Criminology -LLB (Hons)",
      "Law with Criminology LLB (Hons)",
      "Law with Criminology, LLB (Hons)",
      "Law with CriminologyLLB",
      "Law with Social Policy, LLB (Hons)",
      "Law, LLB Hons",
      "Law- LLB (Hons)",
      "LawLLB"
    ],
    "Aviation": [
      "Aviation Management",
      "Aviation Technology",
      "Commercial Pilot License"
    ]
  };

  final List<Map<String, String>> countries = [
    {"name": "Germany", "flag": "assets/images/germany.png"},
    {"name": "Canada", "flag": "assets/images/canada.png"},
    {"name": "UK", "flag": "assets/images/uk.jpg"},
  ];
  double parseFees(String fees) {
  try {
    // Remove spaces and convert lowercase
    fees = fees.trim().toLowerCase();

    // Check if the value is a range (e.g., "15k-30k")
    if (fees.contains('-')) {
      List<String> parts = fees.split('-');
      if (parts.length == 2) {
        double start = parseFees(parts[0]);
        double end = parseFees(parts[1]);
        return (start + end) / 2; // Take the average of the range
      }
    }

    // Convert "15k" to 15000
    if (fees.endsWith('k')) {
      return double.parse(fees.replaceAll('k', '')) * 1000;
    }

    // Convert regular numbers
    return double.parse(fees);
  } catch (e) {
    print("Invalid fee format: $fees");
    return 0.0; // Default to 0.0 if parsing fails
  }
}

Future<void> predictCollege() async {
  setState(() {
    isLoading = true;
  });

  try {
    final url = Uri.parse("https://flask-8v3h.onrender.com/predict");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Country": selectedCountry,
        "Course": selectedCourse,
        "IELTS": ieltsScore,
        "Plustwo": double.tryParse(percentageController.text.trim()) ?? 0.0,
        "TOEFL": toeflScore,
        "PTE": pteScore,
        "Fees": parseFees(feesController.text.trim()),
        "Duration": selectedDuration,
        "Internship": internshipAvailable,
        "Partime": partTimeJob,
        "Stayback": stayBack,
        "HigherStudies": higherStudies,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      List<Map<String, dynamic>> colleges = [];

      if (result is List) {
        // API returns a list of colleges
        colleges = List<Map<String, dynamic>>.from(result);
      } else if (result is Map<String, dynamic> && result.containsKey("college")) {
        // API returns a single college, wrap it in a list
        colleges = [
          {
            "name": result["college"],
            "matchPercentage": "N/A",
            "image": "https://via.placeholder.com/150",
            "location": "N/A",
            "tuition": "N/A",
            "requirements": "N/A"
          }
        ];
      }

      // Store the number of actual colleges received
      int collegeCount = colleges.length;

      // Ensure exactly 5 colleges are displayed
      while (colleges.length < 5) {
        colleges.add({
          "name": "Unknown College ${colleges.length + 1}",
          "matchPercentage": "N/A",
          "image": "https://via.placeholder.com/150",
          "location": "N/A",
          "tuition": "N/A",
          "requirements": "N/A"
        });
      }

      if (mounted) {
        setState(() {
          predictionResult = "Found $collegeCount college(s)";
          isLoading = false;
        });

        // Navigate to the results page with processed data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PredictionResultPage(
              predictionData: {
                "colleges": colleges,
                "collegeCount": collegeCount, // Pass count to next page
              },
            ),
          ),
        );
      }
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        predictionResult = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }
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
                _buildCountryDropdown(),
                
                _buildLabel("Select Stream"),
                _buildStreamDropdown(),
                
                _buildLabel("Select Course"),
                _buildCourseDropdown(),
                
                _buildTextField("+2 Percentage", percentageController, keyboardType: TextInputType.number),

                // Language score sliders
                _buildLabel("IELTS Score: ${ieltsScore.toStringAsFixed(1)}"),
                _buildSlider(
                  value: ieltsScore,
                  min: 1.0,
                  max: 9.0,
                  divisions: 16,
                  onChanged: (value) {
                    setState(() {
                      ieltsScore = value;
                    });
                  },
                ),

                _buildLabel("TOEFL Score: ${toeflScore.toStringAsFixed(0)}"),
                _buildSlider(
                  value: toeflScore,
                  min: 0.0,
                  max: 120.0,
                  divisions: 120,
                  onChanged: (value) {
                    setState(() {
                      toeflScore = value;
                    });
                  },
                ),

                _buildLabel("PTE Score: ${pteScore.toStringAsFixed(0)}"),
                _buildSlider(
                  value: pteScore,
                  min: 0.0,
                  max: 90.0,
                  divisions: 80,
                  onChanged: (value) {
                    setState(() {
                      pteScore = value;
                    });
                  },
                ),
                _buildLabel("Enter the fee range (e.g., 15k-20k) *"),
                _buildTextField("15k-20k", feesController),
                _buildLabel("Select Duration (Years)"),
                _buildDurationDropdown(),


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
                      if (selectedCountry == null || selectedStream == null || selectedCourse == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select country, stream and course"),
                            backgroundColor: Colors.red,
                          )
                        );
                        return;
                      }
                      
                      // Show loading indicator
                      setState(() {
                        isLoading = true;
                      });
                      
                      // Simulate API call
                      await Future.delayed(Duration(seconds: 1));
                      
                      // Navigate directly to result page without waiting for API
                      _navigateToPredictionResult();
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: value.toStringAsFixed(1),
        activeColor: Colors.white,
        inactiveColor: Colors.white.withOpacity(0.3),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCountryDropdown() {
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

  Widget _buildStreamDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        value: selectedStream,
        hint: Text("Choose a stream", style: TextStyle(color: Colors.white)),
        items: streams.map((stream) {
          return DropdownMenuItem<String>( 
            value: stream,
            child: Text(
              stream,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedStream = newValue;
            // Reset the selected course when stream changes
            selectedCourse = null;
          });
        },
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    // Get courses based on selected stream
    List<String> courses = selectedStream != null 
        ? coursesByStream[selectedStream] ?? []
        : [];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        value: selectedCourse,
        hint: Text(
          selectedStream == null 
              ? "Select a stream first" 
              : "Choose a course", 
          style: TextStyle(color: Colors.white)
        ),
        items: courses.map((course) {
          return DropdownMenuItem<String>( 
            value: course,
            child: Text(
              course,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: selectedStream == null 
            ? null 
            : (String? newValue) {
                setState(() {
                  selectedCourse = newValue;
                });
              },
        decoration: InputDecoration(border: InputBorder.none),
        isExpanded: true, // Ensures long text doesn't get cut off
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
  Widget _buildDurationDropdown() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: selectedDuration,
      hint: Text("Choose duration", style: TextStyle(color: Colors.white)),
      items: ["1", "2", "3", "4"].map((duration) {
        return DropdownMenuItem<String>(
          value: duration,
          child: Text(
            "$duration Years",
            style: TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedDuration = newValue;
        });
      },
      decoration: InputDecoration(border: InputBorder.none),
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
        isExpanded: true,
      ),
    );
  }

 void _navigateToPredictionResult() async {
  setState(() {
    isLoading = true;
  });

  try {
    // Format the data according to what your API expects
    Map<String, dynamic> predictionData = {
      "Country": selectedCountry,
      "Course": selectedCourse,
      "IELTS": ieltsScore,
      "Plustwo": double.tryParse(percentageController.text.trim()) ?? 0.0,
      "TOEFL": toeflScore,
      "PTE": pteScore,
      "Fees": parseFees(feesController.text.trim()),
      "Duration": selectedDuration,
      "Internship": internshipAvailable,
      "Partime": partTimeJob,
      "Stayback": stayBack,
      "HigherStudies": higherStudies,
    };
    
    // Reset loading state
    setState(() {
      isLoading = false;
    });
    
    // Navigate to the prediction result page with the properly formatted data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictionResultPage(predictionData: predictionData),
      ),
    );
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error preparing prediction data: ${e.toString()}"),
        backgroundColor: Colors.red,
      )
    );
  }
}
}