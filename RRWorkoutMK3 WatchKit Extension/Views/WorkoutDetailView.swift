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
	@State private var workoutPaused = false
	@State private var workoutWillEnd = false

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

			WorkoutStartStopButtonsView
		}
		.alert(isPresented: $workoutWillEnd, content: {
			Alert(title: Text("Workout Complete?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("End Workout"), action: {
				tabSelection = .home
				workoutController.endWorkout()
			}))
		}).environmentObject(workoutController)

	}


	private func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
		(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
	}

	// Convert the seconds, minutes, hours into a string.
	private func elapsedTimeString(elapsed: (h: Int, m: Int, s: Int)) -> String {
		String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
	}

	private var WorkoutStartStopButtonsView: some View {
		Group {
			if workoutIsActive {
				HStack {
					// Pause Button
					Button(action: {
						// pause or resume workout
						if workoutPaused {
							workoutController.resumeWorkout()
							workoutPaused.toggle()
							return
						} else {
							workoutController.pauseWorkout()
							workoutPaused.toggle()
						}
					}) {
						Image(systemName: workoutPaused  ? "arrow.clockwise.circle.fill" : "pause.fill")
							.foregroundColor(workoutPaused ? .green : .blue)
					}
					// Start/Stop Button
					Button(action: {
						workoutWillEnd.toggle()
						workoutController.pauseWorkout()
//						workoutController.endWorkout()
					}) {
						Image(systemName: "stop.fill")
							.foregroundColor(.red)
					}
				}
				.font(.system(size: 25))

			} else {
				Button("Begin Workout") {
					workoutIsActive.toggle()
					workoutController.beginWorkout()
				}
				.foregroundColor(.blue)
			}
		}
	}

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


//struct WorkoutDetailView_Previews: PreviewProvider {
//	static let environment = WorkoutController()
//	static var previews: some View {
//		WorkoutDetailView().environmentObject(environment)
//	}
//}
