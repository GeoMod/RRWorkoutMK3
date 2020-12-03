//
//  SwiftUIView.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/30/20.
//

import SwiftUI

struct SummaryView: View {
	@EnvironmentObject var workoutController: WorkoutController

	@Binding var tabSelection: TabSelection

	var body: some View {
		VStack {
			Text("Workout Summary")
			Button("Stop") {
				workoutController.endWorkout()
				workoutController.resetWorkout()
				tabSelection = .home
			}
			.navigationTitle("Run Roster")
		}
		.animation(.none)
	}
}

//struct SummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//		SummaryView()
//    }
//}
