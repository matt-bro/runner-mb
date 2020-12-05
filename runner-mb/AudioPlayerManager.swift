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

import Foundation
import AVFoundation

class CustomAVPlayer: AVAudioPlayer {
    public var tag = 0
    public var completion:(()->())?
}

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {

    static let shared = AudioPlayerManager()
    private var playerPool: [CustomAVPlayer] = []
    static var customPath: String = ""

    func playSound(fileName: String, tag: Int = 0, exclusively: Bool = true, completion: (()->())? = nil) {
        if exclusively == true {
            if self.playerPoolContains(fileName: fileName) == true {
                return
            }
        }

        let player = self.createPlayer(fileName: fileName)
        player?.tag = tag
        player?.completion = completion
        player?.delegate = self
        player?.prepareToPlay()
        player?.play()
    }

    func loopSound(fileName: String, tag: Int = 0, exclusively: Bool = true, loops: Int = -1, completion: (()->())? = nil) {
        if exclusively == true {
            if self.playerPoolContains(fileName: fileName) == true {
                return
            }
        }

        let player = self.createPlayer(fileName: fileName)
        player?.tag = tag
        player?.completion = completion
        player?.delegate = self
        player?.numberOfLoops = loops;
        player?.prepareToPlay()
        player?.play()
    }

    func playSoundExclusively(fileName: String, completion: (()->())? = nil) {
        if self.playerPoolContains(fileName: fileName) == false {
            self.playSound(fileName: fileName, completion: completion)
        }
    }

    fileprivate func players(withFileName fileName: String) -> [CustomAVPlayer] {
        return playerPool.filter({
            self.fileNameOnly($0.url?.absoluteString) == self.fileNameOnly(fileName)
        })
    }

    fileprivate func players(withTag tag: Int) -> [CustomAVPlayer] {
        return playerPool.filter({
            $0.tag == tag
        })
    }

    func playOrPauseSound(withFileName fileName: String) {
        let players = self.players(withFileName: fileName)
        self.playOrPauseSound(players: players)
    }

    func playOrPauseSound(withTag tag: Int) {
        let players = self.players(withTag: tag)
        self.playOrPauseSound(players: players)
    }

    fileprivate func playOrPauseSound(players: [CustomAVPlayer]) {
        for player in players {
            if player.isPlaying {
                player.pause()
            } else {
                player.play()
            }
        }
    }

    fileprivate func playerPoolContains(fileName: String) -> Bool {
        var containsFileName = false
        containsFileName = self.players(withFileName: fileName).count > 0
        return containsFileName
    }

    func stopAllSounds() {
        self.playerPool.forEach({ $0.stop() })
    }

    func stopAllSounds(exceptFileNames: [String] = [], exceptTags: [Int] = []) {
        self.playerPool.forEach({ $0.stop() })
    }

    func pauseAllSounds() {
        self.playerPool.forEach({ $0.pause() })
    }

    func pauseAllSounds(exceptFileNames: [String] = [], exceptTags: [Int] = []) {}

    func applyVolumeToAllSounds(_ volume: Float, exceptFileNames: [String] = [], exceptTags: [Int] = []) {
        self.playerPool.forEach({ $0.volume = volume })
    }

    func applyVolumeToSelectedSounds(_ volume: Float, fileNames: [String] = [], tags: [Int] = []) {
        self.playerPool.forEach({ $0.volume = volume })
    }

    func stopSound(tag: Int = 0) {
        let players = self.players(withTag: tag)
        players.forEach({ $0.stop() })

        self.playerPool.removeAll(where: {$0.tag == tag})
    }

    fileprivate func fileNameOnly(_ fileName: String?) -> String {
        guard let fileName = fileName else {
            return ""
        }
        let tempFileName = NSString(string: fileName)
        return String(tempFileName.lastPathComponent)
    }

    fileprivate func createPlayer(fileName:String) -> CustomAVPlayer? {
        if fileName.isEmpty {
            return nil
        }

        var path: String?

        if AudioPlayerManager.customPath.isEmpty == false {
            path = AudioPlayerManager.customPath + fileName
        } else {
            path = Bundle.main.path(forResource: fileName, ofType: nil)
        }
        if let path = path {
            let url = URL(fileURLWithPath: path)

            do {
                let player = try CustomAVPlayer(contentsOf: url)
                playerPool.append(player)
                return player
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let player = self.playerPool.filter({ $0 == player }).first {
            let fileName = NSString(string: player.url?.absoluteString ?? "").lastPathComponent
            print("finished playing sound for \(fileName)")
            //call completion block
            player.completion?()
            //remove from pool
            _ = self.playerPool.firstIndex(of: player).map { self.playerPool.remove(at: $0) }
        }
    }
}
