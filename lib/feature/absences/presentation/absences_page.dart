import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';
import 'package:registro_elettronico/core/infrastructure/navigator.dart';
import 'package:registro_elettronico/feature/web/presentation/spaggiari_web_view.dart';
import 'package:registro_elettronico/utils/constants/registro_constants.dart';

import 'absences_list.dart';
import 'bloc/absences_bloc.dart';

class AbsencesPage extends StatefulWidget {
  const AbsencesPage({Key? key}) : super(key: key);

  @override
  _AbsencesPageState createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<AbsencesBloc>(context).add(GetAbsences());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('absences')!),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: AppLocalizations.of(context)!
                .translate('open_libretto_web'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SpaggiariWebView(
                    appBarTitle: AppLocalizations.of(context)!
                        .translate('open_libretto_web'),
                    url: RegistroConstants.CLASSEVIVA_WEB_LOGIN,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<AbsencesBloc, AbsencesState>(
        listener: (context, state) {
          if (state is AbsencesLoadErrorNotConnected) {
            ScaffoldMessenger.of(context).showSnackBar(
              AppNavigator.instance!.getNetworkErrorSnackBar(context),
            );
          }
        },
        child: AbsencesList(),
      ),
    );
  }
}
