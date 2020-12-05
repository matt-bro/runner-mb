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
import MapKit

struct RunEntry {
    var distance:Double
    var pace:Double
    var time:String
    var steps:Int
    var locations:[CLLocation]?
}

class HistoryTVC: UITableViewController {

    var entries:[Run] = []
    var selectedEntryAction:((Run)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.register(UINib(nibName: "RunEntrySmallCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.backgroundColor = .groupTableViewBackground
        self.tableView.rowHeight = 231
        self.tableView.separatorStyle = .none

        let historyBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pressedDone))
        self.navigationItem.rightBarButtonItem = historyBtn
        self.title = "Running History"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.entries = Database.shared.getRuns()
        self.tableView.reloadData()
    }

    @objc func pressedDone() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RunEntrySmallCell
        let run = entries[indexPath.row]
        cell.distanceLabel?.text = String(format: "%02.02f", run.distanceKm)
        cell.timePassed?.text = "\(run.durationString)"
        cell.paceLabel?.text =  run.paceString()
        cell.titleLabel?.text = "\(run.date)"

        if let image = run.mapImageLight {
            cell.mapImageView.image = UIImage(data: image)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedEntryAction = selectedEntryAction {
            let run = entries[indexPath.row]
            selectedEntryAction(run)
            self.dismiss(animated: true, completion: nil)
        }

    }
}

extension Run {
    var date:String {
        get {
            let df = DateFormatter()
            df.dateStyle = .full
            //df.dateFormat = "EEEE, dd.MM.yyyy - HH:mm"
            return df.string(from: self.startDate ?? Date())
        }
    }

    var distanceKm: Double {
        get {
            let distanceM = Measurement(value: Double(distance), unit: UnitLength.meters)
            return distanceM.converted(to: UnitLength.kilometers).value
        }
    }

    var paceKm: Double {
        get {
            let distanceM = Measurement(value: Double(pace), unit: UnitSpeed.minutesPerKilometer)
            return distanceM.value
        }
    }

    var durationWithPause: Int64 {
        let combinedDuration = duration-pauseDuration
        return combinedDuration < 0 ? 0 :combinedDuration
    }

    var durationString: String {
        get {
            let interval = durationWithPause

            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated

            let formattedString = formatter.string(from: TimeInterval(interval))!
            //print(formattedString)
            return formattedString
        }
    }
}
