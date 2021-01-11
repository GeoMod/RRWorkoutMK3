//
//  Globals.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/30/20.
//

import Foundation

public enum TabSelection {
	case home
	case activeRun
	case pausedRun
	case runSummary
}

public enum UnitOfSpeedMeasurement {
	case kilometersPerHour
	case milesPerHour
}



// Helper used to convert seconds of a run to readable hh:mm:ss
struct TimeConvert {
	static func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
		(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
	}

	// Convert the seconds, minutes, hours into a string.
	static func elapsedTimeString(elapsed: (h: Int, m: Int, s: Int)) -> String {
		String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
	}
}


