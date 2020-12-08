//
//  WorkoutDetailView.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/25/20.
//

import SwiftUI

struct WorkoutDetailView: View {

	@EnvironmentObject var workoutController: WorkoutController

	@Binding var workoutIsActive: Bool

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

			StartButtonView
		}
		.navigationTitle("Run Roster")
	}


	private func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
		(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
	}

	// Convert the seconds, minutes, hours into a string.
	private func elapsedTimeString(elapsed: (h: Int, m: Int, s: Int)) -> String {
		String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
	}

	private var StartButtonView: some View {

		Button("Begin Workout") {
			workoutIsActive = true
			workoutController.setupWorkoutSession()
		}
		.offset(x: workoutIsActive ? -500 : 0)
		.animation(.easeIn(duration: 0.25))
		.disabled(workoutIsActive ? true : false)
		.animation(.none)
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
