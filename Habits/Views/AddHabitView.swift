import SwiftUI
import CoreData
import Foundation

struct AddHabitView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @State private var habitName = ""
  @State private var isGood = false
  @State private var goal = ""
  @State private var bounceAnimation: Bool = false
  @State private var buttonScale: CGFloat = 1.0
  var body: some View {
      NavigationView {
          Form {
              TextField("Habit Name", text: $habitName)
              TextField("Goal", text: $goal)
              HStack {
                  Spacer()
                  Button(action: {
                      isGood.toggle()
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
                      Text(isGood ? "Positive Habit" : "Negative Habit")
                          .padding()
                          .foregroundColor(.white)
                  }
                  .background(Capsule()
                    .fill(isGood ? Color.green : Color.red))
                  .clipShape(Capsule())
                  .scaleEffect(buttonScale)
                  .animation(.easeInOut(duration: 0.25), value: buttonScale)
                  .padding()
                  Spacer()
              }

          }
          .navigationBarTitle("Add Habit", displayMode: .inline)
          .navigationBarItems(trailing: Button(action: {
              self.addHabit()
          }) {
              Text("Save")
          })
      }
  }

  @Environment(\.presentationMode) var presentationMode
  func addHabit() {
      let newHabit = Habit(context: self.managedObjectContext)
      newHabit.name = habitName
      newHabit.isGood = isGood
      newHabit.createdAt = Date()
      newHabit.goal = goal
      do {
          try self.managedObjectContext.save()
          self.presentationMode.wrappedValue.dismiss()
      } catch {
          print("Failed saving")
      }
   }
}
