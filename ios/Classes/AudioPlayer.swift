import Foundation
import AVFoundation
import AVKit

import MediaPlayer


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
    
    func mediaItemArtwork(from image: UIImage) -> MPMediaItemArtwork {
          if #available(iOS 10.0, *) {
              return MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size: CGSize) -> UIImage in
                  return image
              })
          } else {
              return MPMediaItemArtwork(image: image)
          }
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
    
    func getMetaData(path: String?,result: @escaping FlutterResult){
        
        if(!(path ?? "").isEmpty){
            var nowPlayingInfo : [String: Any] = [:]
            let url = URL.init(fileURLWithPath: path!)
            print("PATH:-\(url)")
//            let asset = AVAsset(url: url)
//            let metaData = asset.metadata(forFormat: AVMetadataFormat.id3Metadata)
//            let releaseDate = AVMetadataItem.metadataItems(from: metaData, withKey: "TDAT",keySpace:.id3)
//            if let data = releaseDate.first , let date = data.stringValue{
//                print("RELEASE_DATE:-\(date)")
//            }
            do{
                let asset = AVAsset(url: url)
                let item = AVPlayerItem(asset: asset)
                let metadatalist = item.asset.metadata
                
                for item in metadatalist{
                    switch item.commonKey{
                     
                    
                    case .commonKeyTitle?:nowPlayingInfo[MPMediaItemPropertyTitle] = item.stringValue
                    case .commonKeyArtist?:nowPlayingInfo[MPMediaItemPropertyArtist] = item.stringValue
                    case .commonKeyAlbumName?:nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = item.stringValue
                    case .commonKeyType?:nowPlayingInfo[MPMediaItemPropertyGenre] = item.stringValue
                    case .commonKeyArtwork?:nowPlayingInfo[MPMediaItemPropertyArtwork] = item.dataValue
                    case .commonKeyCreationDate?:nowPlayingInfo[MPMediaItemPropertyReleaseDate] = item.stringValue
                    case .none:
                        break
                    default :
                        break
                    }
                }
                print("ITEM:-\n\n\(item)")
                
            
                print("METADATALIST:-\n\n\(metadatalist)")
                print("NOWPLAYINGINFO:-\n\n\(nowPlayingInfo)")
                result(nowPlayingInfo)
            } catch
            {
                result(FlutterError(code: "", message: "Failed to Get Metadata", details: nil))
            }
        }else{
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
