import 'package:dumping_system/bloc/auth_bloc.dart';
import 'package:dumping_system/bloc/post_handover_bloc.dart';
import 'package:dumping_system/cubit/handover_cubit.dart';
import 'package:dumping_system/screen/handover%20&%20mixing/bloc/material_set_bloc.dart';
import 'package:dumping_system/screen/scanner%20barcode/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanTongResultsWeighing extends StatefulWidget {
  // ignore: use_super_parameters
  const ScanTongResultsWeighing({Key? key}) : super(key: key);

  @override
  State<ScanTongResultsWeighing> createState() =>
      _ScanTongResultsWeighingScreenState();
}

class _ScanTongResultsWeighingScreenState
    extends State<ScanTongResultsWeighing> {
  AuthBloc authBloc = AuthBloc();
  HandoverCubit _handoverCubit = HandoverCubit();
  SubmitHandoverBloc submitHandoverBloc = SubmitHandoverBloc();
  MaterialSetBloc materialSetBloc = MaterialSetBloc();
  String scannedBarcode = "";
  final line = TextEditingController();

  List<String> parseStringAndWrapInMap(String input) {
    List<String> parts = input.split(';');
    List<String> scanned = [];
    scanned = parts;

    return scanned;
  }

  void _scanOperator(Barcode? barcode) async {
    if (barcode != null && barcode.displayValue != null) {
      setState(() {
        scannedBarcode = barcode.displayValue!;
        _handoverCubit.setScannedTong(parseStringAndWrapInMap(scannedBarcode));
      });
      if (mounted) {
        if (_handoverCubit.state.isChecked) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Data is Scanned"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ));
        }
        if (_handoverCubit.state.isNullData) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Data not found"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
    _handoverCubit = BlocProvider.of<HandoverCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _handoverCubit),
        BlocProvider.value(value: materialSetBloc),
      ],
      child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text(
                "Handover Mixing - ${handoverState.selectedOperationNumber.operationDesc} (${handoverState.selectedOperationNumber.activityNo})"),
            leading: BackButton(
              onPressed: () {
                _handoverCubit.setTab(HandoverStatus.handover);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 20, left: 10, right: 10),
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
                            Text(
                              "ActivityWh",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            )
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
                                handoverState.selectedOperation.material != null
                                    ? '(${handoverState.selectedOperation.material}) ${handoverState.selectedOperation.materialDesc}'
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
                                handoverState.selectedOperation.orderNo != null
                                    ? handoverState.selectedOperation.orderNo!
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
                                handoverState.selectedOperation.batchFG != null
                                    ? handoverState.selectedOperation.batchFG!
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
                                handoverState.selectedOperationNumber
                                            .activityNo !=
                                        null
                                    ? handoverState
                                        .selectedOperationNumber.activityNo!
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
                                handoverState.selectedOperationNumber
                                            .operationDesc !=
                                        null
                                    ? handoverState
                                        .selectedOperationNumber.operationDesc!
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
                                handoverState.tongs.isNotEmpty
                                    ? handoverState.tongs[0].activityNo!
                                    : '',
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
                  _listTong(context, handoverState)
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
                child: handoverState.isComplete
                    ? TextButton(
                        onPressed: () {
                          submitHandoverBloc
                              .add(SubmitHandover(orderData: handoverState));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Complete",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ScanBarcodeScreen(
                                onBarcodeScanned: (barcode) {
                                  _scanOperator(barcode);
                                },
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Scan Barcode Label",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _listTong(BuildContext context, HandoverState handoverState) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _handoverCubit,
        ),
      ],
      child: BlocBuilder<HandoverCubit, HandoverState>(
          builder: (context, handoverState) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Text(
                    "Scan Containers",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(endIndent: 10, indent: 10),
                for (var fullpack in handoverState.fullpack) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            '${fullpack.materialDesc} ${fullpack.counter}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (fullpack.isScannedFullpack == true) ...[
                          const Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        ]
                      ],
                    ),
                  ),
                  const Divider(
                    endIndent: 10,
                    indent: 10,
                  ),
                ]
              ],
            ),
          ),
        );
      }),
    );
  }
}
