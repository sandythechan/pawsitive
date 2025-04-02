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
    @Binding var selectedAMPM: [Bool]
    @Binding var selectedDays: [[String]]
    @Binding var selectedTimes: [String]
    @Binding var alarmSetTime: [String: (Int, Int)]
    var body: some View{
        VStack {
            Text("Alarm")
                .font(Font.custom("Jersey25-Regular",size: 60))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.top, 20)
                .foregroundColor(.white)
            
            Spacer()
                .frame(height:10)
            
            SetUpAlarm(
                selectedTime: $selectedTimes,
                selectedAMPM: $selectedAMPM,
                selectedDays: $selectedDays,
                alarmSetTime: $alarmSetTime
            )

            Spacer()
                .frame(height:0.1)
        }
    }
}

struct TimePicker: View {
    var label: String
    var hourSelection: Binding<Int>
    var minuteSelection: Binding<Int>
    var ampmSelection: Binding<Bool>
    var thisAlarm: Binding<Bool>
    
    var body: some View {
        HStack (spacing: 0){
            Toggle(label, isOn: thisAlarm)
                .toggleStyle(.button)
                .background(thisAlarm.wrappedValue ?
                            Color.yellow :
                                Color.gray)
                .cornerRadius(13)
                .font(Font.custom("Jersey25-Regular", size: 33))
                .foregroundColor(.white)
                .frame(width: 140, alignment: .leading)
                // .padding(.horizontal, 5)
            
            Picker("Hour", selection: hourSelection) {
                ForEach(1..<13, id: \.self) { hour in
                    Text(String(format: "%02d", hour))
                        .tag(hour)
                        .font(Font.custom("Jersey25-Regular",size: 40))
                        .foregroundColor(.white)
                    Text(" ")
                }
            }
            .frame(width: 65, height: 70)
            .clipped()
            .pickerStyle(WheelPickerStyle())
            
            Text(":")
                .font(Font.custom("Jersey25-Regular",size: 35))
                .foregroundColor(.white)
            
            Picker("Minute", selection: minuteSelection) {
                ForEach(0..<60, id: \.self) { minute in
                    Text(String(format: "%02d", minute))
                        .tag(minute)
                        .font(Font.custom("Jersey25-Regular",size: 40))
                        .foregroundColor(.white)
                    Text(" ")
                }
            }
            .frame(width: 65, height: 70)
            .clipped()
            .pickerStyle(WheelPickerStyle())
            
            Picker("AM/PM", selection: ampmSelection) {
                Text("AM").tag(true)
                    .font(Font.custom("Jersey25-Regular",size: 40))
                    .foregroundColor(.white)
                Text(" ")
                Text("PM").tag(false)
                    .font(Font.custom("Jersey25-Regular",size: 40))
                    .foregroundColor(.white)
            }
            .frame(width: 65, height: 70)
            .clipped()
            .pickerStyle(WheelPickerStyle())
        }
    }
}

struct SetUpAlarm: View {
    @State private var showAlert: Bool = false
    @State private var alarmType: String = "daily"

    @State private var alarmSetup: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    @State private var label_button: String = "set alarm"
    
    @State var alarm_daily = false
    @State var alarm_weekday = false
    @State var alarm_weekend = false
    
    // -------------
    
    @State var selectedHour: [Int] = [9,9,9]
    @State var selectedMinute: [Int] = [0,0,0]
    @Binding var selectedTime: [String]
    @Binding var selectedAMPM: [Bool] 
    @Binding var selectedDays: [[String]]
    @Binding var alarmSetTime: [String: (Int, Int)]
    @State var thisAlarm: [Bool] = [false, false, false] // which alarm is set
    
    @State var anySet: Bool = false
    
    let label = ["daily", "weekday", "weekend"]
    
    var body: some View {
        
        VStack (spacing: 0){
            
            ForEach(0..<3, id:\.self) { i in
                // $array[i] in swiftUI views does not create true binding
                // may not reflects changes properly -> use helper function to get Binding
                TimePicker(
                    label: label[i],
                    hourSelection: binding(array: $selectedHour, index: i),
                    minuteSelection: binding(array: $selectedMinute, index: i),
                    ampmSelection: binding(array: $selectedAMPM, index: i),
                    thisAlarm: binding(array: $thisAlarm, index: i)
                )
            }
            
            Button(action: {
                //action block : runs when button is tapped
                setAlarm()
            }) {
                // view block : builds UI appearance
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 200, height: 50)
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .overlay(
                        Text(label_button)
                            .font(Font.custom("Jersey25-Regular",size: 35))
                            .foregroundColor(.black)
                    )
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("Ok"))
                    )
                }
            }
            .padding(.top, 0)
        }
        
    // helper function : get the Binding for specific index
    func binding<T>(array: Binding<[T]>, index: Int) -> Binding<T> {
        return Binding<T>(
                get: { array.wrappedValue[index]},
                set: { array.wrappedValue[index] = $0}
        )
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
        anySet = false
        alertMessage = ""
        
        requestPermission()
     
        selectedDays[0] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        selectedDays[1] = ["Mon", "Tue", "Wed", "Thu", "Fri"]
        selectedDays[2] = ["Sat", "Sun"]
        
        // traditional for loop : control over index
        // ForEach : for SwiftUI views
        
        for i in 0..<3 {
            if (thisAlarm[i]) {
                anySet = true
                
                selectedTime[i] = formatAlarmTime(
                    hour: selectedHour[i],
                    minute: selectedMinute[i],
                    ampm: selectedAMPM[i] ? "AM" : "PM"
                )
                
                for day in selectedDays[i] {
                    alarmSetTime[day] = (selectedHour[i], selectedMinute[i])
                    scheduleNotification(for: day, index: i)
                }
                
                if (i<3) {
                    alertMessage += "\(label[i]) : \(selectedTime[i])!\n"
                } else {
                    alertMessage += "\(label[i]) : \(selectedTime[i])!"
                }
                
                showAlert = true
            }
        }
        
        if anySet {
            alertTitle = "Alarm Set!"
            label_button = "reset alarm"
            alertMessage += "\nHuman see u tmr morning 🐾"
        } else {
            alertTitle = "No Alarm Selected"
            label_button = "set alarm"
            alertMessage = "Click to choose daily, weekday or weekend alarm."
        }
        showAlert = true
    }
    
    func formatAlarmTime(hour: Int, minute: Int, ampm: String) -> String {
        let formattedHour = String(format: "%02d", hour)
        let formattedMinute = String(format: "%02d", minute)
        return "\(formattedHour):\(formattedMinute) \(ampm)"
    }

    
    func scheduleNotification(for day: String, index: Int) {
        
        let content = UNMutableNotificationContent()
        content.title = "Time To Wake Up!"
        content.body = "It is time to walk your dog"
        content.sound = UNNotificationSound.default
        
        var hour = selectedHour[index]
        
        if !selectedAMPM[index] && hour != 12 {
                hour += 12
        } else if selectedAMPM[index] && hour == 12 {
                hour = 0
        }
        
        var components = DateComponents()
        components.hour = hour
        components.minute = selectedMinute[index]
        
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
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "alarm_\(day)_\(index)",
            content: content,
            trigger: trigger
        )
        
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
    
    @Binding var selectedDays: [[String]]
    @Binding var selectedTimes: [String]
    @Binding var selectedAMPM: [Bool]
    @Binding var alarmSetTime: [String: (Int, Int)]
    
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
                            .overlay(AlarmSection(
                                selectedAMPM: $selectedAMPM,
                                selectedDays: $selectedDays,
                                selectedTimes: $selectedTimes,
                                alarmSetTime: $alarmSetTime
                                )
                            )
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
    
    @State static var selectedDays: [[String]] = [[],[],[]]
    @State static var selectedTimes: [String] = ["09:00 AM", "09:00 AM", "09:00 AM"]
    @State static var selectedAMPM: [Bool] = [true, true, true]
    @State static var alarmSetTime: [String: (Int, Int)] = [:]
    // preview provider : static structure

    static var previews: some View {
        SleepModeView(
            bloodline: $bloodline,
            markedDays: $markedDays,
            selectedDays: $selectedDays,
            selectedTimes: $selectedTimes,
            selectedAMPM: $selectedAMPM,
            alarmSetTime: $alarmSetTime
        )
    }
}

// text : alarm is set | button : reset alarm
// show the time set
// notification : Human see u tmr morning!
// reset alarm no -> reset the unselected
