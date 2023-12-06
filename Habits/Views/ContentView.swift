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


struct ContentView_Previews: PreviewProvider {
 static var previews: some View {
 ContentView()
 }
}
