import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/confirmation/bloc/submit_bloc.dart';
import 'package:dumping_system/screen/confirmation/cubit/confirmation_cubit.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FormConfirmationScreen extends StatefulWidget {
  const FormConfirmationScreen({super.key});

  @override
  State<FormConfirmationScreen> createState() => _FormConfirmationScreenState();
}

class _FormConfirmationScreenState extends State<FormConfirmationScreen> {
  AuthBloc authBloc = AuthBloc();
  ConfirmationCubit _confirmationCubit = ConfirmationCubit();
  SubmitBloc submitBloc = SubmitBloc();
  final line = TextEditingController();
  String scannedBarcode = '';
  final yield = TextEditingController();
  final machineTime = TextEditingController();
  final laborTime = TextEditingController();
  final startExecution = TextEditingController();
  final finishExecution = TextEditingController();
  final postingDate = TextEditingController();
  final numberOfLabor = TextEditingController();
  // final reason = TextEditingController();
  var laborTimeValue = 0.0;

  @override
  void initState() {
    authBloc = BlocProvider.of<AuthBloc>(context);
    _confirmationCubit = BlocProvider.of<ConfirmationCubit>(context);
    numberOfLabor.text = '1';
    super.initState();
  }

  void scanLine(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
      line.text = scannedBarcode;
      _confirmationCubit.setLine(line.text);
      _confirmationCubit.setStartDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _confirmationCubit,
        ),
        BlocProvider(create: (context) => submitBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ConfirmationCubit, ConfirmationState>(
              listener: (context, state) {
            if (state.tab == ConfirmationStatus.formConfirmation) {
              String date = state.yieldSet.startDateOpr;
              DateTime? parsedDate = DateTime.parse(date);
              String hours = state.yieldSet.startTimeOpr.substring(0, 2);
              String minutes = state.yieldSet.startTimeOpr.substring(2, 4);
              String seconds = state.yieldSet.startTimeOpr.substring(4, 6);
              yield.text = state.yieldSet.yieldQty;
              machineTime.text = state.yieldSet.machineHour;
              laborTime.text = state.yieldSet.laborHour;
              startExecution.text =
                  '${DateFormat('dd-MM-yyyy').format(parsedDate)} $hours:$minutes:$seconds';
              postingDate.text =
                  DateFormat('dd-MM-yyyy').format(DateTime.now());
            }
          }),
          BlocListener<SubmitBloc, SubmitState>(listener: (context, state) {
            switch (state) {
              case SubmitSuccess():
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text("Saved Successfully"),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
                context.go('/home');
                break;
              case SubmitError():
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ));
                break;
            }
          })
        ],
        child: BlocBuilder<ConfirmationCubit, ConfirmationState>(
          builder: (context, confirmationState) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Confirmation"),
                  leading: IconButton(
                    onPressed: () {
                      _confirmationCubit
                          .setTab(ConfirmationStatus.chooseOperation);
                      numberOfLabor.text = '1';
                    },
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 10, right: 10),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Material",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                Text(
                                  "Process order",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                Text(
                                  "Batch",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                Text(
                                  "Operation No",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                Text(
                                  "Operation text",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    confirmationState.selectedOrder.material !=
                                            null
                                        ? '(${confirmationState.selectedOrder.material}) ${confirmationState.selectedOrder.materialDesc}'
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    confirmationState.selectedOrder.orderNo !=
                                            null
                                        ? confirmationState
                                            .selectedOrder.orderNo!
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    confirmationState.selectedOrder.batchFG !=
                                            null
                                        ? confirmationState
                                            .selectedOrder.batchFG!
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    confirmationState
                                        .selectedOperation.activityNo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    confirmationState
                                        .selectedOperation.operationDesc,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextFormField(
                          controller: line,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ScanBarcodeScreen(
                                  onBarcodeScanned: (barcode) {
                                    scanLine(barcode);
                                  },
                                ),
                              ),
                            );
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Scan Line',
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              suffixIcon:
                                  const Icon(Icons.qr_code_scanner_rounded)),
                          readOnly: true,
                        ),
                      ),
                      _formConfirmation(context)
                    ],
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  elevation: 10,
                  color: Colors.transparent,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: confirmationState.isComplete
                            ? TextButton(
                                onPressed: () {
                                  context.go("/home");
                                  _confirmationCubit.setComplete(false);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Back To Home",
                                  style: TextStyle(color: Colors.white),
                                ))
                            : TextButton(
                                onPressed: line.text.isNotEmpty
                                    ? () {
                                        submitBloc.add(SubmitConfirmation(
                                            confirmationState));
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  backgroundColor: line.text.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Confirm",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                ),
                              )),
                  ),
                ));
          },
        ),
      ),
    );
  }

  Widget _formConfirmation(BuildContext context) {
    return BlocBuilder<ConfirmationCubit, ConfirmationState>(
      builder: (context, confirmationState) {
        return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Form(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: yield,
                  readOnly: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Yield',
                      filled: true,
                      fillColor: Colors.grey[350],
                      suffix: Text(confirmationState.yieldSet.unitYield)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: machineTime,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    var data = _confirmationCubit.state.yieldSet;

                    laborTimeValue =
                        double.parse(value) * double.parse(numberOfLabor.text);

                    _confirmationCubit.setYieldSet(data.copyWith(
                        machineHour: value,
                        laborHour: laborTimeValue.toStringAsFixed(3)));
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.access_time_rounded),
                    labelText: 'Machine Time',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: laborTime,
                  keyboardType: TextInputType.number,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.access_time_rounded),
                    labelText: 'Labor Time',
                    filled: true,
                    fillColor: Colors.grey[350],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: numberOfLabor,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    var data = _confirmationCubit.state.yieldSet;

                    laborTimeValue =
                        double.parse(data.machineHour) * double.parse(value);
                    print(laborTime);

                    _confirmationCubit.setYieldSet(data.copyWith(
                        laborHour: laborTimeValue.toStringAsFixed(3)));
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.access_time_rounded),
                    labelText: 'Number Of Labor',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: startExecution,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                    labelText: 'Start Execution',
                    filled: true,
                    fillColor: Colors.grey[400],
                  ),
                  readOnly: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: postingDate,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                    labelText: 'Posting Date',
                    filled: true,
                    fillColor: Colors.grey[400],
                  ),
                  readOnly: true,
                ),
              ),
              // Padding(
              //     padding: const EdgeInsets.only(bottom: 20),
              //     child: TextFormField(
              //       maxLines: null,
              //       controller: reason,
              //       keyboardType:
              //           TextInputType.multiline, // Enables multi-line input
              //       decoration: InputDecoration(
              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //         labelText: 'Reason (Optional)',
              //       ),
              //     ))
            ])));
      },
    );
  }
}
