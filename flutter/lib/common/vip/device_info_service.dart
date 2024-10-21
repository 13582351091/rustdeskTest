// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'platform.dart';

class DeviceInfoService {
  const DeviceInfoService({
    required DeviceInfoPlugin plugin,
  }) : _plugin = plugin;

  final DeviceInfoPlugin _plugin;

  //TODO: support other platforms
  Future<DeviceInfo> getDeviceInfo() async {
    if (isAndroid()) {
      return DeviceInfo(androidDeviceInfo: await _plugin.androidInfo);
    } else if (isIOS()) {
      return DeviceInfo(iosDeviceInfo: await _plugin.iosInfo);
    }
    else if(isWindows()){
      return DeviceInfo(windowsDeviceInfo: await _plugin.windowsInfo);
    }
    else if(isMacOS()){
      return DeviceInfo(macOSDeviceInfo: await _plugin.macOsInfo);
    }
    else {
      return DeviceInfo.empty();
    }
  }


  Future<String?> getDeviceId() async{
    final deviceInfo =
    await DeviceInfoService(plugin: DeviceInfoPlugin()).getDeviceInfo();
    if (isAndroid() ) {
      return deviceInfo.androidDeviceInfo?.id;
    } else if (isIOS()) {
      return deviceInfo.iosDeviceInfo?.identifierForVendor;
    }
    else if(isWindows()){
      return deviceInfo.windowsDeviceInfo?.computerName;
    }
    else if(isMacOS()){
      return deviceInfo.macOSDeviceInfo?.systemGUID;//ȫ��Ψһ��ʶ����


    }
    else {
      return Future.error('cannot get device id for unknown platform');
    }
  }



}

class DeviceInfo extends Equatable {
  const DeviceInfo({
    this.androidDeviceInfo,
    this.iosDeviceInfo,
    this.windowsDeviceInfo,
    this.macOSDeviceInfo,
  });

  factory DeviceInfo.empty() => const DeviceInfo();

  final AndroidDeviceInfo? androidDeviceInfo;
  final IosDeviceInfo? iosDeviceInfo;
  final WindowsDeviceInfo? windowsDeviceInfo;
  final MacOsDeviceInfo? macOSDeviceInfo;

  @override
  List<Object?> get props => [androidDeviceInfo, iosDeviceInfo,windowsDeviceInfo,macOSDeviceInfo];
}
