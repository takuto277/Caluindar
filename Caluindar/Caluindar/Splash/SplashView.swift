//
//  SplashView.swift
//  Caluindar
//
//  Created by 小野拓人 on 2024/10/27.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opsity = 0.5
    
    var body: some View {
        if isActive {
            CalendarView()
        } else {
            VStack {
                VStack {
                    Image("splashImage")
                        .resizable()
                        .frame(width: 200, height: 200)
                }
                .scaleEffect(size)
                .opacity(opsity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opsity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
