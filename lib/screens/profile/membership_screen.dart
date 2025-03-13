import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  _MembershipScreenState createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  // Membership URLs
  final String membershipInfoUrl = 'https://eg.usembassy.gov/education/american-spaces/';
  final String membershipFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSeoSXplrCmySpzAKyJHDAasyPUsr_l1Q6G0BqxzCgITKPTegw/viewform';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACC Membership'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Membership Overview
            _buildSectionTitle('Membership Overview'),
            _buildInfoCard(),

            // Membership Benefits
            _buildSectionTitle('Membership Benefits'),
            _buildBenefitsList(),

            // Action Buttons
            const SizedBox(height: 20),
            _buildActionButtons(),

            // Contact Information
            _buildSectionTitle('Contact Us'),
            _buildContactInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ACC Membership',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Free membership for residents in Egypt\n'
                  '• Open to individuals aged 16 and above\n'
                  '• Valid until December 31, 2027\n'
                  '• Access to digital and physical resources',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBenefitItem('OverDrive Digital Library Access'),
            _buildBenefitItem('eLibraryUSA Databases'),
            _buildBenefitItem('Streaming Films'),
            _buildBenefitItem('Online Courses'),
            _buildBenefitItem('Members-only Programs'),
            _buildBenefitItem('Book and Media Borrowing'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.assignment),
          label: const Text('Apply for Membership'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _launchMembershipForm(),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          icon: const Icon(Icons.info_outline),
          label: const Text('Membership Details'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue[900],
            side: BorderSide(color: Colors.blue[900]!),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _launchMembershipInfo(),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactRow(
              Icons.location_on,
              '5 Tawfik Diab Street, Garden City, Cairo, Egypt',
            ),
            _buildContactRow(
              Icons.phone,
              '(20-2) 2797-3133',
            ),
            _buildContactRow(
              Icons.email,
              'ACCairo@state.gov',
            ),
            _buildContactRow(
              Icons.access_time,
              'Monday-Thursday, 10:00 AM - 4:00 PM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[900], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMembershipForm() async {
    try {
      final Uri url = Uri.parse(membershipFormUrl);

      // Check if the URL can be launched
      if (await canLaunchUrl(url)) {
        // Attempt to launch the URL
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // If URL cannot be launched, show a detailed error
        _showLaunchErrorDialog(
          'Unable to open the membership form. The link may be invalid or your device cannot handle this type of URL.',
        );
      }
    } catch (e) {
      // Catch any unexpected errors during URL launching
      _showLaunchErrorDialog(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  void _showLaunchErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unable to Open Link'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copyUrlToClipboard();
            },
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  void _copyUrlToClipboard() {
    // Implement clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Membership form URL copied to clipboard'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            // You can add a fallback method to open URL
            _openUrlManually();
          },
        ),
      ),
    );
  }

  void _openUrlManually() {
    // Fallback method to open URL manually
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Membership Form'),
        content: Text(membershipFormUrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _launchMembershipInfo() async {
    final Uri url = Uri.parse(membershipInfoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorDialog('Could not launch membership information');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Optional: Membership Form WebView for in-app experience
class MembershipFormWebView extends StatefulWidget {
  final String formUrl;

  const MembershipFormWebView({
    super.key,
    required this.formUrl,
  });

  @override
  _MembershipFormWebViewState createState() => _MembershipFormWebViewState();
}

class _MembershipFormWebViewState extends State<MembershipFormWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.formUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Application')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}