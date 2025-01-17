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
        NavigationStack {
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
                                withAnimation {
                                    item.isCompleted.toggle()
                                }
                            }) {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.plain)

                            NavigationLink(destination: ItemDetailView(item: item)) {
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .strikethrough(item.isCompleted)
                                    Text(item.timestamp, format: .dateTime)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
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

struct ItemDetailView: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(item.title)
                .font(.title)
            
            Text("생성일: \(item.timestamp, format: .dateTime)")
            
            Text("상태: \(item.isCompleted ? "완료" : "진행 중")")
                .foregroundColor(item.isCompleted ? .green : .blue)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
