import 'package:flutter/material.dart';

class PlantillaFormularios extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final GlobalKey<FormState> formKey;
  final String buttonText;
  final bool isLoading;

  const PlantillaFormularios({
    super.key,
    required this.title,
    required this.children,
    required this.onSave,
    required this.formKey,
    this.buttonText = 'GUARDAR',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        actions: [
          IconButton(
            onPressed: isLoading ? null : onSave,
            icon: Icon(Icons.save, color: primaryColor),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  ...children,
                  const SizedBox(height: 24),
                  _buildSubmitButton(primaryColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.white70,
              child: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isLoading ? null : onSave,
        child: Text(
          buttonText.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}