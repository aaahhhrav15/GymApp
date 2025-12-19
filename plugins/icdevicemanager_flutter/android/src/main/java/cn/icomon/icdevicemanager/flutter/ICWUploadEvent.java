package cn.icomon.icdevicemanager.flutter;





class   ICWUploadEvent {

     static   String TypeInitSDK = "InitSDK";

     static   String TypeUpgrade = "onReceiveUpgradePercent";
     static   String TypeBattery = "onReceiveBattery";
     static   String TypeConfigWifi = "onReceiveConfigWifiResult";
     static   String TypeDeviceScan = "onScanResult";

     static   String TypeSettingResult = "onSettingCallBack";
     static   String TypeAddDeviceResult = "onAddDeviceCallBack";
     static   String TypeRemoveDeviceResult = "onRemoveDeviceCallBack";

     static   String TypeBluetoothChange = "onBleState";

     static   String TypeScaleData = "onReceiveWeightData";
     static   String TypeCoordData = "onReceiveCoordData";
     static   String TypeScaleStepData = "onReceiveMeasureStepData";
     static   String TypeScaleCenterData = "onReceiveWeightCenterData";
     static   String TypeScaleHistoryData = "onReceiveWeightHistoryData";
     static   String TypeScaleUnitChange = "onReceiveWeightUnitChanged";

     static   String TypeRulerData = "onReceiveRulerData";
     static   String RulerHistoryData = "onReceiveRulerHistoryData";
     static   String TypeRulerUnitChange = "onReceiveRulerUnitChanged";
     static   String TypeRulerModeChange = "onReceiveRulerMeasureModeChanged";


     static   String TypeKitchenData = "onReceiveKitchenScaleData";

     static   String TypeSkipData = "onReceiveSkipData";
     static   String TypeDeviceInfo = "onReceiveDeviceInfo";
     static   String TypeSkipBattery = "onReceiveSkipBattery";
     static   String TypeSkipHistoryData = "onReceiveHistorySkipData";
     static   String TypeHrData = "onReceiveHrData";
     static   String TypeDebugData = "TypeDebugData";





     static   String TypeConnectChange = "onDeviceConnectionChanged";
     static   String onNodeConnectionChanged = "onNodeConnectionChanged";

    
     static   String KitchenScaleUnitChanged = "onReceiveKitchenScaleUnitChanged";


}
