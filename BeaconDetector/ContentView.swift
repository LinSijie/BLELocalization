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
    @Published var lastBeacons: [CLBeacon] = []

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
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }

    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        print("didRange")
        if beacons.isEmpty {
            print("beacon not found")
            update(beacons: [])
        } else {
            print(String(beacons.count) + " beacons found")
            update(beacons: beacons)
        }
    }

    func update(beacons: [CLBeacon]) {
        print("update last beacon array")
        lastBeacons = beacons
    }
 }
 
 struct Triangle : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y:rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
 }
 
 struct ContentView: View {
    @ObservedObject var detector = BeaconScanner()

    var body: some View {
        VStack{
            ZStack{
                Image("map").resizable()
                Triangle()
                    .fill(Color.red)
                    .frame(width: 15, height: 15)
                    .offset(x:40, y:-100)
                
            }
    
            List(detector.lastBeacons, id: \.major) { beacon in
              BeaconInfoView(beacon: beacon)
            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


