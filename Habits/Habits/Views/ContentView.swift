//
//  ContentView.swift
//  Habits
//
//  Created by Nicholas Chan on 11/22/23.
//

import SwiftUI
import Foundation


struct ContentView: View {
    let habits = [
       "Exercise",
       "Reading",
       "Meditation",
       "Writing",
       "Cooking",
       "Cleaning",
       "Gardening",
       "Learning a new language",
       "Playing a musical instrument",
       "Volunteering"
    ]
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
                           NavigationLink(destination: HabitView(habit: habit)){
                               ZStack {
                                                             Color.gray
                                                              .frame(width: 120, height: 120)
                                                              .cornerRadius(5)
                                                             Text(habit)
                                                          }
                                   .padding()
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
       }
     }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}