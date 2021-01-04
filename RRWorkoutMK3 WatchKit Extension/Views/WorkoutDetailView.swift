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
		ScrollView {
			VStack(alignment: .leading, spacing: 1) {
				Text(TimeConvert.elapsedTimeString(elapsed: TimeConvert.secondsToHoursMinutesSeconds(seconds: workoutController.elapsedSeconds)))
					.foregroundColor(.yellow)
					.font(Font.title2.monospacedDigit())

				Text("\(workoutController.distance, specifier: "%.2f") mi")
					.font(Font.title.monospacedDigit())
				Label("\(workoutController.getPaceData()) /mi", systemImage: "sun.dust.fill")
					.labelStyle(TitleOnlyLabelStyle())
					.font(Font.title3.monospacedDigit())
					.foregroundColor(.yellow)

				HStack {
					Text("\(workoutController.heartrate, specifier: "%.0f" ) BPM")
						.font(Font.title3.monospacedDigit()).padding(.trailing, 20)
					Text("\(workoutController.activeCalories, specifier: "%.0f") Cal")
						.font(Font.title3.monospacedDigit())
				}
//				Text("\(workoutController.paceManager.currentRunningPace) /mi")
//					.fontWeight(.bold)
//					.foregroundColor(.yellow)
//					.font(Font.title3.monospacedDigit())

				StartButtonView
			}
		}
		.navigationTitle("Run Roster")
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
