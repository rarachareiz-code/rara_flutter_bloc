import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repository/item_repository.dart';
import 'cubit/item_cubit.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = ItemRepository();

  runApp(
    // BlocProvider is above MaterialApp, so ItemCubit is accessible anywhere
    BlocProvider(
      create: (_) => ItemCubit(repository: repository),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cubit + Persistence Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}
