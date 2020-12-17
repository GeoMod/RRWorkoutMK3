//
//  SummaryView.swift
//  RRWorkoutMK3 WatchKit Extension
//
//  Created by Daniel O'Leary on 12/11/20.
//

import SwiftUI

struct SummaryView: View {
	@Environment(\.presentationMode) var presentationMode

	let totalDistance: String
	let totalTime: Text
	let averagePace: String

    var body: some View {
		ScrollView {
			VStack {
				Text("Workout Complete!")
				VStack(alignment: .leading, spacing: 1) {
					Text("Time: \(totalTime.foregroundColor(.yellow))")
						.padding()
					Divider()
					Text("Dist: \(totalDistance)")
						.padding()
					Divider()
					Text("Avg: \(averagePace)")
						.padding()
				}.font(.body)
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
		SummaryView(totalDistance: "3.2mi", totalTime: Text("32min"), averagePace: "09:28/mi")
    }
}
