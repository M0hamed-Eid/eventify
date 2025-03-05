import 'package:flutter/material.dart';
import '../services/database_service.dart';


class DatabaseProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  DatabaseService get database => _databaseService;
}