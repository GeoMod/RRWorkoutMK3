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
			VStack(alignment: .leading) {
				Label {
					Text("\(TimeConvert.elapsedTimeString(elapsed: TimeConvert.secondsToHoursMinutesSeconds(seconds: workoutController.elapsedSeconds)))")
				} icon: {
					Image(systemName: "clock.fill")
						.foregroundColor(.yellow)
				}

				Label {
					Text("\(workoutController.distance, specifier: "%.2f") mi")
				} icon: {
					Image(systemName: "figure.walk.circle.fill")
						.foregroundColor(.yellow)
				}

				Label {
					Text("\(workoutController.averagePace) /mi")
				} icon: {
					Image(systemName: "speedometer")
						.foregroundColor(.yellow)
				}


				Label { Text("\(workoutController.heartrate, specifier: "%.0f") bpm") }
					icon: { Image(systemName: "heart.circle.fill")
						.foregroundColor(.yellow)
					}

				Label {
					Text("\(workoutController.activeCalories, specifier: "%.0f") cal")
				} icon: {
					Image(systemName: "bolt.horizontal.circle")
						.foregroundColor(.yellow)
				}

				StartButtonView
			}
			.foregroundColor(.white)
			.font(Font.title2.monospacedDigit())
		}
		.navigationTitle("Run Roster")
	}

	private var StartButtonView: some View {

		Button("Begin Workout") {
			workoutIsActive = true
			workoutController.setupWorkoutSession()
		}
		.font(.body)
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
	static let workoutController = WorkoutController()
	static var workoutIsActive = true

	static var previews: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 1) {
				Label {
					Text("0:23:02")
				} icon: {
					Image(systemName: "clock.fill")
						.foregroundColor(.yellow)
				}
				Label {
					Text("\(workoutController.distance, specifier: "%.2f") mi")
				} icon: {
					Image(systemName: "figure.walk.circle.fill")
						.foregroundColor(.yellow)
				}

				Label {
					Text("\(workoutController.averagePace) /mi")
				} icon: {
					Image(systemName: "speedometer")
						.foregroundColor(.yellow)
				}
				Label { Text("\(workoutController.heartrate, specifier: "%.0f") bpm") }
					icon: { Image(systemName: "heart.circle.fill")
						.foregroundColor(.yellow)
					}
				Label {
					Text("\(workoutController.activeCalories, specifier: "%.0f") cal")
				} icon: {
					Image(systemName: "bolt.horizontal.circle")
						.foregroundColor(.yellow)
				}
			}
			.foregroundColor(.white)
			.font(Font.title2.monospacedDigit())
		}
		.navigationTitle("Run Roster")
	}


}
