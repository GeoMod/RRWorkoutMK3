//
//  CoreMotionManager.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 12/8/20.
//

import Combine
import CoreMotion

class RunPaceManager: NSObject, ObservableObject {

	enum UnitOfSpeedMeasurement {
		case kilometersPerHour
		case milesPerHour
	}

	@Published var currentRunningPace = "00:00"
	@Published var unitOfMeasurement: UnitOfSpeedMeasurement = .milesPerHour

	let pedometer = CMPedometer()
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

			// Update UI
			DispatchQueue.main.async {
				self.currentRunningPace = self.convert(pace: pace, to: self.unitOfMeasurement)
			}
		}
	}

	func convert(pace: NSNumber, to speed: UnitOfSpeedMeasurement) -> String  {
		/*
		metersPerSecond is given from CoreMotion as an NSNumber. But...
		the original pace value is given as "Seconds per Meter", not Meters per Second.
		1 / value converts to Meters per Second
		*/
		var conversion: Double {
			1 / pace.doubleValue
		}

		let metersPerSecond = Measurement(value: conversion, unit: UnitSpeed.metersPerSecond)

		var paceValue: Double = 0

		var minutes = 0
		var seconds = 0

		switch speed {
			case .milesPerHour:
				paceValue = 60 / metersPerSecond.converted(to: .milesPerHour).value
			case .kilometersPerHour:
				paceValue = 60 / metersPerSecond.converted(to: .kilometersPerHour).value
		}

		minutes = Int(paceValue)
		seconds = Int(paceValue * 60) % 60

		return "\(minutes)m:\(seconds)s"
	}


}


//class FromWeb {
//
//	var pace: Double = 0
//	var distance: Double = 0
//	var timeElapsed: Double = 0
//
//	func paceString(title: String, pace: Double) -> String{
//			var minPerMile = 0.0
//			let factor = 26.8224 //conversion factor
//			if pace != 0 {
//				minPerMile = factor / pace
//			}
//			let minutes = Int(minPerMile)
//			let seconds = Int(minPerMile * 60) % 60
//			return String(format: "%@: %02.2f m/s \n\t\t %02i:%02i min/mi",title,pace,minutes,seconds)
//		}
//
//	func computedAvgPace() -> Double {
//
//			pace = distance / timeElapsed
//			return pace
//
//	}
//
//	func miles(meters:Double)-> Double{
//			let mile = 0.000621371192
//			return meters * mile
//		}
//}
