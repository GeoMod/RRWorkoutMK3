//
//  WorkoutDetailView.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/25/20.
//

import SwiftUI

struct WorkoutDetailView: View {

	@EnvironmentObject var workoutController: WorkoutController

	@Binding var tabSelection: TabSelection

	@State private var workoutIsActive = false
	@State private var workoutIsPaused = false

	var body: some View {
		VStack(alignment: .leading) {
			Text(elapsedTimeString(elapsed: secondsToHoursMinutesSeconds(seconds: workoutController.elapsedSeconds)))
				.foregroundColor(.yellow)
				.font(Font.title2.monospacedDigit())

			Text("\(workoutController.distance, specifier: "%.2f") mi")
				.font(Font.title.monospacedDigit())
			HStack(spacing: 20) {
				Text("\(workoutController.heartrate, specifier: "%.0f" ) BPM")
				Text("\(workoutController.activeCalories, specifier: "%.0f") Cal")
			}.font(Font.title3.monospacedDigit())

			StartStopButtonView
				.navigationTitle("Run Roster")
		}
		// To prevent the TabView animation from affecting everything inside the otehr views.
//		.animation(.none)
	}


	private func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
		(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
	}

	// Convert the seconds, minutes, hours into a string.
	private func elapsedTimeString(elapsed: (h: Int, m: Int, s: Int)) -> String {
		String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
	}

	private var StartStopButtonView: some View {
		Group {
			if workoutIsActive {
				// pause workout
				// move to deatail screen where user can go back to active workout or stop the workout.
				// stay on same page after stopping workout.
				Button(action: {
					workoutIsActive = false
					workoutController.pauseWorkout()
					tabSelection = .runSummary
				}, label: {
					Image(systemName: "pause.fill")
						.font(.title2)
				})
			} else {
				Button(action: {
					workoutIsActive = true
					workoutIsPaused = true
					workoutController.setupWorkoutSession()
				}, label: {
					Text(workoutIsPaused ? "Resume Workout" : "Begin Workout")
						.foregroundColor(.blue)
				})
			}
		}
		.animation(.none)

	}

//	private var WorkoutStartStopButtonsView: some View {
//		Group {
//			if workoutIsActive {
//				HStack {
//					// Pause Button
//					Button(action: {
//						// pause or resume workout
//						if workoutPaused {
//							workoutController.resumeWorkout()
//							workoutPaused.toggle()
//							return
//						} else {
//							workoutController.pauseWorkout()
//							workoutPaused.toggle()
//						}
//					}) {
//						Image(systemName: workoutPaused  ? "arrow.clockwise.circle.fill" : "pause.fill")
//							.foregroundColor(workoutPaused ? .green : .blue)
//					}
//					// Start/Stop Button
//					Button(action: {
//						workoutWillEnd.toggle()
//						workoutController.pauseWorkout()
//					}) {
//						Image(systemName: "stop.fill")
//							.foregroundColor(.red)
//					}
//				}
//				.font(.system(size: 25))
//
//			} else {
//				Button("Begin Workout") {
//					workoutIsActive.toggle()
//					workoutController.beginWorkout()
//				}
//				.foregroundColor(.blue)
//			}
//		}
//	}

}



struct Metric: Codable {
	var name: String
	var value: Double
}


extension Metric: CustomStringConvertible {
	var description: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2

		let number = NSNumber(value: value)
		let formattedValue = formatter.string(from: number)!
		return "\(name): \(formattedValue)"
	}
}


struct WorkoutDetailView_Previews: PreviewProvider {
	static let environment = WorkoutController()
	static var workoutIsActive = true

	static var previews: some View {
		VStack {
			Button(action: {
				//
			}, label: {
				Text("Begin Workout")
			})

			Button(action: {
				//
			}, label: {
				Image(systemName: "pause.fill")
					.font(.title2)
			})
		}
	}

}
