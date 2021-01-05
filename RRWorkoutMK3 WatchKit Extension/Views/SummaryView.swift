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
				Text("Run Summary")
					.font(.title3)
					.fontWeight(.bold)
					.padding(.bottom, 3)
				VStack(alignment: .leading, spacing: 2) {
					Label("\(totalTime.foregroundColor(.offWhite))", systemImage: "clock.fill")
					Divider()
					Label("\(totalDistance.foregroundColor(.offWhite))", systemImage: "figure.walk.circle.fill")
					Divider()
					Label("\(averagePace.foregroundColor(.offWhite))", systemImage: "speedometer")
				}
				.foregroundColor(.yellow)
				.font(.system(size: 30))

				Button(action: {
					presentationMode.wrappedValue.dismiss()
				}, label: {
					Text("Done")
						.font(.system(size: 20))
				})
			}
		}
	}
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
		SummaryView(totalDistance: Text("3.2mi"), totalTime: Text("32min"), averagePace: Text("09:28 /mi"))
    }
}
