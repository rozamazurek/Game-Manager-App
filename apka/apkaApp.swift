//
//  apkaApp.swift
//  apka
//
//  Created by Róża Mazurek on 30/10/2025.
//

import SwiftUI
import SwiftData


@main
struct apkaApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [
            Player.self,
            Debt.self,
            GameExpense.self,
            Settlement.self,
            PlayDate.self
        ])
    }
}

