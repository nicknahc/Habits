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
    @State private var showHelpOverlay = false
    
    init(habit: Habit) {
         self.habit = habit
         _habitName = State(initialValue: habit.name ?? "")
         _goal = State(initialValue: habit.goal ?? "")
        _goalFulfilled=State(initialValue: habit.goalFulfilled)
     }
    
    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 20){
                TextField("Habit Name", text: $habitName, onCommit: saveHabit)
                    .font(.largeTitle)
                HStack{
                    TextEditor(text: $goal)
                        .monospaced()
                        .frame(minHeight: 100)
                        .lineSpacing(5)
                        .padding()
                        .onChange(of: goal) { newValue in
                              saveHabit()
                          }
                    Spacer()
                }
                VStack (alignment: .center){
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            habit.goalFulfilled.toggle()
                            withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 1)) {
                                self.bounceAnimation.toggle()
                                self.buttonScale = 0.9
                            }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showHelpOverlay.toggle()
                    }) {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
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
                        Text("Restore Habit")
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
        .overlay(
          Group {
              if showHelpOverlay {
                  Color.black.opacity(0.4)
                      .edgesIgnoringSafeArea(.all)
                      .onTapGesture {
                        self.showHelpOverlay = false
                      }
                  VStack {
                      Text("Need Help?")
                         .font(.title)
                         .fontWeight(.bold)
                      Text("You can tap the Habit name or goal to change it. Tap the 'Goal Fulfilled' button to toggle whether or not you have completed that goal for today. Green means completed and Red means incomplete. The 'Delete Habit' Button will delete the habit permanently while the 'Archive Habit' button will simply move the habit to Archived Habits. The 'Restore Habit' will move the habit back to the homepage.")
                         .font(.body)
                      Button("Dismiss") {
                         self.showHelpOverlay = false
                      }
                      .padding()
                      .background(Color.orange)
                      .foregroundColor(.white)
                      .cornerRadius(10)
                  }
                  .padding()
                  .background(Color.white)
                  .cornerRadius(20)
                  .shadow(radius: 20)
              }
          }
        )
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
