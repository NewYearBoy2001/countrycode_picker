import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> countries = [];
  String selectedCountry = "Bahrain";
  Map<String, String> phoneNumberFormats = {
    "Bahrain": "+973",
    "Egypt": "+20",
    "Kuwait": "+965",
    "Oman": "+968",
    "Qatar": "+974",
    "Saudi Arabia": "+966",
  };
  String phoneNumberFormat = "+973";
  TextEditingController phoneNumberController = TextEditingController();
  int allowedNumberCount = 8;

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  Future<void> fetchDataFromAPI() async {
    final response = await http.get(Uri.parse('https://lovicasales.demoatcrayotech.com/api/country/list/test'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> countryList = responseData['data'];

      setState(() {
        countries = countryList.cast<Map<String, dynamic>>().toList();
        phoneNumberFormat = phoneNumberFormats[selectedCountry] ?? "";
        allowedNumberCount = int.tryParse(countries
            .firstWhere((country) =>
        country['countryname_en'] == selectedCountry)['number_allowed']) ??
            8;
      });
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country code picker with "\n" allocated number formate'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: selectedCountry,
              onChanged: (newValue) {
                setState(() {
                  selectedCountry = newValue!;
                 phoneNumberFormat = phoneNumberFormats[selectedCountry] ?? "";
                  allowedNumberCount = int.tryParse(countries
                      .firstWhere((country) =>
                  country['countryname_en'] == selectedCountry)['number_allowed']) ??
                      8;
                });
              },
              items: countries
                  .map<DropdownMenuItem<String>>(
                    (country) => DropdownMenuItem<String>(
                  value: country['countryname_en'].toString(),
                  child: Text(country['countryname_en'].toString()),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Country: ${selectedCountry.isEmpty ? "Select a country" : selectedCountry}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              'Phone Number Format: $phoneNumberFormat',
              style: const TextStyle(fontSize: 18,color: Colors.red),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                maxLength: allowedNumberCount, // Set the maximum character count for the phone number
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    //borderSide: BorderSide(color: Colors.red,width: 50),
                  ),
                  hintText: 'Enter your number',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }
}
