import 'package:flutter/material.dart';

class SchoolSubmitFormPage extends StatelessWidget {
  const SchoolSubmitFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24 : 40,
                horizontal: isMobile ? 16 : 36,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submit Drill Report',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            fontSize: isMobile ? 18 : null,
                          ),
                    ),
                    SizedBox(height: isMobile ? 18 : 32),
                    DropdownButtonFormField<String>(
                      items: ['Earthquake', 'Fire', 'Flood'].map((e) =>
                        DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (_) {},
                      decoration: InputDecoration(
                        labelText: 'Drill Type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 22),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {},
                    ),
                    SizedBox(height: isMobile ? 12 : 22),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: isMobile ? 12 : 22),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.upload_file, color: colorScheme.primary),
                      label: Text('Upload File (placeholder)', style: TextStyle(color: colorScheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: isMobile ? 18 : 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        onPressed: () {},
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
