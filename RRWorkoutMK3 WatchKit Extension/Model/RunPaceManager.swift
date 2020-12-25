//
//  CoreMotionManager.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 12/8/20.
//

import Combine
import CoreMotion

final class RunPaceManager: NSObject, ObservableObject {

	enum UnitOfSpeedMeasurement {
		case kilometersPerHour
		case milesPerHour
	}

	@Published var currentRunningPace = "0:00:00"
	@Published var unitOfMeasurement: UnitOfSpeedMeasurement = .milesPerHour

	var pedometer: CMPedometer

	override init() {
		pedometer = CMPedometer()
	}


	func startMotionUpdates() {
		if CMPedometer.isPaceAvailable() {
			getOngoingAveragePace()
		} else {
			print("No Pedometer to start updating")
		}
	}

	func stopMotionUpdates() {
		if CMPedometer.isPaceAvailable() {
			pedometer.stopUpdates()
			print("STOP Called")
		} else {
			print("No Pedometer to stop.")
		}
		// WIP
		// send final average pace to summary screen
	}

	func getOngoingAveragePace() {
		pedometer.startUpdates(from: Date()) { (data, error) in
			// Get the current pace, if there isn't one set it as Zero
			let rawPace = data?.averageActivePace ?? 0
			let currentPace = Double(truncating: rawPace)

			// Update UI
			DispatchQueue.main.async {
				self.currentRunningPace = self.convert(pace: currentPace, to: self.unitOfMeasurement)
			}
		}
	}



	func convert(pace: Double, to speed: UnitOfSpeedMeasurement) -> String  {
		// metersPerSecond is given from CoreMotion.
		let metersPerSecond = Measurement(value: Double(truncating: NSNumber(value: pace)), unit: UnitSpeed.metersPerSecond)
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
