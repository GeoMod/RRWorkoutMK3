//
//  RRWorkoutMK3App.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/24/20.
//

import SwiftUI

@main
struct RRWorkoutMK3App: App {

	let workoutController = WorkoutController()

    var body: some Scene {
        WindowGroup {
            NavigationView {
				ContentView(tabSelection: TabSelection.home)
			}
			.environmentObject(workoutController)
        }
    }
}
