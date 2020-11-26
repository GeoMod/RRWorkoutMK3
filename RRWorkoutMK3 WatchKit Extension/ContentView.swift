//
//  ContentView.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/24/20.
//

import SwiftUI

enum TabSelection {
	case home
	case activeRun
	case pausedRun
	case runSummary
}

struct ContentView: View {


	@State var tabSelection: TabSelection


	var body: some View {
		TabView(selection: $tabSelection,
				content:  {
					// Home View/Start Button
					Button(action: {
						tabSelection = .activeRun
					}, label: {
						Image(systemName: "figure.walk.circle")
							.shadow(radius: 5)
							.font(.title)
							.foregroundColor(.purple)
					}).buttonStyle(WorkoutButtonStyle())
					.frame(width: WKInterfaceDevice.current().screenBounds.width, height: WKInterfaceDevice.current().screenBounds.height)

					.tabItem { Text("Home") }
					.tag(TabSelection.home)

					// Active Workout View
					WorkoutDetailView()
						.tabItem { Text("Active") }
						.tag(TabSelection.activeRun)

				})

	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(tabSelection: .home)
    }
}
