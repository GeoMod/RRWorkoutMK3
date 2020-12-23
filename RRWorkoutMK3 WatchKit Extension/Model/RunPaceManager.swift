//
//  CoreMotionManager.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 12/8/20.
//

import Combine
import CoreMotion

final class RunPaceManager: NSObject, ObservableObject {

	@Published var currentRunningPace = "0:00:00"

	var pedometer: CMPedometer

	override init() {
		pedometer = CMPedometer()
	}

	enum UnitOfSpeedMeasurement {
		case kilometersPerHour
		case milesPerHour
	}

	func startMotionUpdates() {
		if CMPedometer.isStepCountingAvailable() {
			getActivePace()
		} else {
			print("No Pedometer available")
		}
	}

	func getActivePace() {
		pedometer.startUpdates(from: Date()) { (data, error) in
			// Get the current pace, if there isn't one set it as Zero
			let rawPace = data?.currentPace ?? 0

			let currentPace = Double(truncating: rawPace)

			// Update UI
			self.currentRunningPace = self.convert(pace: currentPace, to: .milesPerHour)
		}
	}


	func stopMotionUpdates() {
		getAverageRunningPace()
		pedometer.stopUpdates()
	}

	func getAverageRunningPace() {
		pedometer.startUpdates(from: Date()) { (data, error) in
			// WIP

//			guard let data = data else {
//				print("Error in pedometer \(error!.localizedDescription)")
//				return }

//			self.averageRunningPace = data.averageActivePace!
		}
	}

	func convert(pace: Double, to speed: UnitOfSpeedMeasurement) -> String  {
		// Measurement<UnitSpeed>
		// metersPerSecond is given from CoreMotion. This is an example value for testing.
		let metersPerSecond = Measurement(value: Double(truncating: NSNumber(value: pace)),
										  unit: UnitSpeed.metersPerSecond)
		var unitSpeed: Measurement<UnitSpeed>

		var mintues = 0
		var seconds = 0

		switch speed {
			case .milesPerHour:
				unitSpeed = metersPerSecond.converted(to: .milesPerHour)
				let minPerMile = 60 / unitSpeed.value

				mintues = Int(minPerMile.rounded(.towardZero))
				seconds = Int(minPerMile.truncatingRemainder(dividingBy: 1.0) * 60)

				return "Pace: \(mintues)m:\(seconds)s"
			case .kilometersPerHour:
				unitSpeed = metersPerSecond.converted(to: .kilometersPerHour)
				let minPerKm = 60 / unitSpeed.value

				mintues = Int(minPerKm.rounded(.towardZero))
				seconds = Int(minPerKm.truncatingRemainder(dividingBy: 1.0) * 60)

				return "Pace: \(mintues)m:\(seconds)s"
		}
	}

}
