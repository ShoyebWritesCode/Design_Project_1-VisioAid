import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: TextStyle(
            fontFamily: 'Sora', // Set the Sora font family
          ),
        ),
        backgroundColor: Color(0xff005aee), // Replace with your custom color
      ),
      body: buildFAQPage(),
    );
  }

  Widget buildFAQPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            FAQItem(
              question: 'What is Flutter?',
              answer: 'Flutter is an open-source UI software development toolkit created by Google.',
            ),
            FAQItem(
              question: 'How does Flutter work?',
              answer: 'Flutter uses a reactive framework to build cross-platform applications with a single codebase.',
            ),
            FAQItem(
              question: 'How does Flutter work?',
              answer: 'Flutter uses a reactive framework to build cross-platform applications with a single codebase.',
            ),
            FAQItem(
              question: 'How does Flutter work?',
              answer: 'Flutter uses a reactive framework to build cross-platform applications with a single codebase.',
            ),


            // Add more FAQItem widgets as needed
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              answer,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Sora', // Set the Sora font family
              ),
            ),
            SizedBox(height: 8.0),
            IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () {
                // You can implement the logic to play the corresponding sound for the FAQ item
              },
            ),
          ],
        ),
      ),
    );
  }
}