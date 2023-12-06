//
//  HistoryView.swift
//  Habits
//
//  Created by Nicholas Chan on 11/24/23.
//
import SwiftUI
import Foundation

struct HistoryView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(entity: Habit.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Habit.name, ascending: true)],
                  predicate: NSPredicate(format: "archived == %@", NSNumber(value: true))) var archivedHabits: FetchedResults<Habit>

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))]) {
                    ForEach(archivedHabits, id: \.self) { habit in
                        NavigationLink(destination: HabitView(habit: habit)) {
                            ZStack {
                                Color.gray
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(5)
                                Text(habit.name ?? "")
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("Archived Habits")
        }
    }
}
