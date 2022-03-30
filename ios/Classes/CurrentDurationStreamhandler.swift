import Foundation

class CurrentDurationStreamHandler:  NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?
    private var audioPlayer = AudioPlayer.sharedInstance
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        
        print(audioPlayer.player)
            return nil
        }
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
            return nil
        }
        
}
