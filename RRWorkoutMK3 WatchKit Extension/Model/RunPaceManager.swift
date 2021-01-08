//
//  CoreMotionManager.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 12/8/20.
//

import CoreMotion

extension WorkoutController {
	class RunPaceManager {

		private let pedometer = CMPedometer()
		private let now = Date()

		public func startMotionUpdates(_ unitOfMeasurement: UnitOfSpeedMeasurement, _ callback: @escaping (String) -> Void) {
			if CMPedometer.isPaceAvailable() {
				pedometer.startUpdates(from: now) { (data, error) in
					// Get the current pace, if there isn't one set it as Zero
					guard let pace = data?.averageActivePace else { return }

					callback(self.convert(pace: pace, to: unitOfMeasurement))
				}
			} else {
				print("No Pedometer to start updating")
			}
		}

		public func stopMotionUpdates() {
			if CMPedometer.isPaceAvailable() {
				pedometer.stopUpdates()
			} else {
				print("No Pedometer to stop.")
			}
		}

		private func convert(pace: NSNumber, to speed: UnitOfSpeedMeasurement) -> String  {
			/*
			metersPerSecond is given from CoreMotion as an NSNumber. But...
			the original pace value is given as "Seconds per Meter", not Meters per Second.
			Mathematically (1 / pace) converts to Meters per Second
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
}
