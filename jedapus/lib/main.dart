import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'presentation/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qslrghxupjzmaghylddo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzbHJnaHh1cGp6bWFnaHlsZGRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4MzM5MzgsImV4cCI6MjA2NjQwOTkzOH0.6OjoJzcZzBy-FAoggZ8V0_lvxnP-OTxJYqK5BffvP2A'
   );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CutiProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
      ],
      child: const JedapusApp(),
    ),
  );
}
