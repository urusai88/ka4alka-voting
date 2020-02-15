import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ka4alka_voting/blocs/application/application.dart';
import 'package:ka4alka_voting/blocs/application/application_bloc.dart';
import 'package:ka4alka_voting/blocs/screen/screen.dart';
import 'package:ka4alka_voting/domain.dart';
import 'package:ka4alka_voting/screens/screens.dart';
import 'package:ka4alka_voting/simple_bloc_delegate.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(HumanAdapter());
  Hive.registerAdapter(VotingAdapter());
  Hive.registerAdapter(VoteAdapter());
  Hive.registerAdapter(ImageSourceBase64Adapter());

  BlocSupervisor.delegate = SimpleBlocDelegate();

  runApp(BlocProvider(
    create: (context) => ScreenBloc(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ApplicationBloc()..add(ApplicationLoad()),
        ),
      ],
      child: MaterialApp(home: HomeScreen()),
    );
  }
}
