//
//  SwiftDataToDoApp.swift
//  SwiftDataToDo
//
//  Created by Noel Mac on 1/17/25.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataToDoApp: App {
    let modelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("ModelContainer를 생성할 수 없습니다: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
