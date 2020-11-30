//
//  ContentView.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 11/24/20.
//

import SwiftUI

struct ContentView: View {

	@State var tabSelection: TabSelection

	var body: some View {
		TabView(selection: $tabSelection,
				content:  {
					// Home View/Start Button
					// MARK: Will be replaced in main app
					Button(action: {
						tabSelection = .activeRun
					}, label: {
						Image(systemName: "figure.walk.circle")
							.shadow(radius: 5)
							.font(.title)
							.foregroundColor(.purple)
					})
					.buttonStyle(WorkoutStartButtonStyle())
					.frame(width: WKInterfaceDevice.current().screenBounds.width, height: WKInterfaceDevice.current().screenBounds.height)

					.tabItem { Text("Home") }
					.tag(TabSelection.home)

					WorkoutDetailView(tabSelection: $tabSelection)
						.tabItem { Text("Active") }
						.tag(TabSelection.activeRun)

					SummaryView()
						.tabItem { Text("Summary") }
						.tag(TabSelection.runSummary)
					// Placing animation here will not animate tab transitions.
				})
			// Placing animation modifier around all content will
			// animate transitions and button actions.
			.animation(.easeInOut(duration: 2.0))

	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(tabSelection: .home)
    }
}
