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
    @State private var searchText: String = ""  // 검색어 상태
    @State private var isSearching: Bool = false  // 검색 모드 상태
    
    // 완료되지 않은 항목들
    private var incompleteItems: [Item] {
        items.filter { !$0.isCompleted }
    }
    
    // 완료된 항목들
    private var completedItems: [Item] {
        items.filter { $0.isCompleted }
    }
    
    // 검색 결과를 필터링하는 계산 프로퍼티
    private var filteredIncompleteItems: [Item] {
        if searchText.isEmpty {
            return incompleteItems
        }
        return incompleteItems.filter { $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    private var filteredCompletedItems: [Item] {
        if searchText.isEmpty {
            return completedItems
        }
        return completedItems.filter { $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
        
    

    var body: some View {
        NavigationStack {
            VStack {
                if isSearching {
                    // 검색 바
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.blue)
                        TextField("검색", text: $searchText)
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color(hex: "#a1acdf"))
                            }
                        }
                    }
                }
                HStack {
                    TextField("새로운 할 일", text: $newItemTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: addItem) {
                        Label("추가", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color(hex: "#737b9f"))
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
                .scrollContentBackground(.hidden) // 기본 배경을 숨기고
                .background(Color(hex: "#a1acdf")) // 원하는 색상 지정
                
            }
            .navigationTitle("TO DO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TO DO")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#a1acdf"), Color(hex: "#8164be")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            isSearching.toggle()
                            if !isSearching {
                                searchText = "" // 검색 모드 아닐 때, 검색어 초기화
                            }
                        }
                    }) {
                        Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
                    }
                    .foregroundStyle(Color(hex: "#737b9f"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundStyle(Color(hex: "#737b9f"))
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

// UIColor 확장: 16진수 색상 코드 지원
extension Color {
    init(hex: String) {
        let uiColor = UIColor(hex: hex)
        self.init(uiColor)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: false)
}
