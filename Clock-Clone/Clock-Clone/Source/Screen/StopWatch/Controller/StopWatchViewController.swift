//
//  StopWatchViewController.swift
//  Clock-Clone
//
//  Created by 한유진 on 2022/04/18.
//

import UIKit

class StopWatchViewController: UIViewController {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var lapResetButton: UIButton!
    @IBOutlet weak var labTimerLabel: UILabel!
    @IBOutlet weak var lapsTableView: UITableView!
    
    private var laps : [String] = []
    private var lapsDiff : [String] = []
    private let mainStopwatch : Stopwatch = Stopwatch()
    private var isCounting : Bool = false
    private let timeInterval : Double = 0.035
    private let minute : Double = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButtonShape()
        initTableView()
        initalizeButtons()
    }
    private func initTableView(){
        //TableView에서 사용하는 Cell이라고 등록하는 과정
        let nib = UINib(nibName: StopwatchTableViewCell.identifier, bundle: nil)
        lapsTableView.register(nib, forCellReuseIdentifier: StopwatchTableViewCell.identifier)
    
        lapsTableView.delegate = self
        lapsTableView.dataSource = self
    }
    private func initButtonShape() {
        initCircleButton(playPauseButton)
        initCircleButton(lapResetButton)
    }
    @IBAction func playPauseTimerButton(_ sender: Any) {
        lapResetButton.isEnabled = true
        if isCounting {
            pauseTimer()
        } else {
            playTimer()
        }
    }
    @IBAction func lapResetTimerButton(_ sender: Any) {
        if isCounting {
            if let timerLabelText = labTimerLabel.text {
                laps.append(timerLabelText)
            }
            lapsTableView.reloadData()
        } else {
            initalizeButtons()
        }
    }
    //클로저 문법
    let initCircleButton : (UIButton) -> Void = {
        button
        in
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
//        button.backgroundColor = UIColor.darkGray
    }
    
    private func pauseTimer(){
        //타이머 중지
        mainStopwatch.timer.invalidate()
        
        self.isCounting = false
        
        changeButton(button: lapResetButton, title: "재설정", titleColor: .white, backgroundColor: .darkGray)
        changeButton(button: playPauseButton, title: "시작", titleColor: .white, backgroundColor: .green)
    }
    private func playTimer() {
        mainStopwatch.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self,selector: #selector(updateMainTimer), userInfo: nil, repeats: true)
        
        RunLoop.current.add(mainStopwatch.timer, forMode: RunLoop.Mode.common)
        
        self.isCounting = true
        
        changeButton(button: lapResetButton, title: "랩", titleColor: .gray, backgroundColor: .darkGray)
        changeButton(button: playPauseButton, title: "중단", titleColor: .red, backgroundColor: .red)
    }
    
    private func changeButton(button: UIButton, title:String, titleColor : UIColor , backgroundColor : UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for:.normal)
        button.backgroundColor = backgroundColor
        button.alpha = 0.2
    }
    @objc func updateMainTimer() {
        updateTimer(mainStopwatch, label: labTimerLabel)
    }
    private func resetTimer(stopWatch: Stopwatch, label: UILabel) {
        stopWatch.timer.invalidate()
        stopWatch.counter = 0.0
        label.text = "00:00:00"
    }
    private func initalizeButtons() {
        lapResetButton.isEnabled = false
        
        changeButton(button: lapResetButton, title: "재설정", titleColor: .gray, backgroundColor: .darkGray)
        changeButton(button: playPauseButton, title: "시작", titleColor: .systemGreen, backgroundColor: .green)
        
        resetTimer(stopWatch: mainStopwatch, label: labTimerLabel)
        
        laps.removeAll()
        lapsTableView.reloadData()
    }
    private func updateTimer(_ stopwatch: Stopwatch, label : UILabel) {
        stopwatch.counter = stopwatch.counter + timeInterval
        
        var minutes : String = String(Int(stopwatch.counter / minute))
        if Int(stopwatch.counter / minute) < 10 {
            minutes = "0" + minutes
        }
        
        var seconds : String = String(format: "%.2f",(stopwatch.counter.truncatingRemainder(dividingBy: minute)))
        if stopwatch.counter.truncatingRemainder(dividingBy: minute) < 10 {
            seconds = "0" + seconds
        }
        label.text = minutes + ":" + seconds
    }
}
//화면에 보이는 모습과 행동을 담당(뷰의 동작과 모양 관리)
extension StopWatchViewController : UITableViewDelegate {
    //고정높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
//테이블을 만들때 필요한 정보와 데이터를 제공(데이터를 받아서 뷰를 그려주는 역할)
extension StopWatchViewController : UITableViewDataSource {
    
    //어떤 셀을 꺼내와서 보여줄 것인지? 어떤 내용을 셀에 담아서 보여줄 것인지?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StopwatchTableViewCell.identifier, for: indexPath) as? StopwatchTableViewCell else {return UITableViewCell()}
        cell.setData(laps, indexPath)
        return cell
    }
    //몇 개의 셀을 그릴 것인지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }
}
