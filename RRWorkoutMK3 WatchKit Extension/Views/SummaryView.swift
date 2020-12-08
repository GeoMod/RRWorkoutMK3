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
	@Binding var workoutIsActive: Bool

	@State private var workoutPaused = false

	var body: some View {
		VStack {

			Text(workoutIsActive ? "Cal: \(workoutController.activeCalories)" : "Pause Workout?")

			Button(action: {
				if workoutPaused {
					workoutController.resumeWorkout()
					workoutPaused.toggle()
				} else {
					workoutController.pauseWorkout()
					workoutPaused.toggle()
				}
			}, label: {
				Image(systemName: workoutPaused ? "arrow.clockwise.circle" : "pause.fill")
					.font(.title2)
					.foregroundColor(workoutPaused ? .green : .blue)
			})

			Group {
				if workoutIsActive {
					Button(action: {
						workoutIsActive = false
						workoutController.endWorkout()
					}, label: {
						Image(systemName: "stop.circle")
							.foregroundColor(.red)
					})
					.offset(x: workoutPaused ? 0 : -500)
				} else {
					Button("Done") {
						tabSelection = .home
					}
					.foregroundColor(.yellow)
				}
			}
			.font(.title2)
			.animation(.easeOut)
		}
		.navigationTitle("Run Roster")
	}
}

//struct SummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//		SummaryView()
//    }
//}
