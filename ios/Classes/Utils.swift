enum DurationType {
    case Current
    case Max
}

enum ThrowError: Error {
    case runtimeError(String)
}

protocol AudioPlayerListener: class {
    func bufferWasUpdated(newValue: Double)
    func timeElapsed(newTimeInSeconds: Double)
    func errorReceived(error: NSError)
}
