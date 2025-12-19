

import 'package:icdevicemanager_flutter/model/converter/ICSkipFreqDataConverter.dart';
import 'package:icdevicemanager_flutter/model/data/ICSkipFreqData.dart';
import 'package:json_annotation/json_annotation.dart';

import '../other/ICConstant.dart';




part 'ICSkipData.g.dart';

@JsonSerializable()
class ICSkipData{
  /**
      是否稳定
   */
   bool isStabilized=false;

  /**
      节点ID
   */
   int nodeId=0;
  /**
      节点电量
   */
   int battery=0;
  /**
      节点信息
   */
   int nodeInfo=0;

  /**
   * 测量时间，单位:秒
   */
   int time = 0;

  /**
   * 跳绳模式
   */
   ICSkipMode mode = ICSkipMode.ICSkipModeFreedom;

  /**
   * 设置的参数
   */
   int setting = 0;

  /**
   * 跳绳使用的时间
   */
   int elapsed_time = 0;

  /**
   * 跳绳实际使用的时间，不是所有都支持
   */
   int actual_time = 0;

  /**
   * 跳的次数
   */
   int skip_count = 0;

  /**
   * 平均频次
   */
   int avg_freq = 0;

  /**
   * 最快频次
   */
   int fastest_freq = 0;


  /**
   * 绊绳总数
   */
   int  freq_count = 0;

  /**
   * 最多连跳
   */
   int  most_jump = 0;



  /**
   * 热量消耗
   */
   double calories_burned = 0;

  /**
   * 燃脂效率
   */
   double fat_burn_efficiency = 0;


  /**
   * 跳绳频次数据
   */
   @ICSkipFreqDataConverter()
   List<ICSkipFreqData>? freqs = [];

   ICSkipData();

   factory ICSkipData.fromJson(Map<String, dynamic> json) => _$ICSkipDataFromJson(json);

   Map<String, dynamic> toJson() => _$ICSkipDataToJson(this);

   @override
  String toString() {
    return 'ICSkipData{isStabilized: $isStabilized, nodeId: $nodeId, battery: $battery, nodeInfo: $nodeInfo, time: $time, mode: $mode, setting: $setting, elapsed_time: $elapsed_time, actual_time: $actual_time, skip_count: $skip_count, avg_freq: $avg_freq, fastest_freq: $fastest_freq, freq_count: $freq_count, most_jump: $most_jump, calories_burned: $calories_burned, fat_burn_efficiency: $fat_burn_efficiency, freqs: $freqs}';
  }
}