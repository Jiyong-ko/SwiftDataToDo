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
    @State private var showCompleted: Bool = false  // 완료된 항목 표시 여부
    
    // 완료되지 않은 항목들
    private var incompleteItems: [Item] {
        items.filter { !$0.isCompleted }
    }
    
    // 완료된 항목들
    private var completedItems: [Item] {
        items.filter { $0.isCompleted }
    }

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
                    // 진행중인 할 일들
                    Section("진행중") {
                        ForEach(incompleteItems) { item in
                            TodoItemRow(item: item)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    
                    // 완료된 할 일들
                    Section {
                        DisclosureGroup(
                            isExpanded: $showCompleted,
                            content: {
                                ForEach(completedItems) { item in
                                    TodoItemRow(item: item)
                                }
                                .onDelete(perform: deleteItems)
                            },
                            label: {
                                HStack {
                                    Text("완료됨")
                                    Spacer()
                                    Text("\(completedItems.count)")
                                        .foregroundColor(.gray)
                                }
                            }
                        )
                    }
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
            
            // 저장 시도
            do {
                try modelContext.save()
                print("아이템이 성공적으로 저장되었습니다: \(newItem.title)")
            } catch {
                print("저장 실패: \(error)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
            
            // 삭제 후 저장 시도
            do {
                try modelContext.save()
                print("아이템이 성공적으로 삭제되었습니다")
            } catch {
                print("삭제 실패: \(error)")
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

// 할 일 항목 행을 위한 새로운 뷰
struct TodoItemRow: View {
    let item: Item
    
    var body: some View {
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
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: false)
}
