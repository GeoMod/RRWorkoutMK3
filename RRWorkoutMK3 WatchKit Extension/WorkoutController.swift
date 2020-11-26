//
//  WorkoutController.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/25/20.
//

import Combine
import HealthKit


class WorkoutController: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {

	/// - Tag: Publishers
	// MARK: Switch to main properties when finished.
	@Published var activeCalories: 	Double 	= 0
	@Published var distance: 		Double	= 0
	@Published var heartrate: 		Double	= 0
	@Published var elapsedSeconds: 	Int 	= 0

	/// - Tag: TimerSetup
	// The cancellable holds the timer publisher.
	var start: Date = Date()
	var cancellable: Cancellable?
	var accumulatedTime: Int = 0

	let healthStore = HKHealthStore()
	var session: HKWorkoutSession!
	var builder: HKLiveWorkoutBuilder!

	var workoutRunning = false

	func setUpTimer() {
		start = Date()
		cancellable = Timer.publish(every: 0.001, tolerance: 0.001,on: .main, in: .default).autoconnect()
			.sink{ [weak self] _ in
				guard let self = self else { return }
				self.elapsedSeconds = self.incrementElapsedTime()
			}
	}

	// Calculate the elapsed time.
	func incrementElapsedTime() -> Int {
		let runningTime: Int = Int(-1 * (self.start.timeIntervalSinceNow))
		return self.accumulatedTime + runningTime
	}


	func setupWorkoutSession() {
		let typesToShare: Set = [HKQuantityType.workoutType()]

		let typesToRead: Set = [
			HKQuantityType.quantityType(forIdentifier: .heartRate)!,
			HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
			HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
		]
		// Request authorization for those quantity types.
		// MARK: Reference Info.plist to view Privacy permissions needed to request authorization from the user.
		healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
			// Handle errors.
			if success {
				self.beginWorkout()
			}
		}
	}

	func beginWorkout() {
		/* From Apple: "You must make this request in both the WatchKit extension
		and in the companion iOS app, because watchOS will ask the user to give
		authorization on the companion iPhone."
		*/
		setUpTimer()

		let configuration = HKWorkoutConfiguration()
		configuration.activityType = .running
		configuration.locationType = .outdoor

		do {
			session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
			builder = session.associatedWorkoutBuilder()
		} catch {
			// handle errors
			fatalError("Workout configuration may be invalid.")
		}

		session.delegate = self
		builder.delegate = self
		builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

		session.startActivity(with: Date())
		builder.beginCollection(withStart: Date()) { (success, error) in
			// the workout has started
		}
	}

	func togglePause() {
		if workoutRunning == true {
			 pauseWorkout()
		} else {
			resumeWorkout()
		}
	}

	func pauseWorkout() {
		session.pause()
		// Stop the timer
		cancellable?.cancel()
		// save elapsed time
		accumulatedTime = elapsedSeconds
		workoutRunning = false
	}

	func resumeWorkout() {
		session.resume()

		setUpTimer()
		workoutRunning = true
	}

	func endWorkout() {
		session.end()
		// Stop the timer
		cancellable?.cancel()
	}

	func resetWorkout() {
		// Reset the published values.
		DispatchQueue.main.async {
			self.elapsedSeconds = 0
			self.activeCalories = 0
			self.heartrate = 0
			self.distance = 0
		}
	}

	// MARK: Updating the UI
	func updateLabels(withStatistics statistics: HKStatistics?) {
		guard let statistics = statistics else { return }

		// Dispatch to main, because we are updating the interface.
		DispatchQueue.main.async {
			switch statistics.quantityType {
			case HKQuantityType.quantityType(forIdentifier: .heartRate):
				let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
				let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
				let roundedValue = Double(round(value))
				self.heartrate = roundedValue
			case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
				let energyUnit = HKUnit.kilocalorie()
				let value = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
				let roundedValue = Double(round(value))
				self.activeCalories = roundedValue
			case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
				let distanceUnit = HKUnit.mile()
				let value = statistics.sumQuantity()?.doubleValue(for: distanceUnit) ?? 0
				let roundedValue = Double(round(100*value)/100)
				self.distance = roundedValue
			default:
				return
			}
		}
	}

	// Track elapsed time.
//	func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
//		// Retreive the workout event.
//		guard let workoutEventType = workoutBuilder.workoutEvents.last?.type else { return }
//		// Update the timer based on the event received.
//		switch workoutEventType {
//			case .pause:
//				setDurationTimerDate(.paused)
//			case .resume:
//				setDurationTimerDate(.running)
//			default:
//				return
//		}
//	}

//	func setDurationTimerDate(_ sessionState: HKWorkoutSessionState){
//		let elapsedTime = builder.elapsedTime
//
//		let timerDate = Date(timeInterval: -builder.elapsedTime, since: Date())
//
//		dateComponentsFormatter.unitsStyle = .full
//		dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
//
//		if let formattedTime = dateComponentsFormatter.string(from: timerDate, to: Date()) {
//			DispatchQueue.main.async {
//				self.time = formattedTime
//			}
//		}
//
//	}

	// MARK: - HKWorkoutSessionDelegate
	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
		// From the docs:
		// You may receive the notification long after the state changed.
		// Check the date parameter to determine when the state change actually occurred.

		if toState == .ended {
			builder.endCollection(withEnd: Date()) { (success, error) in
				self.builder.finishWorkout { (workout, error) in
					self.resetWorkout()
				}
			}
		}

		//		switch (toState, fromState) {
		//			case (.prepared, .notStarted):
		//				// call session.prepare() to move to this state
		//				print("Workout not started")
		//			case (.running, .prepared):
		//				print("Workout prepared")
		//			case (.running, .paused):
		//				print("Workout resumed")
		//			case (.ended, .paused):
		//				print("Workout ended")
		//				endWorkout()
		//			case (.paused, .running):
		//				print("Workout paused")
		//			default:
		//				return
		//		}
	}

	// MARK: - HKLiveWorkoutBuilderDelegate
	func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
		for type in collectedTypes {
			guard let quantityType = type as? HKQuantityType else { return }
			let statistics = workoutBuilder.statistics(for: quantityType)

			updateLabels(withStatistics: statistics)
		}
	}

	func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
		// required but unused.
	}



	func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
		// MARK: Elevation infomation can be found here:
		// https://developer.apple.com/documentation/healthkit/hkmetadatakeyelevationdescended
	}

	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		// no errors handled
	}


//	func workoutTimeSummary(from duration: TimeInterval) {
//		dateComponentsFormatter.allowedUnits = [.hour, .minute, .second]
//		dateComponentsFormatter.unitsStyle = .abbreviated
//
//		if let outputString = dateComponentsFormatter.string(from: duration) {
//			DispatchQueue.main.async {
//				self.NEWelapsedSeconds = outputString
//			}
//		} else {
//			DispatchQueue.main.async {
//				self.NEWelapsedSeconds = "hh:mm:ss"
//			}
//		}
//	}


}
