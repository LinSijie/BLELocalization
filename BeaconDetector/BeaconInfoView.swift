//
//  BeaconInfoView.swift
//  BeaconDetector
//
//  Created by 林思劼 on 4/1/20.
//  Copyright © 2020 林思劼. All rights reserved.
//

import SwiftUI
import CoreLocation

struct BeaconInfoView: View {
    var beacon: CLBeacon
    
    var body: some View {
        var color: Color
        var text: String
        switch beacon.proximity {
        case .immediate:
            text = "IMMEDIATE"
            color = Color.red
        case .near:
            text = "NEAR"
            color = Color.orange
        case .far:
            text = "FAR"
            color = Color.blue
        default:
            text = "UNKNOWN"
            color = Color.gray
        }
        
        return HStack {
            VStack(alignment: .leading) {
                
                Text(text)
                    .font(Font.system(size: 36, design: .rounded))
                
                HStack {
                    Text("RSSI = " + String(beacon.rssi))
                    Text("Major: " + String(beacon.major.intValue))
                    Text("Minor: " + String(beacon.minor.intValue))
                }
                .font(Font.system(size: 18, design: .rounded))
            }
            Spacer()
            Image(systemName: "star.fill")
            .imageScale(.large)
            .foregroundColor(color)
        }
        .padding()
    }
}

struct BeaconInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconInfoView(beacon: CLBeacon())
    }
}
