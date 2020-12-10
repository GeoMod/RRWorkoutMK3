//
//  CoreMotionManager.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 12/8/20.
//

import CoreMotion

//final class CoreMotionManager: ObservableObject {
//
//	@Published var currentRunningPace: NSNumber = 0
//	@Published var averageRunningPace: NSNumber = 0
//
//	var pedometer: CMPedometer
//
//	init() {
//		pedometer = CMPedometer()
//	}
//
//	func startMotionUpdates() {
//		print("I got called to start motion")
//		if CMPedometer.authorizationStatus() == .authorized && CMPedometer.isStepCountingAvailable() {
//			print("You be activated")
//			getActivePace()
//		}
//	}
//
//	func getActivePace() {
//		pedometer.startUpdates(from: Date()) { (data, error) in
//			// Update UI
//			DispatchQueue.main.async {
//				print("I am running!")
//				self.currentRunningPace = data?.currentPace ?? 0
//			}
//		}
//	}
//
//
//	func stopMotionUpdates() {
//		pedometer.stopUpdates()
//	}
//
//
//}
