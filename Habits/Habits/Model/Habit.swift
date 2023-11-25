//
//  Habit.swift
//  Habits
//
//  Created by Nicholas Chan on 11/22/23.
//

import Foundation
import SwiftUI


struct Habit: Hashable, Codable {
    var id: Int
    var name: String
    var description: String
    var isCurrent: Bool
}
