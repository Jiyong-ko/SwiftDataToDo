//
//  ContentView.swift
//  SwiftDataToDo
//
//  Created by Noel Mac on 1/17/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var newItemTitle: String = ""

    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    TextField("새로운 할 일", text: $newItemTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: addItem) {
                        Label("추가", systemImage: "plus.circle.fill")
                    }
                }
                .padding()

                List {
                    ForEach(items) { item in
                        HStack {
                            Button(action: {
                                item.isCompleted.toggle()
                            }) {
                                Image(
                                    systemName: item.isCompleted
                                        ? "checkmark.circle.fill" : "circle")
                            }

                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .strikethrough(item.isCompleted)
                                Text(item.timestamp, format: .dateTime)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("TO DO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TO DO")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        } detail: {
            Text("할 일을 선택하세요")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(title: newItemTitle, timestamp: Date())
            modelContext.insert(newItem)
            newItemTitle = ""
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
