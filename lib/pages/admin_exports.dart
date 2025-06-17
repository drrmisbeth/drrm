import 'package:flutter/material.dart';

class AdminExportsPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const AdminExportsPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 24),
            child: Card(
              color: colorScheme.secondary.withOpacity(0.13),
              elevation: 7,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 18 : 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Exports',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: isMobile ? 18 : null,
                            color: colorScheme.primary,
                          ),
                    ),
                    SizedBox(height: isMobile ? 10 : 24),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.picture_as_pdf, color: colorScheme.primary),
                      label: Text('Export to PDF (placeholder)', style: TextStyle(color: colorScheme.primary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary.withOpacity(0.13),
                        foregroundColor: colorScheme.primary,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.table_chart, color: colorScheme.secondary),
                      label: Text('Export to Excel (placeholder)', style: TextStyle(color: colorScheme.secondary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary.withOpacity(0.13),
                        foregroundColor: colorScheme.secondary,
                        elevation: 0,
                        shape: const StadiumBorder(),
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
