//
//  WorkoutButtonStyle.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/25/20.
//

import SwiftUI

struct WorkoutStartButtonStyle: ButtonStyle {
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.padding(10)
			.background(
				Group {
					if configuration.isPressed {
						Circle()
							.fill(Color.offWhite)
							.overlay(
								Circle()
									.stroke(Color.gray, lineWidth: 4)
									.blur(radius: 4)
									.offset(x: 2, y: 2)
									.mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
							)
							.overlay(
								Circle()
									.stroke(Color.white, lineWidth: 8)
									.blur(radius: 4)
									.offset(x: -2, y: -2)
									.mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
							)
					} else {
						Circle()
							.fill(Color.offWhite)
							.shadow(color: Color.gray.opacity(0.2), radius: 10, x: 10, y: 10)
							.shadow(color: Color.purple.opacity(0.5), radius: 10, x: -5, y: -5)
					}
				}
			)
	}
}

extension Color {
	static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

extension LinearGradient {
	init(_ colors: Color...) {
		self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
	}
}
