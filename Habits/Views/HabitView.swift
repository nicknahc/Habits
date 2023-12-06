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
    @State private var goalFulfilled = false
    @State private var bounceAnimation: Bool = false
    @State private var buttonScale: CGFloat = 1.0
    init(habit: Habit) {
         self.habit = habit
         _habitName = State(initialValue: habit.name ?? "")
         _goal = State(initialValue: habit.goal ?? "")
        _goalFulfilled=State(initialValue: habit.goalFulfilled)
     }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20){
            TextField("Habit Name", text: $habitName, onCommit: saveHabit)
                          .font(.largeTitle)
            HStack{
                TextEditor(text: $goal)
                    .monospaced()
                    .frame(minHeight: 100) // Set a minimum height to allow multiple lines
                    .lineSpacing(5) // Adjust line spacing if needed
                    .padding()
                    Spacer()
            }
            
            VStack (alignment: .center){
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                    habit.goalFulfilled.toggle()
                    // Trigger bounce animation
                    withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 1)) {
                        self.bounceAnimation.toggle()
                        self.buttonScale = 0.9
                    }
                    // Reset button scale after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation {
                            self.buttonScale = 1.0
                        }
                    }
                }) {
                    Text("Goal Fulfilled Today?")
                        .padding()
                        .foregroundColor(.white)
                }
                .background(Capsule()
                    .fill(habit.goalFulfilled ? Color.green : Color.red))
                .clipShape(Capsule())
                .scaleEffect(buttonScale)
                .animation(.easeInOut(duration: 0.25), value: buttonScale)
                .padding()
                    Spacer()
                }
                    
                Spacer()
            }
            .padding()
    
           
        }
        .navigationBarTitle("Habit Details", displayMode: .inline)
        .padding()
        VStack(alignment: .center){
            Spacer()
            Button("Delete Habit") {
                showingDeleteConfirmation = true
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
