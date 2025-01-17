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
    let container: ModelContainer = {
        let schema = Schema([Item.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("SwiftData 저장소 생성 실패: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
