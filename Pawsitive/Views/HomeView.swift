//
//  SwiftUIView.swift
//  App
//
//  Created by Chan Ka Yu on 21/2/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var bloodline: Int = 6
    @State private var checkIn: Bool = false
    @State private var showAlert1: Bool = false
    @State private var showAlert2: Bool = false
    @State private var showAlertExceedTime: Bool = false
    @State private var markedDays: Set<Int> = []
    
    @State private var lastPressedDate: Date? = nil
    @State private var alarmTime: Date? = nil
    @State private var selectedDays : [String] = []
    @State private var selectedTimes : [String: (Int, Int)] = [:]
    @State private var selectedAMPM: Bool = true
    @State private var buttonPressedToday = false
    

    var body: some View {
            NavigationStack {
            //main container that enables navigation
                ZStack{
                /*can overlay multiple views on top of each other*/
                    Color(red: 244/255, green: 187/255, blue: 54/255).edgesIgnoringSafeArea(.all)
                    
                    VStack{
                        //button to go to sleep mode
                        NavigationLink(destination:
                            
                                        SleepModeView(bloodline: $bloodline, markedDays: $markedDays, selectedDays: $selectedDays, selectedTimes: $selectedTimes, selectedAMPM: $selectedAMPM)){
                            Rectangle()
                                .fill(Color(red: 42/255, green: 139/255, blue: 201/255))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(61)
                                .overlay(
                                    HStack{
                                        
                                        VStack (alignment: .leading) {
                                            Text("Sleep")
                                                .font(Font.custom("Jersey25-Regular",size: 60))
                                                .font(.largeTitle).bold()
                                            Text("Mode").font(.largeTitle).bold()
                                        }
                                        .padding(.leading, 20)
                                        
                                        Spacer()
                                        
                                        Image("sleeping2")
                                            .resizable()
                                            .scaledToFit()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 180, height: 200)
                                            .clipped()
                                    }.padding(.horizontal)
                                )
                                .padding()
                        }.buttonStyle(PlainButtonStyle())
                        
                        
                        Spacer()
                            .frame(height:10)
                        
                        //button to go to sleep mode
                        NavigationLink(destination: FocusModeView(bloodline: $bloodline)) {
                            Rectangle()
                                .fill(Color(red: 201/255, green: 74/255, blue: 42/255))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .cornerRadius(61)
                                .overlay(
                                    HStack{
                                        VStack (alignment: .leading) {
                                            Text("Focus")           .font(Font.custom("Jersey25-Regular",size: 60))                 .font(.largeTitle).bold()
                                            Text("Mode").font(.largeTitle).bold()
                                        }
                                        .padding(.leading, 20)
                                        
                                        Spacer()
                                        
                                        Image("focusMode")
                                            .resizable().scaledToFit()
                                    }.padding(.horizontal)
                                )
                                .padding()
                        }.buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                            .frame(height: 30)
                        
                        HStack (spacing: 5){
                            
                            ForEach(0..<3, id: \.self) { index in
                                Rectangle()
                                    .fill(index < bloodline ? Color(red: 194/255, green: 69/255, blue: 15/255): Color.white)
                                    .frame(width: 30, height:68)
                                    .cornerRadius(20)
                                
                                Spacer()
                                    .frame(width: 5)
                                
                            }
                            
                            /*
                             ForEach(data, id: \.self) { item in }
                             data : 0..<5 == 0 to 4
                             */
                            
                            Button(action: {
                                checkInStatus()
                               
                            } ) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width:89, height: 89)
                                    .overlay(
                                        Image("dogIcon").resizable().scaledToFit())
                            }
                            .alert(isPresented: $showAlert1) {
                                Alert(
                                    title: Text("Already Checked In"),
                                    message: Text("You have already checked in today and walked your dog!"),
                                    dismissButton: .default(Text("OK")))
                            }
                            
                            Spacer()
                                .frame(width: 5)
                            
                            ForEach(0..<3, id: \.self) { index in
                                Rectangle() 
                                    .fill(index < (bloodline-3) ? Color(red: 194/255, green: 69/255, blue: 15/255) : Color.white)
                                    .frame(width: 30, height:68)
                                    .cornerRadius(20)
                                    .cornerRadius(20)
                                Spacer()
                                    .frame(width: 5)
                                
                            }
                        }
                    }.alert(isPresented: $showAlert2) {
                        Alert(
                            title: Text("go for a walk with dog!"),
                            message: Text("successfully woke up and \ntime to go for a walk with your dog!"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    .alert(isPresented: $showAlertExceedTime) {
                        Alert(title: Text("You are late!"),
                              message: Text("You fail to walk your dog on time! \n The bloodlne of your dog will decrease"),
                              dismissButton: .default(Text("OK")))
                    }
                    
                }
            }
        }
    
    func checkInStatus() {
        let now = Date()
        
        for day in selectedDays {
            guard let time = selectedTimes[day] else { continue }
            
            var components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: now)
            
            switch day {
            case "Mon": components.weekday = 2
            case "Tue": components.weekday = 3
            case "Wed": components.weekday = 4
            case "Thu": components.weekday = 5
            case "Fri": components.weekday = 6
            case "Sat": components.weekday = 7
            case "Sun": components.weekday = 1
            default: break
            }
            
            var alarmHour = time.0
            if !selectedAMPM && alarmHour != 12 {  // PM case
                alarmHour += 12
            } else if selectedAMPM && alarmHour == 12 { // AM case
                alarmHour = 0
            }
            
            components.hour = alarmHour
            components.minute = time.1
            
            alarmTime = Calendar.current.date(from: components)
            
            if let alarmTime = alarmTime {
                let timeDifference = now.timeIntervalSince(alarmTime)
                
                if timeDifference >= 0 && timeDifference <= 900 {
                    if buttonPressedToday {
                        showAlert1 = true
                        if bloodline<6 {
                            bloodline+=1
                        }
                    } else {
                        markedDays.insert(Calendar.current.component(.day, from: now))
                        lastPressedDate = now
                        showAlert1=false
                        showAlert2=true
                        buttonPressedToday = true
                    }
                } else {
                    if bloodline>0 && !buttonPressedToday{
                        bloodline-=1
                        buttonPressedToday = true
                        showAlertExceedTime = true
                    }
                    showAlert1 = true
                }
            }
        }
    
    }
}

#Preview {
    HomeView()
}
