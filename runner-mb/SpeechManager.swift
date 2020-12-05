//MIT License
//
//Copyright (c) 2020 Matthias Brodalka
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import UIKit
import AVFoundation

class SpeechManager: NSObject {

    static let shared = SpeechManager()
    var speechSynthesizer = AVSpeechSynthesizer()
    var audioFile:AVAudioFile?
    override init() {

    }

    func say(text: String) {
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
    }

    func getAudio(text: String, alias: String, completion:((AVAudioFile?)->())?) {
        self.audioFile = nil
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.write(speechUtterance) { buffer in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
               fatalError("unknown buffer type: \(buffer)")
            }
            if pcmBuffer.frameLength == 0 {
              // done
                completion?(self.audioFile)

            } else {
              // append buffer to file
                do {
                    if self.audioFile == nil {
                        self.audioFile = try? AVAudioFile(
                            forWriting: URL(string: URL.documentsURL.absoluteString+"/\(alias).caf")!,
                            settings: pcmBuffer.format.settings,
                      commonFormat: .pcmFormatInt16,
                      interleaved: false)
                    }
                    try? self.audioFile?.write(from: pcmBuffer)
                }
            }
        }
    }


}
