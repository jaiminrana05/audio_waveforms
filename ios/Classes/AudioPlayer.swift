import Foundation

import AVKit



class AudioPlayer : NSObject, FlutterStreamHandler {
    static let sharedInstance = AudioPlayer()
    var player: AVPlayer?
    var sink: FlutterEventSink?
    private weak var listener: AudioPlayerListener?
    var timer = Timer()
    var observerToken: Any?
   
    
    public func registerListener(listener: AudioPlayerListener) {
            self.listener = listener
        }
    
    func preparePlayer(path: String?, volume: Double?,result:  @escaping FlutterResult){
        if(!(path ?? "").isEmpty){
            let url = URL.init(fileURLWithPath: path!)
            do{
                player = AVPlayer(url: url)
                player?.volume = Float(volume ?? 1.0)
                result(true)
            } catch {
                result(FlutterError(code: "", message: "Failed to prepare player", details: nil))
            }
        } else {
            result(FlutterError(code: "", message: "Path to file can't be empty or null", details: nil))
        }
    }
    
    func startPlayer(result:  @escaping FlutterResult){
                do{
                    if(player?.status == .readyToPlay){
                        player?.play()
                       
                        result(true)
                    }
                } catch {
                    result(FlutterError(code: "", message: "Failed to start player", details: nil))
                }
    }
    
    func getDuration(_ type:DurationType,_ result:  @escaping FlutterResult) throws {
        if type == .Current {
            let seconds = player?.currentItem?.duration.seconds
            guard !(seconds == nil || seconds!.isNaN || seconds!.isInfinite) else {
                throw ThrowError.runtimeError("Error")
            }
            result(Int(player?.currentItem?.currentTime().seconds ?? 0) * 1000)
        }else{
            let seconds = player?.currentItem?.duration.seconds
            guard !(seconds == nil || seconds!.isNaN || seconds!.isInfinite) else {
                throw ThrowError.runtimeError("Error")
            }
            result(Int(player?.currentItem?.duration.seconds ?? 0) * 10000)
        }
    }
    
    func pausePlayer(_ result:  @escaping FlutterResult){
        player?.pause()
        result(true)
    }
    
    func stopPlayer(_ result:  @escaping FlutterResult){
        player?.replaceCurrentItem(with: nil)
        result(true)
    }
    
    func setVolume(_ volume: Double?,_ result : @escaping FlutterResult) {
        if(volume != nil){
            player?.volume = Float(volume!)
            result(true)
        }
            result(false)
        }
    
    func seekTo(_ time: Int?,_ result : @escaping FlutterResult) {
        if(time != nil){
            player?.seek(to: CMTime(seconds: Double(time!/1000), preferredTimescale: 1))
            result(true)
        } else {
            result(false)
        }
    }
    
    func startListening(){
        let interval = CMTimeMakeWithSeconds(0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        observerToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .global(), using: {[weak self] time in
            var milliSeconds = (self?.player?.currentItem?.currentTime().seconds ?? 0) * 1000
            self?.sink!(Int(milliSeconds))
        })
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        startListening()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if(observerToken != nil){
            player?.removeTimeObserver(observerToken!)
        }
        
        sink = nil
        timer.invalidate()
        return nil
    }
}
