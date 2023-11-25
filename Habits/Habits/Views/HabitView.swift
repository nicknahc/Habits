//
//  HabitView.swift
//  Habits
//
//  Created by Nicholas Chan on 11/24/23.
//

import Foundation
import SwiftUI
struct HabitView: View {
   var habit: String

   var body: some View {
       VStack {
           Text(habit)
               .font(.largeTitle)
               .padding()
       }
       .navigationBarTitle("Habit Description", displayMode: .inline)
   }
}
