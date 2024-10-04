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
    // [時, 分, 秒]の配列
    var intervalTextFields: [[UITextField]] = []

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
        // UIのセットアップ
        setupUI()

        // オーディオセッションのセットアップ
        setupAudioSession()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Timer Label
        timerLabel = UILabel()
        timerLabel.text = "00:00:00"
        // Fontの設定
        timerLabel.font = UIFont.systemFont(ofSize: 60)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)

        // 各インターバル用のTextField (時, 分, 秒)を5つ作成
        for _ in 0..<5 {
            var timeFields: [UITextField] = []

            // "時" TextField
            let hoursField = createTextField(placeholder: "時")
            timeFields.append(hoursField)

            // "分" TextField
            let minutesField = createTextField(placeholder: "分")
            timeFields.append(minutesField)

            // "秒" TextField
            let secondsField = createTextField(placeholder: "秒")
            timeFields.append(secondsField)

            intervalTextFields.append(timeFields)

            // 各フィールドをビューに追加
            view.addSubview(hoursField)
            view.addSubview(minutesField)
            view.addSubview(secondsField)
        }
        
        // Start/Pause Button
        startPauseButton = UIButton(type: .system)
        startPauseButton.setTitle("開始", for: .normal)
        startPauseButton.backgroundColor = UIColor.systemBlue
        startPauseButton.tintColor = .white
        startPauseButton.layer.cornerRadius = 10
        startPauseButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        startPauseButton.translatesAutoresizingMaskIntoConstraints = false
        startPauseButton.addAction(
            UIAction { [weak self] _ in self?.startPauseTapped() },
            for: .touchUpInside
        )
        view.addSubview(startPauseButton)
        
        // Reset Button
        resetButton = UIButton(type: .system)
        resetButton.setTitle("リセット", for: .normal)
        resetButton.backgroundColor = UIColor.systemRed
        resetButton.tintColor = .white
        resetButton.layer.cornerRadius = 10
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addAction(
            UIAction { [weak self] _ in self?.resetTapped() },
            for: .touchUpInside
        )
        view.addSubview(resetButton)
        
        // Bell Button with Icon
        bellButton = UIButton(type: .system)
        bellButton.setTitle("🛎️", for: .normal)
        bellButton.titleLabel?.font = UIFont.systemFont(ofSize: 60)
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        bellButton.addAction(UIAction { [weak self] _ in self?.bellTapped() }, for: .touchUpInside)
        view.addSubview(bellButton)
        
        setupLayoutUI()
    }
    
    // UIのレイアウト設定
    private func setupLayoutUI() {
        // Timer Labelのレイアウト
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // スタートボタンの幅と高さの制約を追加
        NSLayoutConstraint.activate([
            startPauseButton.widthAnchor.constraint(equalToConstant: 100),
            startPauseButton.heightAnchor.constraint(equalToConstant: 50),
        ])

        // リセットボタンの幅と高さの制約を追加
        NSLayoutConstraint.activate([
            resetButton.widthAnchor.constraint(equalToConstant: 100),
            resetButton.heightAnchor.constraint(equalToConstant: 50),
        ])

        // 各インターバル用TextField (時, 分, 秒) のレイアウト
        for (index, timeFields) in intervalTextFields.enumerated() {
            let yOffset = CGFloat(40 + index * 50)

            NSLayoutConstraint.activate([
                timeFields[0].topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: yOffset),
                timeFields[0].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                timeFields[0].widthAnchor.constraint(equalToConstant: 60),

                timeFields[1].topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: yOffset),
                timeFields[1].centerXAnchor.constraint(equalTo: view.centerXAnchor),
                timeFields[1].widthAnchor.constraint(equalToConstant: 60),

                timeFields[2].topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: yOffset),
                timeFields[2].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                timeFields[2].widthAnchor.constraint(equalToConstant: 60)
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
    
    // TextFieldを生成する共通の関数
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    // タイマーの開始/停止
    private func startPauseTapped() {
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    // タイマーのリセット
    private func resetTapped() {
        timer?.invalidate()
        totalTime = 0
        isTimerRunning = false
        bellIndex = 0
        startPauseButton.setTitle("開始", for: .normal)
        updateTimerLabel()
    }
    
    // 音を再生
    private func playBellSound() {
        guard let url = Bundle.main.url(forResource: "bell2", withExtension: "m4a") else { return } // bell2.m4aを再生

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("音声ファイルのURL: \(url)")
        } catch {
            print("音声ファイルの再生に失敗しました: \(error)")
        }
    }
    
    // 音ver2を再生
    private func playBellSound2() {
        guard let url = Bundle.main.url(forResource: "bell1", withExtension: "m4a") else { return } // bell1.m4aを再生

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("音声ファイルのURL: \(url)")
        } catch {
            print("音声ファイルの再生に失敗しました: \(error)")
        }
    }

    
    // ベルを鳴らす
    private func bellTapped() {
        // 音を鳴らす関数を呼び出す
        playBellSound2()
        print("🛎️ 手動でベルが鳴りました！")
    }
    
    // タイマーの開始
    private func startTimer() {
        bellTimes = intervalTextFields.compactMap { fields in
            let hours = Int(fields[0].text ?? "0") ?? 0
            let minutes = Int(fields[1].text ?? "0") ?? 0
            let seconds = Int(fields[2].text ?? "0") ?? 0
            return hours * 3600 + minutes * 60 + seconds
        }
        bellIndex = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isTimerRunning = true
        startPauseButton.setTitle("一時停止", for: .normal)
    }
    
    // タイマーの停止
    private func pauseTimer() {
        timer?.invalidate()
        isTimerRunning = false
        startPauseButton.setTitle("開始", for: .normal)
    }
    
    // タイマーの更新
    @objc func updateTimer() {
        totalTime += 1
        updateTimerLabel()
        
        if bellIndex < bellTimes.count && totalTime == bellTimes[bellIndex] {
            // 音を鳴らす関数を呼び出す
            playBellSound()
            print("🛎️ \(bellIndex + 1)回目のベルが鳴りました！")
            bellIndex += 1
        }
    }
    
    // タイマーラベルを更新
    private func updateTimerLabel() {
        let hours = totalTime / 3600
        let minutes = (totalTime % 3600) / 60
        let seconds = totalTime % 60
        timerLabel.text = String(format: "%02d:%02d:%02d",hours, minutes, seconds)
    }
}
