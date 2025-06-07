//
//  Jelly_iOS_AppApp.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//

import SwiftUI
import FirebaseCore

@main
struct Jelly_iOS_AppApp: App {
    let persistenceController = PersistenceController.shared
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
