import 'package:hive_ce/hive.dart';

class ChannelVariables extends HiveObject {
  String channelName;
  String greeting;
  String audience;
  String style;
  String avoid;
  String avgDuration;

  ChannelVariables({
    this.channelName = '',
    this.greeting = '',
    this.audience = '',
    this.style = '',
    this.avoid = '',
    this.avgDuration = '',
  });

  bool get isEmpty =>
      channelName.isEmpty &&
      greeting.isEmpty &&
      audience.isEmpty &&
      style.isEmpty &&
      avoid.isEmpty &&
      avgDuration.isEmpty;

  Map<String, dynamic> toBackupJson() => {
        'channelName': channelName,
        'greeting': greeting,
        'audience': audience,
        'style': style,
        'avoid': avoid,
        'avgDuration': avgDuration,
      };

  factory ChannelVariables.fromBackupJson(Map<String, dynamic> json) =>
      ChannelVariables(
        channelName: (json['channelName'] as String?) ?? '',
        greeting: (json['greeting'] as String?) ?? '',
        audience: (json['audience'] as String?) ?? '',
        style: (json['style'] as String?) ?? '',
        avoid: (json['avoid'] as String?) ?? '',
        avgDuration: (json['avgDuration'] as String?) ?? '',
      );
}
