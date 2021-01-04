//
//  SummaryView.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 12/11/20.
//

import SwiftUI

struct SummaryView: View {
	@Environment(\.presentationMode) var presentationMode

	let totalDistance: Text
	let totalTime: Text
	let averagePace: Text

    var body: some View {
		ScrollView {
			VStack {
				Text("Run Roster")
				VStack(alignment: .leading, spacing: 1) {
					Text("Time: \(totalTime.foregroundColor(.yellow))")
						.fontWeight(.bold)
						.padding()
					Divider()
					Text("Distance: \(totalDistance.foregroundColor(.green))")
						.fontWeight(.bold)
						.padding()
					Divider()
					Text("Avg Pace: \(averagePace.foregroundColor(.yellow))")
						.fontWeight(.bold)
						.padding()
				}
				.font(.body)
				Spacer()
				Button(action: {
					presentationMode.wrappedValue.dismiss()
				}, label: {
					Text("Done")
				})
				.frame(width: 150, height: 45)
			}.font(.headline)
		}
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
		SummaryView(totalDistance: Text("3.2mi"), totalTime: Text("32min"), averagePace: Text("09:28 /mi"))
    }
}
