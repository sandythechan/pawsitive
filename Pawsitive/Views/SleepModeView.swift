//
//  SleepModeView.swift
//  App
//
//  Created by Chan Ka Yu on 21/2/2025.
//

import SwiftUI
import Foundation
import UserNotifications

struct AlarmSection: View{
    @Binding var selectedDays: [String]
    @Binding var selectedTimes: [String: (Int, Int)]
    @Binding var selectedAMPM: Bool
    
    var body: some View{
        VStack {
            Text("Alarm")
                .font(Font.custom("Jersey25-Regular",size: 60))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
                .foregroundColor(.white)
            
            Spacer()
                .frame(height:10)
            
            SetUpAlarm(selectedDays: $selectedDays, selectedTimes: $selectedTimes, selectedAMPM: $selectedAMPM)
            
            Spacer()
                .frame(height:0.1)
        }
    }
}

struct SetUpAlarm: View {
    @State private var selectedHour = 9
    @State private var selectedMinute = 0
    @State private var showAlert: Bool = false
    @State private var alarmType: String = "daily"
    
    @Binding var selectedDays: [String]
    @Binding var selectedTimes: [String: (Int, Int)]
    @Binding var selectedAMPM: Bool

    @State private var alarmSetup: Bool = false
    @State private var alertMessage: String = ""
    
    let daily = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        
        VStack (spacing: 0){
            HStack (spacing: 0){
                //variable input by user
                
                Picker("Hour", selection: $selectedHour) {
                    ForEach(1..<13, id: \.self) { hour in
                        Text(String(format: "%02d", hour))
                            .tag(hour)
                            .font(Font.custom("Jersey25-Regular",size: 80))
                            .foregroundColor(.white)
                        Text(" ")
                    }
                }
                .frame(width: 100, height: 150)
                .clipped()
                .pickerStyle(WheelPickerStyle())
                
                Text(":")
                    .font(Font.custom("Jersey25-Regular",size: 80))
                    .foregroundColor(.white)
                
                Picker("Minute", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text(String(format: "%02d", minute))
                            .tag(minute)
                            .font(Font.custom("Jersey25-Regular",size: 80))
                            .foregroundColor(.white)
                        Text(" ")
                    }
                }
                .frame(width: 100, height: 150)
                .clipped()
                .pickerStyle(WheelPickerStyle())
                
                
                Picker("AM/PM", selection: $selectedAMPM) {
                    Text("AM").tag(true)
                        .font(Font.custom("Jersey25-Regular",size: 80))
                        .foregroundColor(.white)
                    Text(" ")
                    Text("PM").tag(false)
                        .font(Font.custom("Jersey25-Regular",size: 80))
                        .foregroundColor(.white)
                }
                .frame(width: .infinity, height: 150)
                .clipped()
                .pickerStyle(WheelPickerStyle())
            }
            .padding(.horizontal)
            
            HStack {
                Picker("Alarm Type", selection: $alarmType) {
                    Text("daily").tag("daily")
                    Text("weekday").tag("weekday")
                    Text("weekend").tag("weekend")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 10)
            .padding()
            
            Button(action: {
                setAlarm()
            }) {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 200, height: 50)
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .overlay(
                        Text("set alarm")
                            .font(Font.custom("Jersey25-Regular",size: 35))
                            .foregroundColor(.black)
                    )
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Alarm Set!"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
        .padding(.top, 0)
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Permission Error: \(error)")
                return
            }
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }
    
    func setAlarm() {
        requestPermission()
        
        switch alarmType {
        case "weekday":
            selectedDays = ["Mon", "Tue", "Wed", "Thu", "Fri"]
        case "weekend":
                    selectedDays = ["Sat", "Sun"]
        case "daily":
                    selectedDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        default:
            break
        }
        
        for day in selectedDays {
            selectedTimes[day] = (selectedHour, selectedMinute)
        }
        
        for day in selectedDays {
            scheduleNotification(for: day)
        }
        
        let ampm = selectedAMPM ? "AM" : "PM"
        let formattedTime = formatAlarmTime(hour: selectedHour, minute: selectedMinute, ampm:ampm)
        alertMessage = "Set alarm at \(formattedTime)!"
        showAlert = true
    }
    
    func formatAlarmTime(hour: Int, minute: Int, ampm: String) -> String {
        let formattedHour = String(format: "%02d", hour)
        let formattedMinute = String(format: "%02d", minute)
        return "\(formattedHour):\(formattedMinute) \(ampm)"
    }

    
    func scheduleNotification(for day: String) {
        
        let content = UNMutableNotificationContent()
        content.title = "Time To Wake Up!"
        content.body = "It is time to walk your dog"
        content.sound = UNNotificationSound.default
        
        var hour = selectedHour
        
        if !selectedAMPM && hour != 12 {
                hour += 12
        } else if selectedAMPM && hour == 12 {
                hour = 0
        }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute, .weekday], from: Date())
        
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
        
        components.hour = hour
        components.minute = selectedMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "alarm_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(day)!")
            }
        }
    }
        
}

struct WalkSection: View {
    let daily = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @Binding var markedDays: Set<Int>
    
    var body: some View {
        VStack{
            
            Text("Go for a walk ?")
                .font(Font.custom("Jersey25-Regular",size: 50))
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 50)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)) {
                ForEach(daily, id: \.self) {day in
                    Text(day)
                        .font(Font.custom("Jersey25-Regular",size: 29))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal)
            .padding(.bottom,0)
            
            CalendarView(markedDays: $markedDays)
                .frame(maxWidth: .infinity, maxHeight: 400)
                .padding(.top, 0)
        }
    }
}

struct CalendarView: View {
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    @Binding var markedDays: Set<Int>
    
    @State private var selectedTab = 0;
    
    var body: some View {
        TabView(selection: $selectedTab){
            ForEach(0..<months.count, id: \.self) { monthIndex in
                //let numberOfDays = getDaysInMonth(forMonth: monthIndex + 1)
                let weeksInMonth = getWeeksInMonth(forMonth: monthIndex + 1)
                /*let numberOfWeeks = weeksInMonth?.count*/
                VStack (spacing: 10){
                    Text("\(months[monthIndex])")
                        .font(Font.custom("Jersey25-Regular",size: 35))
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 0)
                        .underline()
                    
                    if let weeksInMonth = weeksInMonth {
                        ForEach(0..<weeksInMonth.count, id: \.self){ rowIndex in
                            ZStack{
                                Rectangle()
                                    .fill(Color(red: 217/255, green: 217/255, blue: 217/255))
                                    .frame(height: 30)
                                    .cornerRadius(20)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)){
                                    ForEach(weeksInMonth[rowIndex], id: \.self){ dayIndex in
                                        if markedDays.contains(dayIndex) {
                                            Image("Tick")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 35, height:35)
                                                .scaleEffect(1.5)
                                        } else {
                                            Text(dayIndex > 0 ? "\(dayIndex)": "")

                                                .font(Font.custom("Jersey25-Regular",size: 35))
                                                .bold()
                                                .foregroundColor(.black)
                                                .padding(2)
                                        }
                                        
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
    
    
    let currentYear = Calendar.current.component(.year, from: Date())
    // get number of days each month + start day
    func getDaysInMonth(forMonth month: Int) -> Int? {
        
        let dateComponents = DateComponents(year: currentYear, month: month)
        if let date = Calendar.current.date(from: dateComponents),
           let range = Calendar.current.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return nil
    }
    
    func getWeeksInMonth(forMonth month: Int) -> [[Int]]? {
        
        let dateComponents = DateComponents(year: currentYear, month: month, day: 1)
        if let firstDayofMonth = Calendar.current.date(from: dateComponents),
           let range = Calendar.current.range(of: .day, in: .month, for: firstDayofMonth) {
            let firstWeekDay = Calendar.current.component(.weekday, from: firstDayofMonth)
            
            var weeks: [[Int]] = []
            var currentWeek: [Int] = []
            var currentDay = 1
            
            for _ in 1..<firstWeekDay {
                currentWeek.append(0)
            }
            
            while currentDay <= range.count {
                currentWeek.append(currentDay)
                if currentWeek.count == 7 {
                    weeks.append(currentWeek)
                    currentWeek = []
                }
                currentDay += 1
            }
            
            if !currentWeek.isEmpty {
                weeks.append(currentWeek)
            }
            
            return weeks
        }
        return nil
    }
}
    
struct SleepModeView: View {
    @Binding var bloodline: Int
    @Binding var markedDays: Set<Int>
    
    @Binding var selectedDays: [String]
    @Binding var selectedTimes: [String: (Int, Int)]
    @Binding var selectedAMPM: Bool
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationStack {
            ZStack{
                Color(red: 244/255, green: 187/255, blue: 54/255).edgesIgnoringSafeArea(.all)
                
                ScrollView{
                    VStack (spacing: 30){
                        Rectangle()
                            .fill(Color(red:75/255, green: 78/255, blue: 61/255))
                            .cornerRadius(61)
                            .frame(minHeight: 450)
                            .overlay(AlarmSection(selectedDays: $selectedDays, selectedTimes: $selectedTimes, selectedAMPM: $selectedAMPM))
                            .padding(.horizontal)

                        Rectangle()
                            .fill(Color(red:75/255, green: 78/255, blue: 61/255))
                            .cornerRadius(61)
                            .frame(minHeight: 550)
                            .overlay(WalkSection(markedDays: $markedDays))
                            .padding(.horizontal)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image("Arrow")
                    .foregroundColor(.white)
                    .padding(.leading,0)
                    .offset(x: -10)
            })
        }
    }
}
    
struct SleepModeView_Preview: PreviewProvider {
    @State static var bloodline = 6
    @State static var markedDays: Set<Int> = []
    
    @State static var selectedDays: [String] = []
    @State static var selectedTimes: [String: (Int, Int)] = [:]
    @State static var selectedAMPM: Bool = true

    static var previews: some View {
        SleepModeView(bloodline: $bloodline, markedDays: $markedDays, selectedDays: $selectedDays, selectedTimes: $selectedTimes, selectedAMPM: $selectedAMPM)
    }
}

// block the time and change the button to "alarm set"
// text : alarm is set | button : reset alarm
// show the time set
