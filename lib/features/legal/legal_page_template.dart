import 'package:questra_app/imports.dart';

class LegalPageTemplate extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> sections;

  const LegalPageTemplate({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text('Last Updated: August 2023',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                )),
            SizedBox(height: 20),
            ...sections.expand((section) => [
                  _buildSection(
                    title: section['title'],
                    content: section['content'],
                  ),
                  Divider(color: Colors.grey[800], height: 40),
                ]),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text('© 2023 Questra. All rights reserved.',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.5,
            )),
        SizedBox(height: 8),
        ...content.map((text) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(text,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    height: 1.4,
                  )),
            )),
      ],
    );
  }
}
