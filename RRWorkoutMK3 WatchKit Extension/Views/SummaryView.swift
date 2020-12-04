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

			Text(workoutPaused ? "Paused" : "Pause Workout?")

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
				Button(action: {
					workoutIsActive = false
					workoutController.endWorkout()
					workoutController.resetWorkout()
				}, label: {
					Image(systemName: "stop.circle")
						.foregroundColor(.red)
				})
				.offset(x: workoutPaused ? 0 : -500)

				Button("Done") {
					tabSelection = .home
				}
				.foregroundColor(.yellow)
				.offset(x: workoutIsActive ? -500 : 0)
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
