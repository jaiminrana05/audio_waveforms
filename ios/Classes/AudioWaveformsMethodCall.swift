import AVFoundation
import Accelerate

public class AudioWaveformsMethodCall: NSObject, AVAudioRecorderDelegate{
    var audioRecorder: AVAudioRecorder?
    var path: String?
    var hasPermission: Bool = false
    private var audioEngine: AVAudioEngine!
    public var meteringLevels: [Float]?
    
    public override init() {
        super.init()
        self.audioEngine = AVAudioEngine()
    //    self.startEngine()
        
    }
    public func startRecording(_ result: @escaping FlutterResult,_ path: String?,_ encoder : Int?,_ sampleRate : Int?,_ fileNameFormat: String){
        let settings = [
            AVFormatIDKey: getEncoder(encoder ?? 0),
            AVSampleRateKey: sampleRate ?? 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let options: AVAudioSession.CategoryOptions = [.defaultToSpeaker, .allowBluetooth]
        if (path == nil) {
            let directory = NSTemporaryDirectory()
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = fileNameFormat
            let fileName = dateFormatter.string(from: date) + ".aac"
            
            self.path = NSURL.fileURL(withPathComponents: [directory, fileName])?.absoluteString
        } else {
            self.path = path
        }
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: options)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let url = URL(string: self.path!) ?? URL(fileURLWithPath: self.path!)
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            result(true)
        } catch {
            result(FlutterError(code: "", message: "Failed to start recording", details: nil))
        }
    }
    
    public func stopRecording(_ result: @escaping FlutterResult) {
        audioRecorder?.stop()
        audioRecorder = nil
        result(path)
    }
    
    public func pauseRecording(_ result: @escaping FlutterResult) {
        audioRecorder?.pause()
        result(false)
    }
    
    public func getDecibel(_ result: @escaping FlutterResult) {
        var amp = Float()
        audioRecorder?.updateMeters()
        amp = audioRecorder?.peakPower(forChannel: 0) ?? 0.0
        print(amp)
        result(amp)
    }
    
    public func checkHasPermission(_ result: @escaping FlutterResult){
        switch AVAudioSession.sharedInstance().recordPermission{
            
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    self.hasPermission = allowed
                }
            }
            break
        case .denied:
            hasPermission = false
            break
        case .granted:
            hasPermission = true
            break
        @unknown default:
            hasPermission = false
            break
        }
        result(hasPermission)
    }
    public func getEncoder(_ enCoder: Int) -> Int {
        switch(enCoder) {
        case 1:
            return Int(kAudioFormatMPEG4AAC_ELD)
        case 2:
            return Int(kAudioFormatMPEG4AAC_HE)
        case 3:
            return Int(kAudioFormatOpus)
        case 4:
            return Int(kAudioFormatAMR)
        case 5:
            return Int(kAudioFormatAMR_WB)
        default:
            return Int(kAudioFormatMPEG4AAC)
        }
    }
    public func startEngine(){
        guard !audioEngine.isRunning else {
                    return
                }

                do {
                    try audioEngine.start()
                } catch { }
    }
     func readBuffer(_ result: @escaping FlutterResult,_ path: String?) -> UnsafeBufferPointer<Float> {
        let url = URL(string: path!)!
            let file = try! AVAudioFile(forReading: url)

            let audioFormat = file.processingFormat
            let audioFrameCount = UInt32(file.length)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            else { return UnsafeBufferPointer<Float>(_empty: ()) }
            do {
                try file.read(into: buffer)
            } catch {
                print(error)
            }

    //        let floatArray = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength)))
            let floatArray = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
        print(floatArray)
        result(0)
            return floatArray
        }
    
 
    public func readFile(_ result: @escaping FlutterResult,_ path: String?){
        print(path ?? "path")
        let url = URL(string: path!)!
        do{
            AudioContext.load(fromAudioURL: url) { audioContext in
                        guard let audioContext = audioContext else {
                            fatalError("Couldn't create the audioContext")
                        }
                self.meteringLevels = audioContext.render(targetSamples: 100)
                print(self.meteringLevels)
                    }

//            let file = try AVAudioFile(forReading: URL(string: path!)!)
//            guard let reader = try? AVAssetReader(asset: AVAsset(url: URL(string: path!)!)) else {
//                        fatalError("Couldn't initialize the AVAssetReader")
//                    }
//
//            let playerNode = AVAudioPlayerNode()
//            audioEngine.attach(playerNode)
////            let point = AVAudioConnectionPoint(node: AVAudioNodeplayerNode, bus: <#T##AVAudioNodeBus#>)
//            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: file.processingFormat)
          // audioEngine.con
//            if let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false), let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)){
//                try file.read(into: buf)
////                let abl = Array(UnsafeBufferPointer(start: buf.audioBufferList, count: Int(buf.audioBufferList.pointee.mNumberBuffers)))
//
////                let buffer = buf.audioBufferList[0].mBuffers
////                let mDataList = Array(UnsafeMutableRawBufferPointer(start: buffer.mData, count: Int(buffer.mDataByteSize)))
//                //print(buffer.mData)
//               // print(abl)
//
//            }
//            audioEngine.prepare()
//            startEngine()
//            playerNode.scheduleFile(file, at: nil) {
//                        playerNode .removeTap(onBus: 0)
//                    }
//            playerNode.installTap(onBus: 0, bufferSize: 4096, format: playerNode.outputFormat(forBus: 0)) { (buffer, when) in
//                let sampleData = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
////                for data in sampleData{
////                    print(data)
////                }
//
//                    }
//                    playerNode.play()
                
            result(0)
        }catch{
            result(FlutterError(code: "", message: "Failed to read file", details: nil))
        }
        
    }
}
