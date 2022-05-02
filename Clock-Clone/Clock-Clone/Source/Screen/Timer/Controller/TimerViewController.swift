//
//  TimerViewController.swift
//  Clock-Clone
//
//  Created by 한유진 on 2022/04/18.
//

import UIKit

class TimerViewController: UIViewController, CAAnimationDelegate {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmTime: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    let foreProgressLayer = CAShapeLayer()
    let backProgressLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    
    var isAnimationStarted = false
    var timer = Timer()
    var isTimerStarted = false
    var time = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButtonShape()
        initalizeButtons()
        beforeStartButton()
        drawBackLayer()
    }
    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: datePickerView.date)
    }
    private func beforeStartButton(){
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.5
        
        foreProgressLayer.isHidden = true
        backProgressLayer.isHidden = true
        
        alarmTime.isHidden = true
        timeLabel.isHidden = true
        
        datePicker.isHidden = false
    }
    private func afterStartButtonClicked(){
        cancelButton.isEnabled = true
        cancelButton.alpha = 1.0
        foreProgressLayer.isHidden = false
        backProgressLayer.isHidden = false
        alarmTime.isHidden = false
        timeLabel.isHidden = false
        
        datePicker.isHidden = true
    }
    private func initButtonShape(){
        initCircleButton(cancelButton)
        initCircleButton(startButton)
    }
    private func initalizeButtons() {
        cancelButton.isEnabled = false
        changeButton(button: cancelButton, title: "재설정", titleColor: .gray, backgroundColor: .darkGray)
        changeButton(button: startButton, title: "시작", titleColor: .systemGreen, backgroundColor: .green)
    }
    let initCircleButton : (UIButton) -> Void = {
        button
        in
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
    }
    //cancel눌러졌을때, textfield 글자 없어지게
    private func removeTextField() {
        [alarmTime,timeLabel].forEach {
            $0.text?.removeAll()
        }
    }
//    private func getLeftTimeToAlarm(alarmtime :DateFormatter) {
//        let date = NSDate() // 현재 시간 가져옴
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        let alarmTime = date as Date + alarmtime
//    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        stopAnimation()
        beforeStartButton()
        
        timer.invalidate()
        isTimerStarted = false
        time = Int(datePicker.countDownDuration)
        timeLabel.text = datePicker.date.formatted()
        removeTextField()
        changeButton(button: startButton, title: "시작", titleColor: .green, backgroundColor: .systemGreen)
    }
    @IBAction func startButtonTapped(_ sender: Any) {
        afterStartButtonClicked()
        if !isTimerStarted {
            startTimer()
            drawForeLayer()
            startResumeAnimation()
            isTimerStarted = true
            changeButton(button:startButton,title: "일시정지", titleColor: .orange ,backgroundColor: .systemOrange)
        }
        else {
            pauseAnimation()
            timer.invalidate() // 타이머 멈춤
            isTimerStarted = false
            changeButton(button: startButton, title: "재개", titleColor: .green, backgroundColor: .systemGreen)
        }
    }
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        time = Int(datePicker.countDownDuration)
    }
    @objc func updateTimer() {
        if time <= 1 {
            stopAnimation()
            beforeStartButton()
            changeButton(button: startButton, title: "시작", titleColor: .green, backgroundColor: .systemGreen)
            timer.invalidate()
            isTimerStarted = false
            time = Int(datePicker.countDownDuration)
        } else {
            time -= 1
            print(time)
            timeLabel.text = formatTime()
        }
        
    }
    private func formatTime() -> String{
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        return String(format : "%02i:%02i", hours, minutes)
    }
    private func changeButton(button: UIButton, title:String, titleColor : UIColor , backgroundColor : UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for:.normal)
        button.backgroundColor = backgroundColor
        button.titleLabel?.font = button.titleLabel?.font.withSize(5)
    }
    
    //background layer
    private func drawBackLayer() {
        backProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY - 150), radius: 140, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).cgPath
        backProgressLayer.strokeColor = UIColor.orange.cgColor
        backProgressLayer.fillColor = UIColor.clear.cgColor
        backProgressLayer.lineWidth = 10
        view.layer.addSublayer(backProgressLayer)
    }
    //forelayer
    private func drawForeLayer() {
        foreProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY - 150), radius: 140, startAngle: -90.degreesToRadians, endAngle: 270.degreesToRadians, clockwise: true).cgPath
        foreProgressLayer.strokeColor = UIColor.darkGray.cgColor
        foreProgressLayer.fillColor = UIColor.clear.cgColor
        foreProgressLayer.lineWidth = 10
        view.layer.addSublayer(foreProgressLayer)
    }
    
    private func startResumeAnimation() {
        if !isAnimationStarted {
            startAnimation()
        } else {
            resumeAnimation()
        }
    }
    
    private func startAnimation() {
        resetAnimation()
        foreProgressLayer.strokeEnd = 0.0
        animation.keyPath = "strokeEnd"
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = CFTimeInterval(Int(time))
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        foreProgressLayer.add(animation,forKey : "strokeEnd")
        isAnimationStarted = true
    }
    private func resetAnimation(){
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    private func pauseAnimation(){
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 0.0
        foreProgressLayer.timeOffset = pausedTime
    }
    private func resumeAnimation(){
        let pausedTime = foreProgressLayer.timeOffset
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        
        let timeSincePaused = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        foreProgressLayer.beginTime = timeSincePaused
    }
    private func stopAnimation(){
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        foreProgressLayer.removeAllAnimations()
        isAnimationStarted = false
    }
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
    
}
extension Int{
    var degreesToRadians : CGFloat{
        return CGFloat(self) * .pi / 180
    }
}
