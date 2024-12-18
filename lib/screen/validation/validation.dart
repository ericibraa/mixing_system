import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/models/response/validation.dart';
import 'package:dumping_system/provider/submit_handover_provider.dart';
import 'package:dumping_system/screen/login/login.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:dumping_system/screen/validation/bloc/validation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ValidationScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const ValidationScreen({Key? key}) : super(key: key);

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  AuthBloc authBloc = AuthBloc();
  late ValidationBloc validationBloc;
  Results validations = Results();
  String scannedBarcode = "";
  List<String> hasScanned = [];
  String valueOperator = '';
  String valuePengawas = '';

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    validationBloc = ValidationBloc();
    var data = authBloc.state;
    if (data is Authenticated) {
      valueOperator = data.nrpOperator;
      valuePengawas = data.nrpPengawas;
    }
    super.initState();
  }

  List<String> parseStringAndWrapInMap(String input) {
    List<String> parts = input.split(';');
    return parts;
  }

  void _scanOperator(Barcode? barcode, String title) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
      hasScanned = parseStringAndWrapInMap(scannedBarcode);
      if (title == 'OPERATOR') {
        await storage.write(key: 'nameOperator', value: hasScanned[1]);
      } else {
        await storage.write(key: 'namePengawas', value: hasScanned[1]);
      }
      validationBloc.add(SendValidation(
          nrp: hasScanned[0], name: hasScanned[1], title: title));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          if (state.token.isNotEmpty) {
            return validationBody(context);
          }
        }
        return const LoginScreen();
      },
    );
  }

  Widget validationBody(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => validationBloc,
        child: MultiBlocListener(
          listeners: [
            BlocListener<ValidationBloc, ValidationState>(
              listener: (context, state) {
                if (state is ValidationLoaded) {
                  if (state.validation.d!.results!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text("Invalid Operator"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )));
                  } else {
                    for (var valDate in state.validation.d!.results!) {
                      validations = valDate;
                    }
                    if (validations.title == 'OPERATOR') {
                      BlocProvider.of<AuthBloc>(context).add(ChangeUserEvent(
                          nrpOperator: hasScanned[0],
                          nameOperator: hasScanned[1],
                          weerks: validations.werks));
                    } else {
                      BlocProvider.of<AuthBloc>(context).add(ChangeUserEvent(
                          nrpPengawas: hasScanned[0],
                          namePengawas: hasScanned[1]));
                    }
                  }
                } else if (state is ValidationError) {
                  print("kesini error");
                }
              },
            ),
            BlocListener<AuthBloc, AuthState>(listener: (context, state) {
              if (state is Authenticated) {
                setState(() {
                  valueOperator = state.nrpOperator;
                  valuePengawas = state.nrpPengawas;
                });
              }
            })
          ],
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 200, bottom: 70),
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/logo/mixing_system.png",
                      fit: BoxFit.cover,
                      width: 270,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScanBarcodeScreen(
                            onBarcodeScanned: (barcode) =>
                                _scanOperator(barcode, "OPERATOR"),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 1.5),
                      padding: const EdgeInsets.only(
                          left: 20, top: 25, right: 20, bottom: 25),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(valueOperator.isNotEmpty
                                ? 'NRP $valueOperator'
                                : 'OPERATOR'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScanBarcodeScreen(
                            onBarcodeScanned: (barcode) =>
                                _scanOperator(barcode, "PENGAWAS"),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 1.5),
                      padding: const EdgeInsets.only(
                          left: 20, top: 25, right: 20, bottom: 25),
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.supervisor_account_rounded,
                            size: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(valuePengawas.isNotEmpty
                                ? 'NRP $valuePengawas'
                                : 'PENGAWAS'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor:
                  valueOperator.isNotEmpty && valuePengawas.isNotEmpty
                      ? Colors.black
                      : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size.fromHeight(50)),
          onPressed: valueOperator.isNotEmpty && valuePengawas.isNotEmpty
              ? () {
                  context.push('/home');
                }
              : null,
          child: Text(
            "Masuk",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.merge(const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
