import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const DiagnomassApp());
}

class DiagnomassApp extends StatelessWidget {
  const DiagnomassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnomass: Derma-Vision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto', 
      ),
      home: const DermaVisionScreen(),
    );
  }
}

class DermaVisionScreen extends StatefulWidget {
  const DermaVisionScreen({super.key});

  @override
  State<DermaVisionScreen> createState() => _DermaVisionScreenState();
}

class _DermaVisionScreenState extends State<DermaVisionScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _webImage;
  bool _isLoading = false;
  String _result = "";

  double _age = 50.0;
  String _selectedSex = 'Male';
  String _selectedSite = 'Torso';

  final List<String> _sites = [
    'Head/Neck', 'Lower Extremity', 'Oral/Genital', 
    'Palms/Soles', 'Torso', 'Upper Extremity'
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f;
        _result = ""; 
      });
    }
  }

  Future<void> _runAnalysis() async {
    if (_webImage == null) {
      setState(() => _result = "⚠️ Please upload a dermoscopic image.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ⚠️ REPLACE WITH YOUR ACTUAL HUGGING FACE API URL
      final targetUrl ='https://SOU-mya/Derma-Vision/api/predict');
      final uri = Uri.parse('https://corsproxy.io/?' + Uri.encodeComponent(targetUrl));
      
      String base64Image = "data:image/jpeg;base64,${base64Encode(_webImage!)}";

      var response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "data": [
            base64Image,
            _age,
            _selectedSex,
            _selectedSite
          ]
        }),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        setState(() => _result = responseData['data'][0].toString());
      } else {
        setState(() => _result = "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _result = "Connection Error. Please ensure the AI backend is awake.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnomass | Derma-Vision AI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Card(
              elevation: 6,
              shadowColor: Colors.teal.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'AI Lesion Analysis',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.teal.shade900),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dual-Stream EfficientNet-B7 Architecture',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.teal.shade200, width: 2, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _webImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(_webImage!, fit: BoxFit.contain),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 60, color: Colors.teal.shade300),
                                  const SizedBox(height: 16),
                                  Text("Click to Upload Dermoscopic Image", style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w600)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text("Patient Age: ${_age.toInt()}", style: const TextStyle(fontWeight: FontWeight.w600)),
                    Slider(
                      value: _age,
                      min: 0,
                      max: 120,
                      divisions: 120,
                      activeColor: Colors.teal,
                      label: _age.round().toString(),
                      onChanged: (double value) {
                        setState(() => _age = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Biological Sex',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            value: _selectedSex,
                            items: ['Male', 'Female'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (newValue) => setState(() => _selectedSex = newValue!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Anatomical Site',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            value: _selectedSite,
                            items: _sites.map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (newValue) => setState(() => _selectedSite = newValue!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _isLoading ? null : _runAnalysis,
                        child: _isLoading 
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('Run Diagnosis'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_result.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _result.contains('Malignant') ? Colors.red.shade50 : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _result.contains('Malignant') ? Colors.red.shade200 : Colors.teal.shade200),
                        ),
                        child: Text(
                          _result,
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: _result.contains('Malignant') ? Colors.red.shade900 : Colors.teal.shade900
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
