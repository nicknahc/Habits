import SwiftUI
import CoreData
import Foundation

struct AddHabitView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @State private var habitName = ""
  @State private var isGood = true
  @State private var goal = ""
  @State private var bounceAnimation: Bool = false
  @State private var buttonScale: CGFloat = 1.0
  @State private var hasTriedToSave = false

  var body: some View {
      NavigationView {
          Form {
              TextField("Habit Name", text: $habitName)
              TextField("Goal", text: $goal)
              HStack {
                  Spacer()
                  Button(action: {
                      isGood.toggle()
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
      .alert(isPresented: $hasTriedToSave) {
         Alert(title: Text("Error"), message: Text("Please fill in all fields."), dismissButton: .default(Text("OK")))
      }

  }

  @Environment(\.presentationMode) var presentationMode
    func addHabit() {
       if habitName.isEmpty || goal.isEmpty {
           hasTriedToSave = true
       } else {
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

}
