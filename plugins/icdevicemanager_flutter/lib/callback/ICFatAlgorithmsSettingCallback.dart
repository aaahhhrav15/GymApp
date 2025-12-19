import 'package:icdevicemanager_flutter/model/data/ICWeightData.dart';

class ICFatAlgorithmsSettingCallback{
  final void Function(ICWeightData data) callBack;
  ICFatAlgorithmsSettingCallback({required this.callBack});
}