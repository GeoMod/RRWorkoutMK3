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

//	let timeConversion = ConvertTimeInSecondsToString()

	var body: some View {
		VStack {
			Button(action: {
				if workoutPaused {
					workoutController.resumeWorkout()
					workoutPaused.toggle()
					tabSelection = .activeRun
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
//						workoutController.endWorkout()
						isShowingSheet = true
					}, label: {
						Image(systemName: "stop.circle")
							.foregroundColor(.red)
					})
					.offset(x: workoutPaused ? 0 : -500)
				}
//				else {
//					Button("Done") {
//						tabSelection = .home
//					}
//					.foregroundColor(.yellow)
//				}
			}
			.font(.title2)
			.animation(.easeOut)
		}
		.navigationTitle("Run Roster")

		.sheet(isPresented: $isShowingSheet, onDismiss: {
			workoutController.endWorkout()
			workoutIsActive = false
			tabSelection = .home
		}, content: {
			SummaryView(totalDistance: "\(workoutController.distance)",
						totalTime: Text(TimeConvert.elapsedTimeString(elapsed: TimeConvert.secondsToHoursMinutesSeconds(seconds: workoutController.elapsedSeconds))),
						averagePace: "\(workoutController.averageRunningPace)")
		})


	}
}

//struct SummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//		SummaryView()
//    }
//}
