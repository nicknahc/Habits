import SwiftUI
import Foundation
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Habit.name, ascending: true)], predicate: NSPredicate(format: "archived == %@", NSNumber(value: false))) var habits: FetchedResults<Habit>


    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Habits")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.orange)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 12.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))]) {
                        ForEach(habits, id: \.self) { habit in
                            ZStack {
                                let habitColor = habit.isGood == true ? Color.green : Color.red
                                let modifiedColor = habit.goalFulfilled ? habitColor.opacity(1.0) : habitColor.opacity(0.8)
                                Rectangle()
                                    .fill(modifiedColor)
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(5)
                                Text(habit.name ?? "")
                                HStack {
                                    Spacer()
                                    VStack {
                                        NavigationLink(destination: HabitView(habit: habit)) {
                                            Image(systemName: "info.circle")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.white)
                                                .padding(8)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .onTapGesture(count: 2) {
                              if !habit.goalFulfilled {
//                                  withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                                      habit.goalFulfilled.toggle()
//                                  }
                              } else {
                                  habit.goalFulfilled.toggle()
                              }
                            }
                        }
                        NavigationLink(destination: AddHabitView()){
                            ZStack {
                                Color.gray
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(5)
                                Image(systemName: "plus")
                            }
                            .padding()
                        }
                    }
                    Text("Need some inspiration?")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.orange)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 12.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))]) {
                        let existingHabitNames = Set(habits.map { $0.name })
                     ForEach(sampleHabits.filter { !existingHabitNames.contains($0.name) }, id: \.name) { sampleHabit in
                           ZStack {
                               let habitColor = sampleHabit.isGood == true ? Color.green : Color.red
                               Rectangle()
                                   .fill(habitColor)
                                   .frame(width: 120, height: 120)
                                   .cornerRadius(5)
                               Text(sampleHabit.name)
                           }
                           .padding()
                           .onTapGesture {
                               self.addHabit(name: sampleHabit.name, isGood: sampleHabit.isGood, goal: sampleHabit.goal)
                           }
                       }
                    }

                }
            }
            .padding(.top)
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,alignment: .topLeading)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "clock")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()){
                        Image(systemName: "person.crop.circle")
                    }
                }
                ToolbarItem(placement: .principal) { Text("Habits").foregroundColor(.white) }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.orange, for: .navigationBar)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { timer in
                    incrementHabitDaysProgress()
                }
            }
        }
    }
    func addHabit(name: String, isGood: Bool, goal: String) {
       let newHabit = Habit(context: self.managedObjectContext)
       newHabit.name = name
       newHabit.isGood = isGood
       newHabit.createdAt = Date()
       newHabit.goal = goal
       do {
           try self.managedObjectContext.save()
       } catch {
           print("Failed saving")
       }
    }
    
    func incrementHabitDaysProgress() {
       let context = managedObjectContext
       let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()

       do {
           let habits = try context.fetch(fetchRequest)
           for habit in habits {
               if habit.goalFulfilled {
                    habit.progressDays += 1
                    habit.goalFulfilled = false
               }
           }
           try context.save()
       } catch {
           print("Failed to increment habit days progress: \(error)")
       }
    }

}

struct SampleHabit {
   let name: String
   let isGood: Bool
   let goal: String
}

let sampleHabits = [
   SampleHabit(name: "Meditation", isGood: true, goal: "15 minutes of meditation daily"),
   SampleHabit(name: "Screen Time", isGood: false, goal: "Under 2 hours of Screen Time daily"),
   // Add more sample habits as needed
]



struct ContentView_Previews: PreviewProvider {
 static var previews: some View {
 ContentView()
 }
}

