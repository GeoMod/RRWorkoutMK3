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

//	@Published var averagePace: Double = 0
//	@Published var instantaneousPace: Double = 0

	var pedometer = CMPedometer()
	let now = Date()


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
		} else {
			print("No Pedometer to stop.")
		}
		// TODO: send final average pace to summary screen
	}

	func getOngoingAveragePace() {
		pedometer.startUpdates(from: now) { (data, error) in
			// Get the current pace, if there isn't one set it as Zero
			guard let pace = data?.averageActivePace else { return }
			let avgPace = Double(truncating: pace)

//			self.averagePace = Double(truncating: data?.averageActivePace ?? 0)
//			self.instantaneousPace = Double(truncating: data?.currentPace ?? 0)

			// Update UI
			DispatchQueue.main.async {
				self.currentRunningPace = self.convert(pace: avgPace, to: self.unitOfMeasurement)
			}
		}
	}

	func convert(pace: Double, to speed: UnitOfSpeedMeasurement) -> String  {
		// metersPerSecond is given from CoreMotion as an NSNumber.
		let metersPerSecond = Measurement(value: Double(truncating: NSNumber(value: pace)), unit: UnitSpeed.metersPerSecond)
		var unitSpeed: Measurement<UnitSpeed>

		var minutes = 0
		var seconds = 0

		switch speed {
			case .milesPerHour:
				unitSpeed = metersPerSecond.converted(to: .milesPerHour)
//				let minPerMile = 60 / unitSpeed.value
//
//				mintues = Int(minPerMile)
//				seconds = Int(minPerMile * 60) % 60
//
//				return "Pace: \(mintues)m:\(seconds)s"
			case .kilometersPerHour:
				unitSpeed = metersPerSecond.converted(to: .kilometersPerHour)
//				let minPerKm = 60 / unitSpeed.value
//
//				mintues = Int(minPerKm)
//				seconds = Int(minPerKm * 60) % 60
//
//				return "Pace: \(mintues)m:\(seconds)s"
		}

		let timeOverDistance = 60 / unitSpeed.value

		minutes = Int(timeOverDistance)
		seconds = Int(timeOverDistance * 60) % 60

		return "Pace: \(minutes)m:\(seconds)s"
	}

}


class FromWeb {

	var pace: Double = 0
	var distance: Double = 0
	var timeElapsed: Double = 0

	func paceString(title: String, pace: Double) -> String{
			var minPerMile = 0.0
			let factor = 26.8224 //conversion factor
			if pace != 0 {
				minPerMile = factor / pace
			}
			let minutes = Int(minPerMile)
			let seconds = Int(minPerMile * 60) % 60
			return String(format: "%@: %02.2f m/s \n\t\t %02i:%02i min/mi",title,pace,minutes,seconds)
		}

	func computedAvgPace() -> Double {

			pace = distance / timeElapsed
			return pace

	}

	func miles(meters:Double)-> Double{
			let mile = 0.000621371192
			return meters * mile
		}
}
