import 'package:flutter/material.dart';

class ContactDeveloper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Developer'),
        backgroundColor: Color(0xFF5C6BC0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For any queries or ideas, contact me:',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Email: devarsh.shahs07@gmail.com',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Phone: +1 3067508467', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
