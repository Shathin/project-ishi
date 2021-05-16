import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

// ! Third Party libraries
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ! Custom libraries
import 'package:auth_repo/auth_repo.dart';
import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';

// ! File Imports
import 'package:project_ishi/utils/theme/theme.dart';
import 'package:project_ishi/auth/sign_up/sign_up.dart';
import 'package:project_ishi/auth/login/login.dart';

Future<void> main() async {
  // ! Initializing the shared preferences object
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Uncomment to clear shared preferences when required
  // await sharedPreferences.clear();

  // ! Initializing the authentication repository object
  final AuthRepo authRepo = AuthRepo(sharedPreferences: sharedPreferences);

  // ! Initializing the template repository object
  final String templateDbFile = 'template.db';
  final Database templateDatabase = foundation.kIsWeb
      ? await databaseFactoryWeb.openDatabase(templateDbFile)
      : await databaseFactoryIo.openDatabase(templateDbFile);
  final StoreRef templateStore = stringMapStoreFactory.store('template');
  final TemplateRepo templateRepo = TemplateRepo(
    templateDatabase: templateDatabase,
    templateStore: templateStore,
  );

  // ! Initializing the patients repository object
  final String patientsDbFile = 'patients.db';
  final Database patientsDatabase = foundation.kIsWeb
      ? await databaseFactoryWeb.openDatabase(patientsDbFile)
      : await databaseFactoryIo.openDatabase(patientsDbFile);
  final StoreRef patientsStore = stringMapStoreFactory.store('patients');
  final PatientsRepo patientsRepo = PatientsRepo(
    patientsDatabase: patientsDatabase,
    patientsStore: patientsStore,
  );

  // ! Initializing the records repository object
  final String recordsDbFile = 'records.db';
  final Database recordsDatabase = foundation.kIsWeb
      ? await databaseFactoryWeb.openDatabase(recordsDbFile)
      : await databaseFactoryIo.openDatabase(recordsDbFile);
  final StoreRef recordsStore = stringMapStoreFactory.store('records');
  final RecordsRepo recordsRepo = RecordsRepo(
    recordsDatabase: recordsDatabase,
    recordsStore: recordsStore,
    patientsRepo: patientsRepo,
  );

  runApp(ProjectIshi(
    authRepo: authRepo,
    templateRepo: templateRepo,
    patientsRepo: patientsRepo,
    recordsRepo: recordsRepo,
  ));
}

class ProjectIshi extends StatelessWidget {
  final AuthRepo authRepo;
  final TemplateRepo templateRepo;
  final PatientsRepo patientsRepo;
  final RecordsRepo recordsRepo;

  ProjectIshi({
    required this.authRepo,
    required this.templateRepo,
    required this.patientsRepo,
    required this.recordsRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: this.authRepo),
        RepositoryProvider.value(value: this.templateRepo),
        RepositoryProvider.value(value: this.patientsRepo),
        RepositoryProvider.value(value: this.recordsRepo),
      ],
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        lazy: true,
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) => MaterialApp(
            theme: state.themeData,
            home: context.read<AuthRepo>().isFirstTime
                ? SignUpPage()
                : LoginPage(),
          ),
        ),
      ),
    );
  }
}
