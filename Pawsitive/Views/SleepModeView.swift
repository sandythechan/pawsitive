//
//  SleepModeView.swift
//  App
//
//  Created by Chan Ka Yu on 21/2/2025.
//

import SwiftUI
import Foundation
import UserNotifications

class AlarmSetting : ObservableObject {
    @Published var alarmSetTime: [String: (Int, Int)] = [:]
    //@Published var selectedDays: [[String]]
    
}

struct AlarmSection: View{
    @Binding var selectedAMPM: [Bool]
    @Binding var selectedDays: [[String]]
    @Binding var selectedTime: [String]
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
                selectedTime: $selectedTime,
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
    @Binding var AlarmSet: Bool
    
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
                .disabled(AlarmSet)
                // .padding(.horizontal, 5)
            
            Picker("Hour", selection: hourSelection) {
                ForEach(1..<13, id: \.self) { hour in
                    Text(String(format: "%02d", hour))
                        .tag(hour)
                        .font(Font.custom("Jersey25-Regular",size: 40))
                        .foregroundColor(.white)                }
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
                }
            }
            .frame(width: 65, height: 70)
            .clipped()
            .pickerStyle(WheelPickerStyle())
            
            Picker("AM/PM", selection: ampmSelection) {
                Text("AM").tag(true)
                    .font(Font.custom("Jersey25-Regular",size: 40))
                    .foregroundColor(.white)
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
    @State var AlarmSet = false
    @State var permissionReject = false
    
    @State var anySet: Bool = false
    
    let label = ["daily", "weekday", "weekend"]
    
    var body: some View {
        
        VStack (spacing: 0){
            
            ForEach(0..<3, id:\.self) { i in
                // $array[i] in swiftUI views does not create true binding
                // may not reflects changes properly -> use helper function to get Binding
                TimePicker(
                    label: label[i],
                    hourSelection: $selectedHour[i],
                    minuteSelection: $selectedMinute[i],
                    ampmSelection: $selectedAMPM[i],
                    thisAlarm: $thisAlarm[i],
                    AlarmSet: $AlarmSet
                )
            }
            
            Button(action: {
                //action block : runs when button is tapped
                setAlarm()
                //AlarmSet.toggle()
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
                    if permissionReject {
                        return Alert(
                            title: Text("Enable Notifications"),
                            message: Text("Enable notifications in settings to receive your alarm"),
                            primaryButton:. default(Text("Go to Settings")) {
                                if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                                    UIApplication.shared.canOpenURL(settingsURL) {
                                        UIApplication.shared.open(settingsURL)
                                    }
                            },
                            secondaryButton: .cancel()
                     
                        )
                    } else if AlarmSet && !anySet{ // reset alarm
                        return Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            primaryButton: .destructive(Text("Yes")) {
                                AlarmSet = false
                                anySet = false
                                for i in 0..<thisAlarm.count {
                                    thisAlarm[i] = false
                                // further mechanism is needed
                                // like time
                                }
                            },
                            secondaryButton: .cancel(Text("No"))
                        )
                    } else { // no alarm / alarm set
                        return Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("Ok")) {
                                AlarmSet = true
                            }
                            
                        )
                    }
                    
                }
            }
            .padding(.top, 0)
        }
    
    func setAlarm() {
        anySet = false
        alertMessage = ""
            
        requestPermission(completionHandler: {})
        // completionHandler : closure parameter - pass to function
     
        selectedDays[0] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        selectedDays[1] = ["Mon", "Tue", "Wed", "Thu", "Fri"]
        selectedDays[2] = ["Sat", "Sun"]
        
        // traditional for loop : control over index
        // ForEach : for SwiftUI views
        
        for i in 0..<3 {
            if (thisAlarm[i]) {
                anySet = true
                
                for day in selectedDays[i] {
                    alarmSetTime[day] = (selectedHour[i]+1, selectedMinute[i])
                    scheduleNotification(for: day, index: i)
                }
                
                let hour = String(format:"%02d", selectedHour[i])
                let minute = String(format:"%02d", selectedMinute[i])
                let ampm = selectedAMPM[i] ? "AM" : "PM"
                
                if (i<3) {
                    alertMessage += "\(label[i]) : \(hour):\(minute) \(ampm)!\n"
                } else {
                    alertMessage += "\(label[i]) : \(hour):\(minute) \(ampm)!\n"
                }
                
                showAlert = true
            }
        }
        
        if (anySet && !AlarmSet) {
            alertTitle = "Alarm Set!"
            label_button = "reset alarm"
            alertMessage += "\nHuman see u soon 🐾"
        } else if (AlarmSet) {
            alertTitle = "Reset your alarm?"
            label_button = "reset alarm"
            alertMessage = "Do you want to reset your alarm?"
            // current alarm?
        } else {
            alertTitle = "Woof! No Alarm Selected"
            label_button = "set alarm"
            alertMessage = "Click to choose daily, weekday or weekend alarm."
        }
        showAlert = true
    }
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestPermission(completionHandler:@escaping () -> Void) {
        // takes completion handler (run after check/asking notification permission)
        // @escaping: handler will be called later, not immediately
        
        // types of notifications
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.getNotificationSettings { settings in
            let completion: () -> Void = { // define helper closure to run completion handler
                DispatchQueue.main.async { // ensure UI updates run on the main thread
                    completionHandler()
                    // pass from outside the function
                }
            }
            
            switch settings.authorizationStatus {
            // evaulate one variable
            case .notDetermined:
                notificationCenter.requestAuthorization(options: options) {
                    _, _ in // ignore the value OR use granted/error
                    // after response : signal end of the process [local closure]
                    completion()
                }
            case .denied, .authorized, .provisional, .ephemeral:
                // temporary permission / temporary session-based
                completion()
            @unknown default: //safety net for future IOS update, code will not crash
                completion()
            }
        }
    }
    
    
    func scheduleNotification(for day: String, index: Int) {
        notificationCenter.getNotificationSettings { settings in
            if (settings.authorizationStatus == .authorized) {
                
                // content
                let content = UNMutableNotificationContent()
                content.title = "Time To Wake Up!"
                content.body = "It is time to walk your dog"
                content.sound = UNNotificationSound.default
                
                // schedule the date
                var hour = selectedHour[index]
                if !selectedAMPM[index] && hour != 12 {
                        hour += 12
                } else if selectedAMPM[index] && hour == 12 {
                        hour = 0
                }
                
                var components = DateComponents() // define specific date and time info for scheduling notification
                components.calendar = Calendar.current
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
                
                // trigger
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                // request
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    // unique identifier for notification request
                    // ensure each notification has a distinct identifier : useful for update/remov notification
                    content: content,
                    trigger: trigger
                )
                
                // add notification
                self.notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    } else {
                        print("Notification scheduled for \(day)!")
                    }
                }
            } else {
                permissionReject = true
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
                .padding(.top, 0)
                .frame(maxWidth: .infinity, alignment: .top)
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
    @Binding var selectedTime: [String]
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
                                selectedTime: $selectedTime,
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
    @State static var selectedTime: [String] = ["","",""]
    @State static var selectedAMPM: [Bool] = [true, true, true]
    @State static var alarmSetTime: [String: (Int, Int)] = [:]
    // preview provider : static structure

    static var previews: some View {
        SleepModeView(
            bloodline: $bloodline,
            markedDays: $markedDays,
            selectedDays: $selectedDays,
            selectedTime: $selectedTime,
            selectedAMPM: $selectedAMPM,
            alarmSetTime: $alarmSetTime
        )
    }
}

// text : alarm is set | button : reset alarm
// show the time set
// reset alarm no -> reset the unselected
