//
//  HabitsApp.swift
//  Habits
//
//  Created by Nicholas Chan on 12/1/23.
//

import SwiftUI
import Foundation
@main
struct HabitsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
