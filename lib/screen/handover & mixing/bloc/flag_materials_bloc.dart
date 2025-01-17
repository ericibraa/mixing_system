import 'package:bloc/bloc.dart';
import 'package:dumping_system/models/request/flag_materials.dart';
import 'package:dumping_system/models/response/error.dart';
import 'package:dumping_system/repository/flag_scan_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'flag_materials_event.dart';
part 'flag_materials_state.dart';

class FlagMaterialsBloc extends Bloc<FlagMaterialsEvent, FlagMaterialsState> {
  final FlagScanRepository _flagScanRepository = FlagScanRepository();
  FlagMaterialsBloc() : super(FlagMaterialsInitial()) {
    on<GetFlagMaterials>((event, emit) async {
      emit(FlagMaterialsLoading());
      try {
        String activityNo = '';
        String activityWh = '';
        String bOmItem = '';
        String batch = '';
        String fullpackItem = '';
        String materialNo = '';
        String orderNo = '';
        String recipient = '';
        String wadah = '';
        String originalOrder = '';
        switch (event.flagMaterials.length) {
          case 10:
            orderNo = event.flagMaterials[1];
            activityNo = event.flagMaterials[2];
            bOmItem = event.flagMaterials[3];
            materialNo = event.flagMaterials[4];
            recipient = event.flagMaterials[7];
            fullpackItem = event.flagMaterials[6].toString().split("/")[0];
            batch = event.flagMaterials[8];
            activityWh = activityWh;
            wadah = wadah;
            originalOrder = event.orderNo;
            break;
          case 9:
            orderNo = event.flagMaterials[1];
            activityNo = event.flagMaterials[2];
            bOmItem = event.flagMaterials[3];
            materialNo = event.flagMaterials[4];
            recipient = event.flagMaterials[7];
            fullpackItem = event.flagMaterials[6].toString().split("/")[0];
            batch = event.flagMaterials[8];
            activityWh = activityWh;
            wadah = wadah;
            originalOrder = event.orderNo;
            break;
          case 6:
            orderNo = event.flagMaterials[1];
            activityNo = event.flagMaterials[2];
            bOmItem = event.flagMaterials[3];
            materialNo = event.flagMaterials[4];
            recipient = "W";
            fullpackItem = fullpackItem;
            batch = fullpackItem;
            activityWh = activityWh;
            wadah = wadah;
            originalOrder = event.orderNo;
            break;
          case 7:
            orderNo = event.flagMaterials[0];
            activityNo = event.flagMaterials[2];
            bOmItem = bOmItem;
            materialNo = materialNo;
            recipient = recipient;
            fullpackItem = fullpackItem;
            batch = fullpackItem;
            activityWh = event.flagMaterials[6];
            wadah = event.flagMaterials[5].toString().split("/")[0];
            originalOrder = event.orderNo;

            break;
        }

        FlagMaterials flagMaterials = FlagMaterials(
          activityNo: activityNo,
          activityWh: activityWh,
          bOMItem: bOmItem,
          batch: batch,
          fullpackItem: fullpackItem,
          materialNo: materialNo,
          orderNo: orderNo,
          recipient: recipient,
          wadah: wadah,
          originalOrder: originalOrder
        );
        final flagMaterial =
            await _flagScanRepository.fetchSubmitFlag(flagMaterials);
        emit(FlagMaterialsSuccess(flagMaterial));
      } on ErrorResponse catch (e) {
        if (e.error != null && e.error!.message != null) {
          emit(FlagMaterialsError(e.error!.message!.value!));
        } else {
          emit(const FlagMaterialsError('Server Error'));
        }
      } on Exception catch (e) {
        emit(FlagMaterialsError(e.toString()));
      }
    });
  }
}
