import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../widgets/custom_text_field.dart';
import '../models/inquiry_type.dart';
import 'alternative_contact_info.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedInquiryType = InquiryType.types.first;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    // Replace with actual user data from your auth system
    _nameController.text = 'John Doe';
    _emailController.text = 'john.doe@example.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
              validator: (value) => Validators.validateRequired(value, 'name'),
            ),
            const SizedBox(height: AppSpacing.s16),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: AppSpacing.s16),
            _buildInquiryTypeDropdown(),
            const SizedBox(height: AppSpacing.s16),
            CustomTextField(
              controller: _subjectController,
              label: 'Subject',
              icon: Icons.subject,
              validator: (value) => Validators.validateRequired(value, 'subject'),
            ),
            const SizedBox(height: AppSpacing.s16),
            CustomTextField(
              controller: _messageController,
              label: 'Message',
              icon: Icons.message,
              maxLines: 5,
              validator: Validators.validateMessage,
            ),
            const SizedBox(height: AppSpacing.s24),
            _buildSubmitButton(),
            const SizedBox(height: AppSpacing.s16),
            const AlternativeContactInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInquiryTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedInquiryType,
      decoration: InputDecoration(
        labelText: 'Inquiry Type',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: InquiryType.types.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedInquiryType = newValue;
          });
        }
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isSubmitting
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Text(
        'Submit',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear form
          _subjectController.clear();
          _messageController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}