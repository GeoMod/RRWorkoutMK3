//
//  SwiftUIView.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/30/20.
//

import SwiftUI

struct PauseStopResumeView: View {
	@EnvironmentObject var workoutController: WorkoutController

	@Binding var tabSelection: TabSelection
	@Binding var workoutIsActive: Bool

	@State private var isShowingSheet 	= false
	@State private var workoutPaused 	= false


	var body: some View {
		VStack {
			Button(action: {
				if workoutPaused {
					// Workout is paused, lets resume.
					workoutController.resumeWorkout()
					workoutPaused = false
					// Switch back to WorkoutDetailView
					tabSelection = .activeRun
				} else {
					// Workout is running, pause it.
					workoutController.pauseWorkout()
					workoutPaused = true
				}
			}, label: {
				Image(systemName: workoutPaused ? "arrow.clockwise.circle" : "pause.fill")
					.font(.title2)
					.foregroundColor(workoutPaused ? .green : .blue)
			})

			Group {
				// Workout is paused,
				// Here is the option to resume or End
				if workoutIsActive {
					Button(action: {
						workoutIsActive = false
						isShowingSheet = true
					}, label: {
						Image(systemName: "stop.circle")
							.foregroundColor(.red)
					})
					.offset(x: workoutPaused ? 0 : -500)
				}
			}
			.font(.title2)
			.animation(.easeOut)
		}
		.navigationTitle("Run Roster")

		.sheet(isPresented: $isShowingSheet, onDismiss: {
			endWorkoutResetToHome()
		}, content: {
			SummaryView(totalDistance: Text("\(workoutController.distance)"),
						totalTime: Text(TimeConvert.elapsedTimeString(elapsed: TimeConvert.secondsToHoursMinutesSeconds(seconds: workoutController.elapsedSeconds))),
						averagePace: Text(workoutController.paceManager.currentRunningPace))
		})

	}


	private func endWorkoutResetToHome() {
		workoutController.endWorkout()
		workoutIsActive = false
		workoutPaused = false
		tabSelection = .home
	}

}

//struct SummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//		SummaryView()
//    }
//}
