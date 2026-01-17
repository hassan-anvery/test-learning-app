//
//  TennisBallLogo.swift
//  TennisChartingApp
//

import SwiftUI

struct TennisBallLogo: View {
    var size: CGFloat = 80

    var body: some View {
        Image(systemName: "tennisball.fill")
            .font(.system(size: size))
            .foregroundColor(.green)
    }
}

#Preview {
    TennisBallLogo()
}
