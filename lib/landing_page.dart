import 'package:flutter/material.dart';
import 'homepage.dart';
import 'prediction_result_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CollegePredictorPage(),
    );
  }
}

class CollegePredictorPage extends StatefulWidget {
  const CollegePredictorPage({super.key});

  @override
  _CollegePredictorPageState createState() => _CollegePredictorPageState();
}

class _CollegePredictorPageState extends State<CollegePredictorPage> {
  String? selectedCountry;
  String? selectedStream;
  String? selectedCourse;
  String? selectedFeeRange;
  String higherStudies = "Yes";
  String internshipAvailable = "Yes";
  String partTimeJob = "Yes";
  String stayBack = "Yes";
  String predictionResult = "";
  bool isLoading = false;
  final TextEditingController percentageController = TextEditingController();
  
  // Sliders values for language tests
  double ieltsScore = 6.0;
  double toeflScore = 80.0;
  double pteScore = 50.0;

  // Fee ranges
  final List<String> feeRanges = [
    "0-20L",
    "20-40L",
    "40-60L",
    "60-80L",
  ];

  // Yes/No options
  final List<String> yesNoOptions = ["Yes", "No"];

  // Streams available for selection
  List<String> streams = [];

  // Courses categorized by streams
  List<Map<String, dynamic>> coursesByStream = [];

  final List<Map<String, String>> countries = [
    {"name": "Germany", "flag": "assets/images/germany.png"},
    {"name": "Canada", "flag": "assets/images/canada.png"},
    {"name": "UK", "flag": "assets/images/uk.jpg"},
  ];
  bool isLoadingCountries=true;
  bool isLoadingStreams=false;
  bool isLoadingCourses=false;
  double parseFeeRange(String feeRange) {
    // Parse the fee range and return a representative value
    switch (feeRange) {
      case "0-20L":
        return 1000000; // 10L as midpoint
      case "20-40L":
        return 3000000; // 30L as midpoint
      case "40-60L":
        return 5000000; // 50L as midpoint
      case "60-80L":
        return 7000000; // 70L as midpoint
      default:
        return 0.0;
    }
  }
@override
  void initState() {
    super.initState();
    selectedCountry="UK";
    fetchStreams(selectedCountry!);
  }
  Future <void> fetchStreams(String country) async{
  setState(() {
    isLoadingStreams=true;
    streams=[];
    selectedStream=null;
    coursesByStream=[];
  });
  try {
    final streamsnapshot=await FirebaseFirestore.instance.collection('countries').doc(country).collection('streams').get();
    final List<String> streamList=streamsnapshot.docs.map((doc)=>doc.id).toList();
    print("Fetched streams for $country: $streamList");
    setState(() {
      streams=streamList;
      isLoadingStreams=false;
    });
  } catch (e) {
    print("print error $e");
    setState(() {
      isLoadingStreams=false;
    });
    
  }
}
Future<void> fetchCourses(String country, String stream) async {
  setState(() {
    isLoadingCourses = true;
    coursesByStream = [];
    selectedCourse = null;
  });
  
  try {
    print("Attempting to fetch courses for country: '$country', stream: '$stream'");
    
    final coursesRef = FirebaseFirestore.instance
        .collection('countries')
        .doc(country)
        .collection('streams')
        .doc(stream)
        .collection('courses');
    
    print("Query path: ${coursesRef.path}");
    
    final snapshot = await coursesRef.get();
    
    print("Snapshot received, documents count: ${snapshot.docs.length}");
    
    if (snapshot.docs.isEmpty) {
      print("No course documents found in collection");
      setState(() {
        coursesByStream = [];
        isLoadingCourses = false;
      });
      return;
    }
    
    // Print the first document for debugging
    if (snapshot.docs.isNotEmpty) {
      print("First document ID: ${snapshot.docs.first.id}");
      print("First document data: ${snapshot.docs.first.data()}");
    }
    
    final List<Map<String, dynamic>> courseList = [];
      
      // Process each document
      for (var doc in snapshot.docs) {
        final Map<String, dynamic> courseData = {
          'id': doc.id,
          ...doc.data(),
        };
        
        // Debug each document
        print("Processing course: ${courseData['id']} - Fields: ${courseData.keys.join(', ')}");
        
        courseList.add(courseData);
      }
      
      print("Processed ${courseList.length} courses");
      
      setState(() {
        coursesByStream = courseList;
        isLoadingCourses = false;
      });
    } catch (e) {
      print("Error fetching courses: $e");
      print("Stack trace: ${StackTrace.current}");
      setState(() {
        isLoadingCourses = false;
    });
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
          "Fees": parseFeeRange(selectedFeeRange ?? "0-20L"),
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
      // Removed AppBar completely
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(  // Added SafeArea to respect system UI elements
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
                  
                  _buildLabel("+2 Percentage"),
                  _buildPercentageTextField(),

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
                    divisions: 90,
                    onChanged: (value) {
                      setState(() {
                        pteScore = value;
                      });
                    },
                  ),
                  
                  _buildLabel("Select Fee Range"),
                  _buildFeeRangeDropdown(),

                  SizedBox(height: 15),
                  
                  // Attractive and compact dropdowns for Yes/No options
                  _buildLabel("Additional Options"),
                  _buildAttractiveOptionsGrid(),

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
                        
                        // Validate percentage
                        String percentage = percentageController.text.trim();
                        if (percentage.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please enter +2 percentage"),
                              backgroundColor: Colors.red,
                            )
                          );
                          return;
                        }
                        
                        double? percentageValue = double.tryParse(percentage);
                        if (percentageValue == null || percentageValue > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please enter a valid percentage (maximum 100)"),
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
      ),
    );
  }

  // New attractive options grid with card-like UI
  Widget _buildAttractiveOptionsGrid() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade800.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAttractiveYesNoOption(
                  title: "Higher Studies",
                  icon: Icons.school,
                  value: higherStudies,
                  onChanged: (value) => setState(() => higherStudies = value!),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildAttractiveYesNoOption(
                  title: "Internship",
                  icon: Icons.business_center,
                  value: internshipAvailable,
                  onChanged: (value) => setState(() => internshipAvailable = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAttractiveYesNoOption(
                  title: "Part-time Job",
                  icon: Icons.work,
                  value: partTimeJob,
                  onChanged: (value) => setState(() => partTimeJob = value!),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildAttractiveYesNoOption(
                  title: "Stay Back",
                  icon: Icons.home,
                  value: stayBack,
                  onChanged: (value) => setState(() => stayBack = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Attractive card-like Yes/No option with icon
  Widget _buildAttractiveYesNoOption({
    required String title,
    required IconData icon,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 34,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                icon: Icon(
                  Icons.arrow_drop_down_circle,
                  color: Colors.white,
                  size: 18,
                ),
                dropdownColor: Colors.blue.shade700,
                items: yesNoOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: TextStyle(
                        color: option == value ? Colors.white : Colors.white.withOpacity(0.8),
                        fontWeight: option == value ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageTextField() {
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
          controller: percentageController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter percentage (0-100)",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Validate input on change
            if (value.isNotEmpty) {
              double? percentageValue = double.tryParse(value);
              if (percentageValue != null && percentageValue > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Percentage cannot exceed 100"),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  )
                );
              }
            }
          },
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
           if (newValue != null) {
            print("Country selected: $newValue");
            setState(() {
              selectedCountry = newValue;
              selectedStream = null;
              selectedCourse = null;
              streams = [];
              coursesByStream=[];
             
            });
            fetchStreams(newValue);
           }
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
        hint: Text(
          isLoadingStreams
              ? "Loading..."
              : streams.isEmpty
                  ? "No streams available"
                  : "Choose a stream",
          style: TextStyle(color: Colors.white),
        ),

        items: streams.map((stream) {
          return DropdownMenuItem<String>( 
            value: stream,
            child: Text(
              stream,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: isLoadingStreams || streams.isEmpty
            ? null
            : (String? newValue) {
                if (newValue != null) {
                  print("Stream selected: $newValue");
                  setState(() {
                    selectedStream = newValue;
                    selectedCourse = null;
                    coursesByStream = [];
                  });
                  fetchCourses(selectedCountry!, newValue);
                }
              },

        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    // Get courses based on selected stream
    // List<String> courses = selectedStream != null 
    //     ? coursesByStream[selectedStream] ?? []
    //     : [];
    
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
          isLoadingCourses
              ? "Loading..."
              : selectedStream == null
                  ? "Select a stream first"
                  : coursesByStream.isEmpty
                      ? "No courses available"
                      : "Choose a course",
          style: TextStyle(color: Colors.white),
        ),

        items: coursesByStream.map((course) {
          String courseId = course['id']; // document ID
          
          // Try multiple field names to accommodate different data structures
          // Remove quotes and colons from field names if present
          String? courseName;
          course.forEach((key, value) {
            if (key.toLowerCase().contains('course') && value is String) {
              courseName = value;
            }
          });
          
          if (courseName == null) {
            courseName = course['Course'] ?? 
                        course['course'] ?? 
                        course['title'] ?? 
                        course['name'] ?? 
                        courseId;
          }
          
          print("Creating dropdown item: $courseId → $courseName");

          return DropdownMenuItem<String>( 
            value: courseId,
            child: Text(
              courseName ?? "Unnamed Course",
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: isLoadingCourses || selectedStream == null || coursesByStream.isEmpty
            ? null
            : (String? newValue) {
                if (newValue != null) {
                  print("Course selected: $newValue");
                  setState(() {
                    selectedCourse = newValue;
                  });
                }
              },

        decoration: InputDecoration(border: InputBorder.none),
        isExpanded: true, // Ensures long text doesn't get cut off
      ),
    );
  }

  Widget _buildFeeRangeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: Colors.white,
        value: selectedFeeRange,
        hint: Text("Select fee range", style: TextStyle(color: Colors.white)),
        items: feeRanges.map((range) {
          return DropdownMenuItem<String>( 
            value: range,
            child: Text(
              range,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedFeeRange = newValue;
          });
        },
        decoration: InputDecoration(border: InputBorder.none),
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
        "Fees": parseFeeRange(selectedFeeRange ?? "0-20L"),
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