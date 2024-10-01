//
//  TimerViewController.swift
//  TimerApp
//
//  Created by 清水敬貴 on 2024/08/21.
//

import UIKit
import AVFoundation


class TimerViewController: UIViewController {

    // UI Elements
    var timerLabel: UILabel!
    var startPauseButton: UIButton!
    var resetButton: UIButton!
    var bellButton: UIButton!
    var intervalTextFields: [UITextField] = []
    var audioPlayer: AVAudioPlayer?

    
    // タイマー管理用変数
    var timer: Timer?
    var totalTime = 0
    var isTimerRunning = false
    var bellTimes = [Int]()
    var bellIndex = 0
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("オーディオセッションの設定に失敗しました: \(error.localizedDescription)")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UIのセットアップ
        setupAudioSession() // オーディオセッションのセットアップ
    }
    
    // UIを設定する関数
    func setupUI() {
        view.backgroundColor = .white
        
        // Timer Label
        timerLabel = UILabel()
        timerLabel.text = "00:00"
        timerLabel.font = UIFont.systemFont(ofSize: 60)//ここの数字を変更すると文字の大きさが変わる
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)
        
        // インターバルを入力するTextFieldを3つ作成
        for _ in 0..<5 {
            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.placeholder = "ベルタイミング (秒)"
            textField.keyboardType = .numberPad
            textField.translatesAutoresizingMaskIntoConstraints = false
            intervalTextFields.append(textField)
            view.addSubview(textField)
        }
        
        // Start/Pause Button
        startPauseButton = UIButton(type: .system)
        startPauseButton.setTitle("開始", for: .normal)
        startPauseButton.setTitleColor(.red, for: .normal)
        startPauseButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)//ここの数字を変更すると文字の大きさが変わる
        startPauseButton.translatesAutoresizingMaskIntoConstraints = false
        startPauseButton.addTarget(self, action: #selector(startPauseTapped), for: .touchUpInside)
        view.addSubview(startPauseButton)
        
        // Reset Button
        resetButton = UIButton(type: .system)
        resetButton.setTitle("リセット", for: .normal)
        resetButton.setTitleColor(.blue, for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)//ここの数字を変更すると文字の大きさが変わる
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        view.addSubview(resetButton)
        
        // Bell Button with Icon
        bellButton = UIButton(type: .system)
        bellButton.setTitle("🛎️", for: .normal)
        bellButton.titleLabel?.font = UIFont.systemFont(ofSize: 60)//ここの数字を変更すると文字の大きさが変わる
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        view.addSubview(bellButton)
        
        layoutUI() // UIのレイアウトを設定
    }
    
    // UIのレイアウト設定
    func layoutUI() {
        // Timer Labelのレイアウト
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 各インターバル用TextFieldのレイアウト
        for (index, textField) in intervalTextFields.enumerated() {
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: CGFloat(40 + index * 50)),
                textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                textField.widthAnchor.constraint(equalToConstant: 200)
            ])
        }
        
        // Start/Pause Buttonのレイアウト
        NSLayoutConstraint.activate([
            startPauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            startPauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40)
        ])
        
        // Reset Buttonのレイアウト
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        // Bell Buttonのレイアウト
        NSLayoutConstraint.activate([
            bellButton.bottomAnchor.constraint(equalTo: startPauseButton.topAnchor, constant: -30),
            bellButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // タイマーの開始/停止
    @objc func startPauseTapped() {
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    // タイマーのリセット
    @objc func resetTapped() {
        timer?.invalidate()
        totalTime = 0
        isTimerRunning = false
        bellIndex = 0
        startPauseButton.setTitle("開始", for: .normal)
        updateTimerLabel()
    }
    
    //音を再生
    func playBellSound() {
        guard let url = Bundle.main.url(forResource: "motenai", withExtension: "m4a") else { return } // nmuri.m4aを再生

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("音声ファイルのURL: \(url)")
        } catch {
            print("音声ファイルの再生に失敗しました: \(error)")
        }
    }
    
    //音ver2を再生
    func playBellSound2() {
        guard let url = Bundle.main.url(forResource: "kibisii", withExtension: "m4a") else { return } // gatishonbenn.m4aを再生

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("音声ファイルのURL: \(url)")
        } catch {
            print("音声ファイルの再生に失敗しました: \(error)")
        }
    }

    
    // ベルを鳴らす
    @objc func bellTapped() {
        playBellSound2() // 音を鳴らす関数を呼び出す
        print("🛎️ 手動でベルが鳴りました！")
    }
    
    // タイマーの開始
    func startTimer() {
        bellTimes = intervalTextFields.compactMap { Int($0.text ?? "") }
        bellIndex = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isTimerRunning = true
        startPauseButton.setTitle("一時停止", for: .normal)
    }
    
    // タイマーの停止
    func pauseTimer() {
        timer?.invalidate()
        isTimerRunning = false
        startPauseButton.setTitle("開始", for: .normal)
    }
    
    // タイマーの更新
    @objc func updateTimer() {
        totalTime += 1
        updateTimerLabel()
        
        if bellIndex < bellTimes.count && totalTime == bellTimes[bellIndex] {
            playBellSound() // 音を鳴らす関数を呼び出す
            print("🛎️ \(bellIndex + 1)回目のベルが鳴りました！")
            bellIndex += 1
        }
    }
    
    // タイマーラベルを更新
    func updateTimerLabel() {
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}
