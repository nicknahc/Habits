//
//  HistoryView.swift
//  Habits
//
//  Created by Nicholas Chan on 11/24/23.
//
import SwiftUI
import Foundation

struct ProfileView : View {
   @Environment(\.managedObjectContext) var managedObjectContext
   @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Habit.name, ascending: true)]) var habits: FetchedResults<Habit>

   var body : some View {
       VStack {
           Text("Total Habits in Progress: \(habits.filter { !$0.goalFulfilled }.count)")
           Text("Average Habit Consistency: \(averageHabitConsistency())%")
           Text("Total Habits: \(habits.count)")
       }
   }
   
   func averageHabitConsistency() -> Double {
       let totalConsistency = habits.map { Double(consistencyPercentage(for: $0)) }.reduce(0, +)
       return totalConsistency / Double(habits.count)
   }
   
   func consistencyPercentage(for habit: Habit) -> Int {
       let now = Date()
       let creationDate = habit.createdAt ?? now
       let components = Calendar.current.dateComponents([.day], from: creationDate, to: now)
       if let days = components.day, days > 0 {
           let daysInt = Int(days)
           let progressDaysInt = Int(habit.progressDays)
           let consistencyPercentage = (progressDaysInt / daysInt) * 100
           return Int(consistencyPercentage)
       } else {
           return 0
       }
   }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
