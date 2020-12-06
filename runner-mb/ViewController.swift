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
import SnapKit
import RxCocoa
import RxSwift
import CoreLocation
import MapKit
import AVFoundation

class RunModel {
    var unit: UnitLength = .kilometers
    var startDate: Date?
    var endDate: Date?
    var isRunning = BehaviorRelay<Bool>(value: false)
    var distance: BehaviorRelay<Measurement<UnitLength>> = BehaviorRelay(value: Measurement(value: 0, unit: .meters))

    var isPause: Bool = false
    var pauseStartDate: Date?
    var pauseInSeconds: Int = 0

    func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> Measurement<UnitSpeed> {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]

        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        formatter.numberFormatter = numberFormatter
        
        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        return speed.converted(to: outputUnit)
    }

    func pace(_ outputUnit: UnitSpeed = .minutesPerKilometer) -> Measurement<UnitSpeed> {
        return self.pace(distance: distance.value, seconds: 0, outputUnit: .minutesPerKilometer)
    }

    func formatSpeed(speed:Measurement<UnitSpeed>, outputUnit: UnitSpeed) -> String {
        let formatter = MeasurementFormatter()
        return formatter.string(from: speed.converted(to: outputUnit))
    }

    func fakeStart() {
        self.startDate = Date()
        self.isRunning = BehaviorRelay(value: true)
        self.distance = BehaviorRelay(value: Measurement(value: 300, unit: .meters))
    }

    var durationWithPause: Int {
        let combinedDuration = duration-pauseInSeconds
        return combinedDuration < 0 ? 0 :combinedDuration
    }

    var duration: Int {
        guard let startDate = startDate else {
            return  0
        }
        return Int(Date().timeIntervalSince(startDate))
    }
}

class ViewController: UIViewController {

    let runModel = RunModel()
    var disposeBag = DisposeBag()

    //UI
    var startBtn:UIButton?
    var pauseBtn:UIButton?
    var continueBtn:UIButton?
    var finishBtn:UIButton?
    var saveBtn: UIButton?
    var timerDataView: DataView?
    var distanceDataView: DataView?
    var paceDataView: DataView?
    var addGhostDataView: ButtonDataView?
    var mapDataView: MapDataView?
    var containerStackView: UIStackView?
    var ghostController: GhostController = GhostController()

    @IBOutlet weak var containerSV: UIStackView!
    @IBOutlet weak var firstSV: UIStackView!
    @IBOutlet weak var secondSV: UIStackView!
    @IBOutlet weak var mapSV: UIStackView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
        self.setupBindings()
        //self.runModel.fakeStart()

    }

    func setupStack1() {
        let timerDataView = DataView.Timer()
        let distanceDataView = DataView.Distance()

        self.firstSV.addArrangedSubview(timerDataView)
        self.firstSV.addArrangedSubview(distanceDataView)

        self.timerDataView = timerDataView
        self.distanceDataView = distanceDataView

    }

    func setupStack2() {
        let paceDataView = DataView.Pace()
        let stepsDataView = DataView.Button()
        stepsDataView.pressedAddAction = {
            print("pressed add")
            if let vc = self.storyboard?.instantiateViewController(identifier: "HistoryTVC") as? HistoryTVC {
                vc.selectedEntryAction = { run in self.selectedGhost(run: run)}
                self.present(vc, animated: true, completion: nil)
            }
        }
        stepsDataView.pressedDeleteAction = {
            self.ghostController.reset()
        }

        self.secondSV.addArrangedSubview(paceDataView)
        self.secondSV.addArrangedSubview(stepsDataView)

        self.paceDataView = paceDataView
        self.addGhostDataView = stepsDataView
    }

    func setupStartStopButton() {
        let startBtn = RoundButton(color: UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.0))
        startBtn.setTitle("Start", for: .normal)
        //startBtn.setTitle("Pause", for: .selected)
        self.view.addSubview(startBtn)

        startBtn.snp.makeConstraints({ make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        })

        self.startBtn = startBtn
    }

    func setupPauseButton() {
        let btn = RoundButton(color: .systemOrange)
        btn.setTitle("Pause", for: .normal)
        btn.isHidden = true
        //startBtn.setTitle("Pause", for: .selected)
        self.view.addSubview(btn)

        btn.snp.makeConstraints({ make in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        })

        self.pauseBtn = btn
    }

    func setupContinueButton() {
        let btn = RoundButton(color: UIColor(red: 0.08, green: 0.49, blue: 0.98, alpha: 1.0))
        btn.setTitle("Continue", for: .normal)
        btn.isHidden = true
        //startBtn.setTitle("Pause", for: .selected)
        self.view.addSubview(btn)

        btn.snp.makeConstraints({ make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        })

        self.continueBtn = btn
    }

    func setupFinishButton() {
        let btn = RoundButton(color: .systemOrange)
        btn.setTitle("Finish", for: .normal)
        btn.isHidden = true
        //startBtn.setTitle("Pause", for: .selected)
        self.view.addSubview(btn)

        btn.snp.makeConstraints({ make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
        })

        self.finishBtn = btn
    }

    func setupMapDataView() {
        let mapDataView = MapDataView()
        self.mapSV.addArrangedSubview(mapDataView)
        self.mapDataView = mapDataView
    }

    func setupSaveButton() {
        let saveBtn = UIButton(type: .custom)
        saveBtn.layer.cornerRadius = 25
        saveBtn.layer.shadowColor = UIColor.black.cgColor
        saveBtn.layer.shadowOffset = CGSize(width: 2, height: 2)
        saveBtn.layer.shadowOpacity = 0.2
        saveBtn.layer.shadowRadius = 1
        saveBtn.layer.masksToBounds = false
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.backgroundColor = UIColor(white: 0.8, alpha: 1)
        saveBtn.setImage(#imageLiteral(resourceName: "ic_icons8-save"), for: .normal)
        saveBtn.tintColor = .systemBlue

        saveBtn.addTarget(self, action: #selector(pressedSave), for: .touchUpInside)
        self.view.addSubview(saveBtn)

        saveBtn.snp.makeConstraints({ make in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        })

        self.saveBtn = saveBtn
    }

    func setup() {
        self.ghostController.delegate = self
        LocationManager.shared.delegate = self
        setupStartStopButton()
        setupPauseButton()
        setupContinueButton()
        setupFinishButton()
        setupStack1()
        setupStack2()
        setupMapDataView()
        //dont need this save for now
        //setupSaveButton()
    }

    func setupBindings() {
        self.startBtn?.rx.tap.bind(onNext: {
            print("start")
            self.runModel.isRunning.accept(true)
            self.startBtn?.isHidden = true
            self.continueBtn?.isHidden = true
            self.pauseBtn?.isHidden = false
            self.finishBtn?.isHidden = true
            self.runModel.startDate = Date()
            self.ghostController.update()
        }).disposed(by: disposeBag)

        self.pauseBtn?.rx.tap.bind(onNext: {
            self.continueBtn?.isHidden = false
            self.startBtn?.isHidden = true
            self.finishBtn?.isHidden = false
            self.pauseBtn?.isHidden = true
            self.runModel.pauseStartDate = Date()
            self.runModel.isPause = true
            self.runModel.isRunning.accept(false)
            self.ghostController.cancelNotifications()
        }).disposed(by: disposeBag)

        self.continueBtn?.rx.tap.bind(onNext: {
            self.pauseBtn?.isHidden = false
            self.startBtn?.isHidden = true
            self.finishBtn?.isHidden = true
            self.continueBtn?.isHidden = true
            if let pauseStartDate = self.runModel.pauseStartDate {
                self.runModel.pauseInSeconds += self.calculatePause(pauseStartDate: pauseStartDate, pauseEndDate: Date())
                self.runModel.pauseStartDate = nil
            }
            self.ghostController.update()
            self.runModel.isRunning.accept(true)
            self.runModel.isPause = false

        }).disposed(by: disposeBag)

        self.finishBtn?.rx.tap.bind(onNext: {
            self.pauseBtn?.isHidden = true
            self.startBtn?.isHidden = false
            self.finishBtn?.isHidden = true
            self.continueBtn?.isHidden = true
            if (self.runModel.startDate != nil) {
                //self.runModel.pauseInSeconds += self.calculatePause(pauseStartDate: pauseStartDate, pauseEndDate: Date())
                self.runModel.pauseStartDate = nil
            }
            self.ghostController.reset()
            self.runModel.endDate = Date()
            self.showSaveAlert()
            self.runModel.isRunning.accept(false)
            self.runModel.isPause = false

        }).disposed(by: disposeBag)

        self.runModel.isRunning.bind(to: startBtn!.rx.isSelected).disposed(by: disposeBag)

        self.runModel.isRunning.skip(1).subscribe(onNext: {
//            if ($0 == true) {
//                TimerManager.shared.start(Date())
//                LocationManager.shared.start()
//            }
//            else {
//                TimerManager.shared.stop()
//                LocationManager.shared.stop()
//            }
            if self.runModel.isPause {
                if ($0 == true) {
                    TimerManager.shared.start(nil, self.runModel.pauseInSeconds)
                    LocationManager.shared.start()
                } else {
                    TimerManager.shared.pause()
                    LocationManager.shared.stop()
                }
            } else {
                if ($0 == true) {
                    TimerManager.shared.start(Date())
                    LocationManager.shared.start()
                }
                else {
                    TimerManager.shared.stop()
                    LocationManager.shared.stop()
                }
            }
        }).disposed(by: disposeBag)

        self.runModel.distance.map({
            ($0.converted(to: .kilometers).value).short
        })
        .bind(to: distanceDataView!.valueLabel!.rx.text)
        .disposed(by: disposeBag)


        self.runModel.distance.map({
            "\($0.converted(to: .kilometers).unit.symbol)"
        }).bind(to: self.distanceDataView!.unitLabel!.rx.text)
        .disposed(by: disposeBag)


        self.setupTimerBindings()
        self.setupLocationBindings()
    }

    func setupTimerBindings() {
        TimerManager.shared.timeElapsedBinding.map({
            $0.positionalTime
        }).bind(to: timerDataView!.valueLabel!.rx.text )
        .disposed(by: disposeBag)

        TimerManager.shared.timeElapsedBinding.map({ time in

            //should display nothing if we are under 1km or 1mile
            if self.runModel.distance.value.value < 1000 {
                return "--:--"
            }

            let formattedPace = self.runModel.pace(distance: self.runModel.distance.value, seconds: Int(time), outputUnit: .minutesPerKilometer)
            let totalSeconds = lrint(formattedPace.value*60)
            //let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60

            return String(format: "%02d:%02d", minutes, seconds)

        }).bind(to: self.paceDataView!.valueLabel!.rx.text)
        .disposed(by: disposeBag)

        //Can't use this binding because it wont work properly in background
//        TimerManager.shared.timeElapsedBinding.bind(onNext: {
//            if let _ = self.ghostController.currentGhost {
//                if let nextGoal = self.ghostController.getNextGoal() {
//                    if  Int($0) > nextGoal.duration {
//                        SpeechManager.shared.say(text: nextGoal.distance)
//                        self.ghostController.advanceGoal()
//                    }
//                }
//            }
//            }).disposed(by: disposeBag)


    }

    func setupLocationBindings() {
        LocationManager.shared.setup()
        LocationManager.shared.distance.bind(to: self.runModel.distance)
            .disposed(by: disposeBag)

        LocationManager.shared.pastLocationsBinding.skip(1).subscribe(onNext: {
            let locations = $0.map({$0.0.coordinate})
            self.mapDataView?.locations = locations
            }).disposed(by: disposeBag)
    }

    func calculatePause(pauseStartDate: Date, pauseEndDate: Date) -> Int {
        return Int(pauseEndDate.timeIntervalSince(pauseStartDate))
    }


    @objc func pressedSave() {

        let locations:[(CLLocationCoordinate2D, Date)] = mapDataView!.locations.map({($0, Date())})
        self.snapshotMap { image in
            Database.shared.saveRun(startDate: self.runModel.startDate ?? Date(), endDate: self.runModel.endDate ?? Date(), distance: Int(self.runModel.distance.value.value), pace: 3.0, pauseDuration: self.runModel.pauseInSeconds, locations: locations, image: image?.pngData())

            //save pace directly
        }

    }

    func showSaveAlert() {
        let alert = UIAlertController(title: "Save this run?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            self.pressedSave()
        }))
        self.present(alert, animated: true, completion: nil)
    }


    func snapshotMap(_ complete:@escaping (UIImage?)->()) {
        let options = MKMapSnapshotter.Options.init()
                options.mapType = .standard
                //options.showsPointsOfInterest = true
                options.showsBuildings = true

                if let region = mapDataView?.mapView.region {
                    options.region = region
                }
                if let maprect = mapDataView?.mapView.visibleMapRect {
                    options.mapRect = maprect
                }
                options.size = mapDataView!.mapView.frame.size
                let sp = MKMapSnapshotter(options: options)
                sp.start { (snapshot, error) in

                    if let snapshotImage = snapshot?.image {

                        UIGraphicsBeginImageContextWithOptions(snapshotImage.size, true, snapshotImage.scale)
                        snapshotImage.draw(at: CGPoint(x: 0, y: 0))

                        let context = UIGraphicsGetCurrentContext();
                        context!.setStrokeColor(UIColor.red.cgColor)
                        context!.setLineWidth(3)

                        context!.beginPath();

                        for (index, overlay) in self.mapDataView!.locations.enumerated() {

                            let point = snapshot!.point(for: overlay)
                            if (index == 0) {
                                context!.move(to: point)
                            } else {
                                context!.addLine(to: point)
                            }
                        }
                        context!.strokePath()
                        let compositeImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext()
                        complete(compositeImage)
                    }

                }
    }

    func selectedGhost(run: Run) {
        self.ghostController.currentGhost = run
        self.ghostController.update()
    }

    func removeGhost() {

    }
}

extension ViewController: GhostControllerDelegate {
    func didUpdateGhost(ghost:Run?, distance:String, time: String) {
        if let _ = ghost  {
            self.addGhostDataView?.valueLabel?.text = "\(distance)"
            self.addGhostDataView?.unitLabel?.text = "\(time)"
            self.addGhostDataView?.actionBtn?.isHidden = true
            self.addGhostDataView?.deleteBtn?.isHidden = false
        } else {
            self.addGhostDataView?.valueLabel?.text = ""
            self.addGhostDataView?.unitLabel?.text = ""
            self.addGhostDataView?.deleteBtn?.isHidden = true
            self.addGhostDataView?.actionBtn?.isHidden = false
        }
    }
}

extension ViewController: LocationManagerDelegate {
    func updatedLocation(locationManager: LocationManager) {
        if let nextGoal = ghostController.getNextGoal() {
            if nextGoal.duration < runModel.durationWithPause {
                ghostController.advanceGoal()

                //make speak
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("Session is Active")
                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
                    AudioPlayerManager.shared.playSound(fileName: "half.caf", completion: {
                        do {
                            try? AVAudioSession.sharedInstance().setActive(false)
                        }
                    })
                } catch {
                    print(error)
                }
            }
        }
    }
}
