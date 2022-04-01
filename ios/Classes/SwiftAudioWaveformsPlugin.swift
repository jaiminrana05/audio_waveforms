import Flutter
import UIKit

public class SwiftAudioWaveformsPlugin: NSObject, FlutterPlugin {
    
    final var audioWaveformsMethodCall = AudioWaveformsMethodCall()
    
    struct Constants {
        static let methodChannelName = "simform_audio_waveforms_plugin/methods"
        static let startRecording = "startRecording"
        static let pauseRecording = "pauseRecording"
        static let stopRecording = "stopRecording"
        static let getDecibel = "getDecibel"
        static let checkPermission = "checkPermission"
        static let path = "path"
        static let encoder = "encoder"
        static let sampleRate = "sampleRate"
        static let fileNameFormat = "YY-MM-dd-HH-mm-ss"
        static let readAudioFile = "readAudioFile"
        static let startEngine = "startEngine"
        static let startPlayer = "startPlayer";
        static let stopPlayer = "stopPlayer";
        static let pausePlayer = "pausePlayer";
        static let seekTo = "seekTo";
        static let progress = "progress";
        static let setVolume = "setVolume";
        static let leftVolume = "leftVolume";
        static let rightVolume = "rightVolume";
        static let getDuration = "getDuration";
        static let durationType = "durationType";
        static let durationEventChannel = "durationEventChannel";
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Constants.methodChannelName, binaryMessenger: registrar.messenger())
        let instance = SwiftAudioWaveformsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any>
        switch call.method {
        case Constants.startRecording:
            audioWaveformsMethodCall.startRecording(result,  args?[Constants.path] as? String,
                                                    args?[Constants.encoder] as? Int, args?[Constants.sampleRate] as? Int,Constants.fileNameFormat)
            break
        case Constants.pauseRecording:
            audioWaveformsMethodCall.pauseRecording(result)
            break
        case Constants.stopRecording:
            audioWaveformsMethodCall.stopRecording(result)
            break
        case Constants.getDecibel:
            audioWaveformsMethodCall.getDecibel(result)
            break
        case Constants.checkPermission:
            audioWaveformsMethodCall.checkHasPermission(result)
            break
        case Constants.startEngine:
            audioWaveformsMethodCall.startEngine()
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
}
