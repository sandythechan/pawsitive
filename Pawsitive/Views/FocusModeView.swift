//
//  FocusModeView.swift
//  App
//
//  Created by Chan Ka Yu on 21/2/2025.
//

import SwiftUI
import UIKit
import Foundation
import UserNotifications

struct FocusModeView: View {
    @Binding var bloodline: Int
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userTarget: String = ""
    @State private var isFocusModeOn: Bool = false
    @State private var isBreak: Bool = false
    
    @State private var startTime: Date?
    @State private var resumeTime: TimeInterval = 0
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer?
    
    @State private var rotation: Double = 0
    
    @State private var buttonMode: ButtonMode = .start
    enum ButtonMode {
        case start
        case running
        case breakTime
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack{
                Color(red: 75/255, green: 78/255, blue: 61/255).ignoresSafeArea(.all)
                
                VStack{
                    if (!isFocusModeOn) {
                        Text("Focus Mode")
                            .font(.custom("Jersey25-Regular", size: 80))
                            .foregroundColor(Color(red: 246/255, green: 249/255, blue: 220/255))
                        Text("time to put down your phone \nand play with your dog !")
                            .font(.custom("Jersey25-Regular", size: 25))
                            .foregroundColor(Color(red: 246/255, green: 249/255, blue: 220/255))
                            .multilineTextAlignment(.center)
                    } else if (isFocusModeOn) {
                        Text(formatStopWatch(timeElapsed))
                            .font(.custom("Jersey25-Regular", size: 50))
                            .foregroundColor(Color(red: 246/255, green: 249/255, blue: 220/255))
                            .padding(.bottom, 20)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Button(action: {
                        switch buttonMode{
                        case .start:
                            isFocusModeOn=true
                            buttonMode = .running
                            startStopWatch()
                        case .running:
                            buttonMode = .breakTime
                            isBreak = true
                            stopStopWatch()
                        case .breakTime:
                            buttonMode = .running
                            isBreak = false
                            startStopWatch()
                        }
                    }) {
                        if (buttonMode == .start) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(Color(red: 42/255, green: 139/255, blue: 201/255))
                                    .padding()
                                    .frame(width: 370, height: 370)
                                    .overlay(
                                        VStack{
                                            Text("Start")
                                                .font(.custom("Jersey25-Regular", size: 90))
                                                .foregroundStyle(Color(red: 246/255, green: 249/255, blue: 220/255))
                                            
                                            Text("(enter your target to start)")
                                                .font(.custom("Jersey25-Regular", size: 28))
                                                .foregroundStyle(Color(red: 246/255, green: 249/255, blue: 220/255))
                                                .opacity(0.7)
                                        }
                                    )
                                
                                Image("focusing")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .offset(x: 0, y: -195) // start position
                            }
                        } else if (buttonMode == .running){
                            ZStack {
                                Circle()
                                    .foregroundStyle(Color(red: 244/255, green: 187/255, blue: 54/255))
                                    .padding()
                                    .frame(width: 350, height: 350)
                                    .overlay(
                                        Text("\(userTarget)")
                                            .font(.custom("Jersey25-Regular", size: 90))
                                            .minimumScaleFactor(0.4)
                                            .foregroundStyle(Color(red: 246/255, green: 249/255, blue: 220/255))
                                            .frame(alignment: .center)
                                        
                                    )
                                
                                Image("focusing")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .offset(x: 0, y: -175) // start position
                                    .rotationEffect(.degrees(rotation))
                                    .onAppear {
                                        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                                            rotation += 360
                                        }
                                    }
                            }
                        } else if(buttonMode == .breakTime) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(Color(red: 201/255, green: 74/255, blue: 42/255))
                                    .padding()
                                    .overlay(
                                        Text("Timer Stopped")
                                            .font(.custom("Jersey25-Regular", size: 90))
                                            .minimumScaleFactor(0.4)
                                            .foregroundStyle(Color(red: 246/255, green: 249/255, blue: 220/255))
                                            .frame(alignment: .center)
                                    )
                                
                                Image("break")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .offset(x: 0, y: -200)
                            }
                        }
                    }
                    .padding()
                    .disabled(userTarget.isEmpty)
                    
                    if (!isFocusModeOn) {
                        ZStack {
                            ZStack() {
                                if userTarget.isEmpty {
                                    Text("enter your target...")
                                        .foregroundColor(Color(red: 246/255, green: 249/255, blue: 220/255))
                                        .font(.custom("Jersey25-Regular", size: 40))
                                        .opacity(0.66)
                                        .underline()
                                }
                                
                                TextField("", text: $userTarget)
                                    .padding()
                                    .foregroundColor(Color(red: 246/255, green: 249/255, blue: 220/255))
                                    .font(.custom("Jersey25-Regular", size: 40))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        
                    } else if (isFocusModeOn && isBreak) {
                        Text("Take a Break...")
                            .foregroundColor(Color(red: 246/255, green: 249/255, blue: 220/255))
                            .font(.custom("Jersey25-Regular", size: 40))
                            .opacity(0.66)
                    }
                    
                    Button(action: {
                        isFocusModeOn=false
                        resetStopWatch()
                        userTarget=""
                        buttonMode = .start
                        showAlert = true
                    } ) {
                        if (isFocusModeOn) {
                            Rectangle()
                                .fill(Color(red: 246/255, green: 249/255, blue: 220/255))
                                .cornerRadius(50)
                                .frame(maxWidth: 220, maxHeight: 99)
                                .padding()
                                .overlay(
                                    Text("End")
                                        .font(.custom("Jersey25-Regular", size: 70))
                                        .foregroundStyle(Color.black)
                                )
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image("Arrow1")
                    .foregroundColor(.white)
                    .padding(.leading,0)
                    .offset(x: -10)
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Did u finish your target and play with your dog?"),
                    primaryButton: .default(Text("Yes")) {
                        if bloodline<6 {
                            bloodline+=1
                        }
                    },
                    secondaryButton: .default(Text("No")) {
                        if bloodline>0 {
                            bloodline-=1
                        }
                    }
                )
            }
        }
    }
        
    
    func startStopWatch() {
        if timer == nil {
            startTime = Date().addingTimeInterval(TimeInterval(-resumeTime))
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.timeElapsed = Int(Date().timeIntervalSince(self.startTime!))
            }
        }
    }
    
    func stopStopWatch() {
        timer?.invalidate()
        timer = nil
        
        if let start = startTime {
            resumeTime = Date().timeIntervalSince(start)
        }
    }
    
    func resetStopWatch() {
        stopStopWatch()
        timeElapsed = 0
        resumeTime = 0
    }
    
    func formatStopWatch(_ seconds: Int) -> String {
        let minutes = seconds/60
        let secondsRemain = seconds%60
        return String(format: "%02d:%02d", minutes, secondsRemain)
        
    }
}



struct FocusModeView_Preview: PreviewProvider {
    @State static var bloodline = 6  // Use @State here to make the bloodline modifiable in the preview
    
    static var previews: some View {
        FocusModeView(bloodline: $bloodline)  // Pass a binding to the bloodline
    }
}


// record of focusing time
