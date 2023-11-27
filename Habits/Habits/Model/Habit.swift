//
//  Habit.swift
//  Habits
//
//  Created by Nicholas Chan on 11/22/23.
//

import Foundation
import SwiftUI
import CoreData

class Habit: NSManagedObject, Identifiable {
   @NSManaged var id: Int
   @NSManaged var name: String
   @NSManaged var isCurrent: Bool
}
