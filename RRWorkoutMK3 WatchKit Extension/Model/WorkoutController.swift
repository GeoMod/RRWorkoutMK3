//
//  WorkoutController.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/25/20.
//

import Combine
import HealthKit


final class WorkoutController: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {

	/// - Tag: Workout Publishers
	@Published var activeCalories: 	Double 	= 0
	@Published var distance: 		Double	= 0
	@Published var heartrate: 		Double	= 0
	@Published var avgHeartRate: 	Double 	= 0
	@Published var elapsedSeconds: 	Int 	= 0
	@Published var averagePace = "00:00"

	private let paceManager = RunPaceManager()

	/// - Tag: TimerSetup
	// The cancellable holds the timer publisher.
	var accumulatedTime = 0
	var cancellable: Cancellable?
	var start = Date()

	let healthStore = HKHealthStore()
	var session: HKWorkoutSession!
	var builder: HKLiveWorkoutBuilder!

	var workoutRunning = false

	public func setupWorkoutSession() {
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

	private func beginWorkout() {
		/*
		From Apple: "You must make this request in both the WatchKit extension
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

		// Start the Pedometer
		paceManager.startMotionUpdates(.milesPerHour) { [weak self] (newPace) in
			DispatchQueue.main.async {
				self?.averagePace = newPace
			}
		}

		builder.beginCollection(withStart: Date()) { (success, error) in
			// the workout has started
		}
	}

	private func setUpTimer() {
		start = Date()
		cancellable = Timer.publish(every: 0.001, tolerance: 0.001,on: .main, in: .default).autoconnect()
			.sink{ [weak self] _ in
				guard let self = self else { return }
				self.elapsedSeconds = self.incrementElapsedTime()
			}
	}

	// Calculate the elapsed time.
	private func incrementElapsedTime() -> Int {
		/*
		The apparent redundancy in the use of `accumulatedTime` and elapsedTime is due to the need for
		resuming the timer when the user pauses, then resumes a run.
		Without this the timer will reset to 0 after a run is paused and resumed.
		*/
		let runningTime: Int = Int(-1 * (start.timeIntervalSinceNow))
		return accumulatedTime + runningTime
	}

	public func pauseWorkout() {
		session.pause()
		// Stop the timer
		cancellable?.cancel()
		// save elapsed time
		accumulatedTime = elapsedSeconds
		workoutRunning = false
	}

	public func resumeWorkout() {
		session.resume()

		setUpTimer()
		workoutRunning = true
	}

	public func endWorkout() {
		session.end()
		// Stop the timer
		cancellable?.cancel()
		accumulatedTime = 0
		paceManager.stopMotionUpdates()
	}

	public func getAverageHeartRateFromWorkout() {
		guard let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
		let predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: start, end: Date(), options: HKQueryOptions.strictEndDate)

		let query = HKStatisticsQuery(quantityType: heartRate, quantitySamplePredicate: predicate, options: .discreteAverage) { (statsQuery, results, error) in
			DispatchQueue.main.async {
				let quantity = results?.averageQuantity()
				let averageBeatsPerMinute = quantity?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
				self.avgHeartRate = averageBeatsPerMinute ?? 999
			}
		}
		healthStore.execute(query)
	}

	private func resetWorkout() {
		// Reset the published values.
		DispatchQueue.main.async {
			self.elapsedSeconds = 0
			self.activeCalories = 0
			self.heartrate = 0
			self.distance = 0
		}
	}

	// MARK: Updating the UI
	private func updateLabels(withStatistics statistics: HKStatistics?) {
		guard let statistics = statistics else { return }

		// Update user interface.
		DispatchQueue.main.async {
			switch statistics.quantityType {
			case HKQuantityType.quantityType(forIdentifier: .heartRate):
				let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
				let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
//				let roundedValue = Double(round(value))
				let roundedValue = round(value)
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
		// could be used to mark distance increments if you wanted to include audio alerts at mile/km intervals.
	}



	func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
		// MARK: Elevation infomation can be found here:
		// https://developer.apple.com/documentation/healthkit/hkmetadatakeyelevationdescended

	}

	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		// no errors handled
	}

}
