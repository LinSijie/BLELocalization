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
 
 struct identifiableBeacon: Identifiable {
    var id = UUID()
    var beacon: CLBeacon
 }
 
 class BeaconScanner: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    @Published var lastBeacons: [identifiableBeacon] = []

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
        lastBeacons = []
        for beacon in beacons {
            print(String(beacon.rssi))
            lastBeacons.append(identifiableBeacon(beacon: beacon))
        }
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
    @State var showList = false
    
    var threePoint: [Double] {
        if detector.lastBeacons.count < 3 {
            return []
        }
        let scale = 38.537
        let a1 = detector.lastBeacons[0].beacon.major.doubleValue / scale
        let b1 = detector.lastBeacons[0].beacon.minor.doubleValue / scale
        let a2 = detector.lastBeacons[1].beacon.major.doubleValue / scale
        let b2 = detector.lastBeacons[1].beacon.minor.doubleValue / scale
        let a3 = detector.lastBeacons[2].beacon.major.doubleValue / scale
        let b3 = detector.lastBeacons[2].beacon.minor.doubleValue / scale
        let r1 = Double(detector.lastBeacons[0].beacon.rssi)
        let r2 = Double(detector.lastBeacons[1].beacon.rssi)
        let r3 = Double(detector.lastBeacons[2].beacon.rssi)
        let n = 3.25
        let a = 45.0
        let d1 = pow(10, ((abs(r1) - a)/(10*n)))
        let d2 = pow(10, ((abs(r2) - a)/(10*n)))
        let d3 = pow(10, ((abs(r3) - a)/(10*n)))
        print("d1 = \(d1), d2 = \(d2), d3 = \(d3)")

        let zero = pow(a1 - a2, 2) + pow(b1 - b2, 2) - pow(d1 + d2, 2);
        print("zero = \(zero)")
        if (abs(zero) < 100) {
            let x = a1 + (a2 - a1) * (d1 / (d1 + d2));
            let y = b1 + (b2 - b1) * (d1 / (r1 + d2));
            let d3_cal = sqrt(pow(x - a3, 2) + pow(y - b3, 2))
        
            if (d3 - d3_cal < 10) {
                print("x = \(round(x * scale)), y = \(round(y * scale))")
                return [round(x * scale),round(y * scale)]
            }
        }
        return []
    }

    var body: some View {
        let drag = DragGesture().onEnded{
            if $0.translation.width < -100 {
                withAnimation {
                    self.showList = false
                }
            }
        }
        return NavigationView {
            GeometryReader { geometry in
                ZStack (alignment: .leading) {
                    ZStack {
                        Image("map")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 400, height: 622).opacity(0.2)
                        ForEach(self.detector.lastBeacons) { identifiableBeacon in
                            Image("ibeacon").resizable().frame(width: 30, height: 35)
                            .offset(x: CGFloat(truncating: identifiableBeacon.beacon.major)-200, y: CGFloat(truncating: identifiableBeacon.beacon.minor)-311)
                        }
                        // user device position
                        // three points
                        if self.threePoint.count == 2 {
                            Triangle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                                .offset(x: CGFloat(self.threePoint[0] - 200), y: CGFloat(self.threePoint[1] - 311))
                        }
                        // TODO: other algorithm
                    }
            
                    if self.showList {
                        List(self.detector.lastBeacons) { identifiableBeacon in
                            BeaconInfoView(beacon: identifiableBeacon.beacon)
                        }.frame(width: geometry.size.width * 4 / 5).transition(.move(edge: .leading))
                        
                    }
                }.gesture(drag)
            }.navigationBarTitle(Text("BLE Localization"), displayMode: .inline)
            .navigationBarItems(leading: (
                Button( action: {
                    withAnimation{
                        self.showList.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3").imageScale(.large)
                }
            ))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


