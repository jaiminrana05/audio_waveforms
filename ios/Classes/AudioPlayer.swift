//
//  AudioPlayer.swift
//  audio_waveforms
//
//  Created by Ujas Majithiya on 01/04/22.
//

import Foundation

import AVKit

class AudioPlayer{
    var audioPlayer: AVPlayer?
    
    func startPlayer(_ path: String, volume: Double?,_ result:  @escaping FlutterResult){
        let url = URL(string: path)
        if(url != nil){
            do{
                audioPlayer = AVPlayer(url: url!)
                audioPlayer?.volume = Float(volume ?? 1.0)
                audioPlayer?.play()
                result(true)
            } catch {
                result(FlutterError(code: "", message: "Failed to start plater", details: nil))
            }
        }
        
    }
    
    func getDuration(_ type:DurationType) -> Int{
        if type == .Current {
            return Int(audioPlayer?.currentItem?.currentTime().seconds ?? 0)
        }else{
            return Int(audioPlayer?.currentItem?.duration.seconds ?? 0)
        }
    }
    
    func pausePlayer(_ result:  @escaping FlutterResult){
        audioPlayer?.pause()
        result(true)
    }
    
    func stopPlayer(_ result:  @escaping FlutterResult){
        audioPlayer?.replaceCurrentItem(with: nil)
        result(true)
    }
    
    func setVolume(volume: Double) {
            audioPlayer?.volume = Float(volume)
        }
    
    func seekTo(_ time: Int) {
        audioPlayer?.seek(to: CMTime(seconds: Double(time/1000), preferredTimescale: 1))
    }
}
