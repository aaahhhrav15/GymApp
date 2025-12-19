enum ICWUploadEvent {
  initSDK("InitSDK"),
  onBleState("onBleState"),
  onNodeConnectionChanged("onNodeConnectionChanged"),
  onDeviceConnectionChanged("onDeviceConnectionChanged"),

  onReceiveHrData("onReceiveHrData"),
  onReceiveSkipData("onReceiveSkipData"),
  onReceiveRulerData("onReceiveRulerData"),
  onReceiveCoordData("onReceiveCoordData"),
  onReceiveDebugData("onReceiveDebugData"),
  onReceiveWeightData("onReceiveWeightData"),
  onReceiveMeasureStepData("onReceiveMeasureStepData"),
  onReceiveHistorySkipData("onReceiveHistorySkipData"),
  onReceiveRulerHistoryData("onReceiveRulerHistoryData"),
  onReceiveWeightCenterData("onReceiveWeightCenterData"),
  onReceiveKitchenScaleData("onReceiveKitchenScaleData"),

  onReceiveRulerUnitChanged("onReceiveRulerUnitChanged"),
  onReceiveWeightHistoryData("onReceiveWeightHistoryData"),
  onReceiveWeightUnitChanged("onReceiveWeightUnitChanged"),
  onReceiveKitchenScaleUnitChanged("onReceiveKitchenScaleUnitChanged"),
  onReceiveRulerMeasureModeChanged("onReceiveRulerMeasureModeChanged"),

  onReceiveBattery("onReceiveBattery"),
  onReceiveDeviceInfo("onReceiveDeviceInfo"),
  onReceiveSkipBattery("onReceiveSkipBattery"),
  onReceiveUpgradePercent("onReceiveUpgradePercent"),
  onReceiveConfigWifiResult("onReceiveConfigWifiResult"),

  onScanResult("onScanResult"),
  onSettingCallBack("onSettingCallBack"),
  onAddDeviceCallBack("onAddDeviceCallBack"),
  onRemoveDeviceCallBack("onRemoveDeviceCallBack");

  final String value;

  const ICWUploadEvent(this.value);

  String getValue() {
    return value;
  }
}
