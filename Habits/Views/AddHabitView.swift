import SwiftUI
import CoreData
import Foundation

struct AddHabitView: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  @State private var habitName = ""
  @State private var isGood = false

  var body: some View {
      NavigationView {
          Form {
              TextField("Habit Name", text: $habitName)
              Toggle("Good", isOn: $isGood)
          }
          .navigationBarTitle("Add Habit")
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
      do {
          try self.managedObjectContext.save()
          self.presentationMode.wrappedValue.dismiss()
      } catch {
          print("Failed saving")
      }
   }
}
