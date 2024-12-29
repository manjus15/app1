// lib/screens/select_bank_screen.dart
import 'package:flutter/material.dart';

class SelectBankScreen extends StatelessWidget {
  const SelectBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/cobank_logo.png', // Make sure to add this logo to your assets
                height: 80,
                width: 80,
              ),
              const SizedBox(height: 16),
              
              // Tagline
              const Text(
                'Elevate your finances with smart solutions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Bank',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 24),
              
              // Select your bank text
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select your bank',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Bank List
              Expanded(
                child: ListView.builder(
                  itemCount: banksList.length,
                  itemBuilder: (context, index) {
                    final bank = banksList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: bank.backgroundColor,
                        child: Text(
                          bank.shortName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        bank.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/mobile_verification');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Updated Bank class with more properties
class Bank {
  final String name;
  final String shortName;
  final Color backgroundColor;

  Bank({
    required this.name,
    required this.shortName,
    required this.backgroundColor,
  });
}

// Updated bank list with the banks shown in the image
final List<Bank> banksList = [
  Bank(
    name: 'AU Small Finance Bank',
    shortName: 'AU',
    backgroundColor: Colors.orange,
  ),
  Bank(
    name: 'Abhinandan Urban Co Op Bank Ltd',
    shortName: 'AB',
    backgroundColor: Colors.grey,
  ),
  Bank(
    name: 'Abhyudaya Co-Operative Bank',
    shortName: 'AB',
    backgroundColor: Colors.grey,
  ),
  Bank(
    name: 'Adarsh Co-Operative Bank Limited',
    shortName: 'AC',
    backgroundColor: Colors.grey,
  ),
  Bank(
    name: 'Adilabad District Co Op Central',
    shortName: 'AD',
    backgroundColor: Colors.grey,
  ),
  Bank(
    name: 'Ajantha Urban Co-Op bank',
    shortName: 'AJ',
    backgroundColor: Colors.grey,
  ),
  Bank(
    name: 'Akhand Anand Co-Op Bank Ltd',
    shortName: 'AK',
    backgroundColor: Colors.grey,
  ),
  // Add more banks as needed
];