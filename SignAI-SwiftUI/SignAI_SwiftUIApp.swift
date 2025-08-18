//
//  SignAI_SwiftUIApp.swift
//  SignAI-SwiftUI
//
//  Created by Federico Diaz Nemeth on 06/08/2025.
//


import SwiftUI

private func loadRocketSimConnect() {
    #if DEBUG
    guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
        print("Failed to load linker framework")
        return
    }
    print("RocketSim Connect successfully linked")
    #endif
}

@main
struct SignAI_SwiftUIApp: App {
    init() {
        loadRocketSimConnect()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
