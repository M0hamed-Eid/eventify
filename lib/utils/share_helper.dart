import '../models/event.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  static Future<void> shareEvent(Event event) async {
    final String shareText = '''
      ${event.title}
      Date: ${event.dateTime}
      Location: ${event.location}
      
      Join us for this amazing event!
    ''';

    await Share.share(shareText);
  }
}