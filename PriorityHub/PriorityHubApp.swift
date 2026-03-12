//
//  PriorityHubApp.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/5/26.
//

import SwiftUI
import FirebaseCore

@main
struct PriorityHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate //Register App Delegate
    @State private var globalObject = GlobalObject()
    @AppStorage(CONSTANT.IS_DARK_MODE) private var isDarkMode = false
    
//    init() {
//        FirebaseApp.configure()
//    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .loadingOverlay(isLoading: AlertManager.shared.isShowGlobalLoading)
                .globalAlertView()
                .environment(globalObject)
                .preferredColorScheme(isDarkMode ? .dark : .none)
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
