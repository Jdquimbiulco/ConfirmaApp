import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Interfaces del dominio
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/event_repository.dart';
import 'domain/repositories/attendance_repository.dart';
import 'domain/repositories/enrollment_repository.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Implementaciones de Firebase
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/firebase_event_repository.dart';
import 'data/repositories/firebase_attendance_repository.dart';
import 'data/repositories/firebase_enrollment_repository.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/viewmodels/login_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Inyectando Repositorios reales de Firebase
        Provider<AuthRepository>(create: (_) => FirebaseAuthRepository()),
        Provider<EventRepository>(create: (_) => FirebaseEventRepository()),
        Provider<AttendanceRepository>(create: (_) => FirebaseAttendanceRepository()),
        Provider<EnrollmentRepository>(create: (_) => FirebaseEnrollmentRepository()),
        
        // Inyectando ViewModels
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Asistencia Eventos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
