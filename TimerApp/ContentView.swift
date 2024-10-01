//
//  ContentView.swift
//  TimerApp
//
//  Created by 清水敬貴 on 2024/08/21.
//

import SwiftUI
import UIKit

struct TimerViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> TimerViewController {
        return TimerViewController()
    }
    
    func updateUIViewController(_ uiViewController: TimerViewController, context: Context) {
        // 必要に応じて更新ロジックを記述
    }
}

struct ContentView: View {
    var body: some View {
        TimerViewControllerRepresentable() // UIKitのViewControllerをSwiftUIで使う
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}

