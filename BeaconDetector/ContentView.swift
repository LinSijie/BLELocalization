 //
//  ContentView.swift
//  BeaconScanner
//
//  Created by 林思劼 on 3/24/20.
//  Copyright © 2020 林思劼. All rights reserved.
//
import Combine
import CoreLocation
import SwiftUI
 
 class BeaconScanner: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    @Published var lastDistance = CLProximity.unknown
    @Published var lastRSSI = -99

    override init() {
        super.init()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("authorizedWhenInUse")
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                print("isMonitoringAvailable")
                if CLLocationManager.isRangingAvailable(){
                    print("isRangingAvailable")
                    // we are good to go!
                    startScanning()
                }
            }
        }
    }

    func startScanning() {
        print("Start Scanning")
        let uuid = UUID(uuidString: "5a4bcfce-174e-4bac-a814-092e77f6b7e5")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }

    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        print("didRange")
        if let beacon = beacons.first {
            print("beacon = beacons.first")
            update(distance: beacon.proximity, rssi: beacon.rssi)
        } else {
            print("beacon = unknown")
            update(distance: .unknown, rssi: -99)
        }
    }

    func update(distance: CLProximity, rssi: Int) {
        print("update lastdistance")
        lastDistance = distance
        lastRSSI = rssi
    }
 }
 
 struct BigText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 72, design: .rounded))
    }
 }

struct ContentView: View {
    @ObservedObject var detector = BeaconScanner()
    
    var body: some View {
        if detector.lastDistance == .immediate {
            return VStack {
                VStack {
                    Text("IMMEDIATE")
                        .font(Font.system(size: 72, design: .rounded))
                    Text("RSSI = " + String(detector.lastRSSI))
                        .font(Font.system(size: 36, design: .rounded))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.red)
                .edgesIgnoringSafeArea(.all)
            }
        } else if detector.lastDistance == .near {
            return VStack {
                VStack {
                    Text("NEAR")
                        .font(Font.system(size: 72, design: .rounded))
                    Text("RSSI = " + String(detector.lastRSSI))
                        .font(Font.system(size: 36, design: .rounded))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.orange)
                .edgesIgnoringSafeArea(.all)
            }
        } else if detector.lastDistance == .far {
            return VStack {
                VStack {
                    Text("FAR")
                        .font(Font.system(size: 72, design: .rounded))
                    Text("RSSI = " + String(detector.lastRSSI))
                        .font(Font.system(size: 36, design: .rounded))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.blue)
                .edgesIgnoringSafeArea(.all)
            }
        } else {
            return VStack {
                VStack {
                    Text("UNKNOWN")
                        .font(Font.system(size: 72, design: .rounded))
                    Text("RSSI = " + String(detector.lastRSSI))
                        .font(Font.system(size: 36, design: .rounded))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.gray)
                .edgesIgnoringSafeArea(.all)
            }
        }
//        Text("RSSI: ")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
