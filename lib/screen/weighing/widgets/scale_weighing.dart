import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:dumping_system/screen/weighing/cubit/weighing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScaleWeighingScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const ScaleWeighingScreen({Key? key}) : super(key: key);

  @override
  State<ScaleWeighingScreen> createState() => _ScaleWeighingScreenState();
}

class _ScaleWeighingScreenState extends State<ScaleWeighingScreen> {
  AuthBloc authBloc = AuthBloc();
  WeighingCubit weighingCubit = WeighingCubit();
  final temperature = TextEditingController();
  final moistureContent = TextEditingController();
  final numberOfContainer = TextEditingController();
  final scale = TextEditingController();
  final bruto = TextEditingController();
  final tara = TextEditingController();
  final netto = TextEditingController();
  String scannedBarcode = '';

  void _scanBarcode(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Scale Weighing"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Material",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        Text(
                          "Process order",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        Text(
                          "Batch",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        Text(
                          "Operation No",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                        Text(
                          "Operation text",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         handoverState.selectedOperation.material !=
                    //                 null
                    //             ? '(${handoverState.selectedOperation.material}) ${handoverState.selectedOperation.materialDesc}'
                    //             : '',
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium
                    //             ?.copyWith(
                    //               color: Colors.black87,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //       ),
                    //       Text(
                    //         handoverState.selectedOperation.orderNo !=
                    //                 null
                    //             ? handoverState
                    //                 .selectedOperation.orderNo!
                    //             : '',
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium
                    //             ?.copyWith(
                    //               color: Colors.black87,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //       ),
                    //       Text(
                    //         handoverState.selectedOperation.batchFG !=
                    //                 null
                    //             ? handoverState
                    //                 .selectedOperation.batchFG!
                    //             : '',
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium
                    //             ?.copyWith(
                    //               color: Colors.black87,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //       ),
                    //       Text(
                    //         handoverState.selectedOperationNumber
                    //                     .activityNo !=
                    //                 null
                    //             ? handoverState
                    //                 .selectedOperationNumber.activityNo!
                    //             : '',
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium
                    //             ?.copyWith(
                    //               color: Colors.black87,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //       ),
                    //       Text(
                    //         handoverState.selectedOperationNumber
                    //                     .operationDesc !=
                    //                 null
                    //             ? handoverState.selectedOperationNumber
                    //                 .operationDesc!
                    //             : '',
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium
                    //             ?.copyWith(
                    //               color: Colors.black87,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              _formWeighing(context)
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () {
                  print("Complete");
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Get Weight",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              )),
        ),
      ),
    );
  }

  Widget _formWeighing(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Form(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: temperature,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Temperature',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: moistureContent,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Moisture Content',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: numberOfContainer,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Number Of Container',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: scale,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Scale',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ScanBarcodeScreen(
                                onBarcodeScanned: (barcode) {
                                  _scanBarcode(barcode);
                                },
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.qr_code_scanner_rounded),
                      )),
                  readOnly: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: bruto,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Bruto',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  readOnly: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: tara,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Tara',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: netto,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Netto',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  readOnly: true,
                ),
              ),
            ],
          ),
        ));
  }
}
