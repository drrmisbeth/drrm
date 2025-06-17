import 'package:flutter/material.dart';

class SchoolSubmitFormPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const SchoolSubmitFormPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          color: Colors.white.withOpacity(0.99),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 40,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit Drill Report',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 27,
                      color: Colors.black,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    items: ['Earthquake', 'Fire', 'Flood'].map((e) =>
                      DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (_) {},
                    decoration: InputDecoration(
                      labelText: 'Drill Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: Icon(Icons.category, color: colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      suffixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    readOnly: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                      prefixIcon: Icon(Icons.notes, color: colorScheme.primary),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.upload_file, color: colorScheme.primary),
                    label: Text('Upload File (placeholder)', style: TextStyle(color: colorScheme.primary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      backgroundColor: colorScheme.secondary.withOpacity(0.07),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
