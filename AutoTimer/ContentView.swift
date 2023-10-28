//
//  ContentView.swift
//  AutoTimer
//
//  Created by Jonas Helmer on 28.10.23.
//

import SwiftUI
import SimpleToast
import UserNotifications

struct ContentView: View {
    @AppStorage("message") private var message: String = ""
    @AppStorage("messageSubtitle") private var messageSubtitle: String = ""
    @AppStorage("intervall") private var intervall: Int = 20
    @AppStorage("allowsNotifications") private var allowsNotifications: Bool = false
    @AppStorage("hasRunningNotifcations") private var hasRunningNotifcations: Bool = false
    
    @State private var showStartToast: Bool = false
    @State private var showStopToast: Bool = false
    
    private let toastOptions = SimpleToastOptions(
        hideAfter: 5,
        modifierType: .slide
    )
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("For Notification", text: $message)
                } header: {
                    Text("Message")
                }
                
                Section {
                    TextField("For Notification", text: $messageSubtitle)
                } header: {
                    Text("Message Subtitle")
                }

                Section {
                    TextField("Intervall in Minutes", value: $intervall, format: .number)
                    .keyboardType(.numberPad)
                    .disableAutocorrection(true)
                } header: {
                    Text("Intervall in Minutes")
                }
                
                if hasRunningNotifcations {
                    Section {
                        Button("Stop", action: stopNotifications)
                    }
                } else {
                    Section {
                        Button("Start", action: setNotifications)
                    }
                }
            }
            .simpleToast(isPresented: $showStartToast, options: toastOptions) {
                Label("Added Notifications", systemImage: "plus.app")
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(Color.primary)
                    .cornerRadius(30)
                    .padding(.top)
            }
            .simpleToast(isPresented: $showStopToast, options: toastOptions) {
                Label("Stopped Notifcations", systemImage: "xmark.bin")
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(Color.primary)
                    .cornerRadius(30)
                    .padding(.top)
            }
            .onAppear(perform: requestNotificationAuthorization)
            .navigationTitle("Auto Timer")
        }
    }
    
    func requestNotificationAuthorization() {
        if !allowsNotifications {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func setNotifications() {
        let content = UNMutableNotificationContent()
        content.title = message
        content.subtitle = messageSubtitle
        content.sound = UNNotificationSound.defaultCritical
        let newIntervall = TimeInterval(intervall * 60)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: newIntervall, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        withAnimation {
            showStartToast.toggle()
            hasRunningNotifcations.toggle()
        }
    }
    
    func stopNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        withAnimation {
            showStopToast.toggle()
            hasRunningNotifcations.toggle()
        }
    }
}
