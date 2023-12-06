//
//  HabitView.swift
//  Habits
//
//  Created by Nicholas Chan on 11/24/23.
//
import SwiftUI
import CoreData
import Foundation

struct HabitView: View {
    var habit: Habit
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode

    @State private var showingDeleteConfirmation = false
    @State private var showingArchiveRestoreConfirmation = false
    @State private var habitName = ""
    @State private var goal = ""
    init(habit: Habit) {
         self.habit = habit
         _habitName = State(initialValue: habit.name ?? "")
         _goal = State(initialValue: habit.goal ?? "")
     }
    
    var body: some View {
        VStack {
            TextField("Habit Name", text: $habitName, onCommit: saveHabit)
                          .font(.largeTitle)
                          .padding()
            TextField("Goal", text: $goal, onCommit: saveHabit)
                          .font(.largeTitle)
                          .padding()
            Text("Days since start: \(daysSinceCreation())")
                           .font(.caption)
                           .padding()
            Text("Days of Progress: \(habit.progressDays)")
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Text("Delete Habit")
                    .foregroundColor(.red)
            }
            .confirmationDialog("Are you sure you want to delete this habit?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteHabit()
                    showingDeleteConfirmation = false
                }
            }
            Button(action: {
                showingArchiveRestoreConfirmation = true
            }) {
                if habit.archived {
                    Text("Restore Archive")
                        .foregroundColor(.green)
                } else {
                    Text("Archive Habit")
                        .foregroundColor(.red)
                }
            }
            .confirmationDialog("Are you sure you want to \(habit.archived ? "restore" : "archive") this habit?", isPresented: $showingArchiveRestoreConfirmation, titleVisibility: .visible) {
                Button(habit.archived ? "Restore" : "Archive", role: .destructive) {
                    if habit.archived {
                        restoreHabit()
                    } else {
                        archiveHabit()
                    }
                    showingArchiveRestoreConfirmation = false
                }
            }
        }
        .navigationBarTitle("Habit Details", displayMode: .inline)
    }

    func archiveHabit() {
        habit.archived = true

        do {
            try managedObjectContext.save()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to archive habit")
        }
    }

    func restoreHabit() {
        habit.archived = false

        do {
            try managedObjectContext.save()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to restore habit")
        }
    }

    func deleteHabit() {
        managedObjectContext.delete(habit)

        do {
            try managedObjectContext.save()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to delete habit")
        }
    }
    func daysSinceCreation() -> Int {
           let now = Date()
           let creationDate = habit.createdAt ?? now
           let components = Calendar.current.dateComponents([.day], from: creationDate, to: now)
           return components.day ?? 0
    }
    func saveHabit() {
          habit.name = habitName
          habit.goal = goal
          do {
              try managedObjectContext.save()
          } catch {
              print("Failed to save habit")
          }
    }
}
