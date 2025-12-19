
import 'package:icdevicemanager_flutter/model/other/ICConstant.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ICSkipSoundSettingData.g.dart';

@JsonSerializable()
class ICSkipSoundSettingData {
  /*
      是否开启语音开关
     */
  bool soundOn = false;

  /*
      语音类型
      */
  ICSkipSoundType soundType = ICSkipSoundType.ICSkipSoundTypeFemale;

  /*
     声音大小
     */
  int soundVolume = 0;

  /*
     满分开关
     */
  bool fullScoreOn = false;

  /*
     满分速率
     */
  int fullScoreBPM = 0;

  /*
     语音间隔模式
     */
  ICSkipSoundMode soundMode = ICSkipSoundMode.ICSkipSoundModeCount;

  /*
    模式参数
     */
  int modeParam = 0;

  /*
    是否自动停止播放，true:APP下发开始后，跳绳不会播放语音 ，false:跳绳和APP都会播放语音
     */
  bool isAutoStop = false;

  ICSkipSoundSettingData();


  factory ICSkipSoundSettingData.fromJson(Map<String, dynamic> json) => _$ICSkipSoundSettingDataFromJson(json);

  Map<String, dynamic> toJson() => _$ICSkipSoundSettingDataToJson(this);
}
