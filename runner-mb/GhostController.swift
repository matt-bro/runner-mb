//
//  GhostController.swift
//  runner-mb
//
//  Created by Matt on 03.11.20.
//

import UIKit
import AVKit

protocol GhostControllerDelegate: class {
    func didUpdateGhost(ghost:Run?, distance: String, time: String)
}

class GhostController: NSObject {
    var currentGhost: Run?
    weak var delegate: GhostControllerDelegate?

    var goals:[(duration: Int, distance: String, audio: AVAudioFile?)] = []
    var currentGoal: (duration: Int, distance: String, audio: AVAudioFile?)?
    var goalIndex = 0
    var pauseDuration: Int = 0

    var halfDistanceAudio: AVAudioFile?
    var finishedDistanceAudio: AVAudioFile?

    func update() {
        guard let currentGhost = currentGhost else {
            return
        }

        self.delegate?.didUpdateGhost(ghost: currentGhost, distance: currentGhost.distanceKmString, time: currentGhost.durationString)
        self.setupGoals(run: currentGhost)
        //self.setupNotifications(run: currentGhost)
    }

    func setupGoals(run: Run) {
        //first km/mile
        //half distance
        let halfText = "Ghost reached half at \(run.distanceKm/2) km"
        let finishText = "Ghost finished distance of \(run.distanceKm) km"

//        goals.append((Int(Date().timeIntervalSinceNow+15), "Ghost reached half at \(run.distanceKm/2) km"))
//        goals.append((Int(run.duration/2), "Ghost reached half at \(run.distanceKm/2) km"))
//        goals.append((Int(run.duration), "Ghost finished distance of \(run.distanceKm) km"))

        //generate audio files
        //need to nest, otherwise the order might be wrong
        SpeechManager().getAudio(text: halfText, alias: "half", completion:{ audio in
            self.halfDistanceAudio = audio
            self.goals.append((Int(run.duration/2), halfText, audio))
            SpeechManager().getAudio(text: finishText, alias: "finish", completion:{ audio in
                self.finishedDistanceAudio = audio
                self.goals.append((Int(run.duration), finishText, audio))
            })
        })


        
    }

    func setupNotifications(run: Run) {
        //get the notification center
        let center =  UNUserNotificationCenter.current()

        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = " Ghost reached half"
        content.subtitle = "\(run.distanceKm/2) km"
        content.body = "Ghost reached half at \(run.distanceKm/2) km"
        content.sound = UNNotificationSound.default

        //notification trigger can be based on time, calendar or location
        let timeInterval = 15.0//TimeInterval((Int(run.duration)/2)-pauseDuration)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        //create request to display
        let request = UNNotificationRequest(identifier: "RunnermbHalfTime", content: content, trigger: trigger)

        //add request to notification center
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }

    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["RunnermbHalfTime"])
    }

    func getNextGoal() -> (duration: Int, distance: String, audio: AVAudioFile?)? {
        if self.goalIndex < self.goals.count {
            return self.goals[self.goalIndex]
        } else {
            return nil
        }
    }

    func advanceGoal() {
        self.goalIndex = goalIndex+1
    }

    func reset() {
        self.currentGhost = nil
        self.goals = []
        self.goalIndex = 0
        self.delegate?.didUpdateGhost(ghost: nil, distance: "", time: "")
        self.cancelNotifications()
    }
}
