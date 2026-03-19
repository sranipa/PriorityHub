//
//  PriorityHubApp.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import SwiftUI
import FirebaseCore
import SwiftData

@main
struct PriorityHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate //Register App Delegate
    @State private var globalObject = GlobalObject()
    @AppStorage(CONSTANT.IS_DARK_MODE) private var isDarkMode = false
    
    init() {
        // We add condition here. So content view direct disply home screen. Otherwise it will display first login screeen and then after within 2 second it will display home screen.
        if getUserLoggedIn() {
            globalObject.isUserLoggedIn = true
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .loadingOverlay(isLoading: AlertManager.shared.isShowGlobalLoading)
                .globalAlertView()
                .environment(globalObject)
                .preferredColorScheme(isDarkMode ? .dark : .none)
                .modelContainer(for: [Project.self, TaskItem.self])
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
