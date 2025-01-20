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
    @Query private var todos: [TodoItem]
    @State private var newTodoTitle: String = ""
    @State private var showCompleted: Bool = false  // 완료된 항목 표시 여부
    @State private var searchText: String = ""  // 검색어 상태
    @State private var isSearching: Bool = false  // 검색 모드 상태

    
    // 완료되지 않은 항목들
    private var incompletedTodoItems: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }
    
    // 완료된 항목들
    private var completedTodoItems: [TodoItem] {
        todos.filter { $0.isCompleted }
    }
    
    
    // 진행 중 항목의 검색 필터링
    private var filteredIncompletedTodoItems: [TodoItem] {
        if searchText.isEmpty {
            return incompletedTodoItems
        }
        return incompletedTodoItems.filter { $0.title.localizedCaseInsensitiveContains(searchText)}
    }
    
    // 완료된 항목의 검색 필터링
    private var filteredCompletedTodoItems: [TodoItem] {
        if searchText.isEmpty {
            return completedTodoItems
        }
        return completedTodoItems.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
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
                    .padding()
                }
                HStack {
                    TextField("새로운 할 일", text: $newTodoTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: addTodoItem) {
                        Label("추가", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color(hex: "#8164be"))
                    }
                }
                .padding()

                List {
                    // 진행중인 할 일들
                    Section("진행 중") {
                        ForEach(filteredIncompletedTodoItems) { todoItem in
                            TodoItemRow(todoItem: todoItem)
                        }
                        .onDelete(perform: deleteTodoItems)
                    }
                    
                    // 완료된 할 일들
                    Section("완료됨") {
                        DisclosureGroup(
                            isExpanded: $showCompleted,
                            content: {
                                ForEach(filteredCompletedTodoItems) { todoItem in
                                    TodoItemRow(todoItem: todoItem)
                                }
                                .onDelete(perform: deleteTodoItems)
                            },
                            label: {
                                HStack {
                                    if showCompleted {
                                        Text("완료된 목록 가리기")
                                    } else {
                                        Text("완료된 목록 보기")
                                    }
                                    Spacer()
                                    Text("\(filteredCompletedTodoItems.count)")
                                        .foregroundColor(.gray)
                                }
                            }
                        )
                    }
                }
                .scrollContentBackground(.hidden) // 기본 배경을 숨기고
                .background(
                    LinearGradient(colors: [Color(hex: "#a1acdf"), Color(hex: "#8164be")], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) // 원하는 색상 지정
                
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
                    .foregroundStyle(Color(hex: "#8164be"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundStyle(Color(hex: "#8164be"))
                }
            }
        }
    }

    private func addTodoItem() {
        withAnimation {
            let newTodoItem = TodoItem(title: newTodoTitle, timestamp: Date())
            modelContext.insert(newTodoItem)
            newTodoTitle = ""
            
            // 저장 시도
            do {
                try modelContext.save()
                print("아이템이 성공적으로 저장되었습니다: \(newTodoItem.title)")
            } catch {
                print("저장 실패: \(error)")
            }
        }
    }

    private func deleteTodoItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(todos[index])
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

struct TodoDetailView: View {
    let todoItem: TodoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(todoItem.title)
                .font(.title)
            
            Text("생성일: \(todoItem.timestamp, format: .dateTime)")
            
            Text("상태: \(todoItem.isCompleted ? "완료" : "진행 중")")
                .foregroundColor(todoItem.isCompleted ? .green : .blue)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

// To Do의 리스트 뷰
struct TodoItemRow: View {
    let todoItem: TodoItem
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    todoItem.isCompleted.toggle()
                }
            }) {
                Image(systemName: todoItem.isCompleted ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.plain)

            NavigationLink(destination: TodoDetailView(todoItem: todoItem)) {
                VStack(alignment: .leading) {
                    Text(todoItem.title)
                        .strikethrough(todoItem.isCompleted, color: .purple) // 취소선 추가
                    Text(todoItem.timestamp, format: .dateTime)
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
        .modelContainer(for: TodoItem.self, inMemory: false)
}
