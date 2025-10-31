//
//  NavigationModel.swift
//  Ryokou
//
//  Created by Thiha Ye Yint Aung on 10/31/25.
//

import Foundation
import SwiftUI

@Observable
final class NavigationModel {
    public var tripPlanPath: [TripPlanRoute] = []
    
    private init() { }
    
    static let shared: NavigationModel = .init()
}
