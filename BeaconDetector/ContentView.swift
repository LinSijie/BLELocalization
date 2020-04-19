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
//            print(String(beacon.rssi))
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
        let n = 2.0
        let a = 58.0
        let err = 5.0
        let d1 = pow(10, ((abs(r1) - a)/(10*n)))
        let d2 = pow(10, ((abs(r2) - a)/(10*n)))
        let d3 = pow(10, ((abs(r3) - a)/(10*n)))
        print("d1 = \(d1), d2 = \(d2), d3 = \(d3)")
        //判断任意两个圆是否相切（外切），这里可以设定一个误差允许值d，也就是
        //(x1–x2)^2 + (y1-y2)^2= (r1+r2+d)^2
        var ab = pow(a1 - a2, 2) + pow(b1 - b2, 2)
        var ab_max = pow(d1 + d2 + err, 2)
        var ab_min = pow(max(d1 + d2 - err, 0.0), 2)

        if (ab < ab_max && ab > ab_min) {
            let x = a1 + (a2 - a1) * (d1 / (d1 + d2))
            let y = b1 + (b2 - b1) * (d1 / (d1 + d2))
            let d3_cal = sqrt(pow(x - a3, 2) + pow(y - b3, 2))
            print("d3 = \(d3), d3_cal = \(d3_cal)")
            if (abs(d3_cal - d3) <= err) {
                print("x = \(round(x * scale)), y = \(round(y * scale))")
                return [x * scale, y * scale]
            } else {
                var diff = d3_cal - d3
                var newx = -(x - a3) * diff / d3_cal
                var newy = -(y - b3) * diff / d3_cal
                print("newx = \(round(newx * scale)), newy = \(round(newy * scale))")
                return [newx * scale, newy * scale]
            }
        }
        return []
    }
    
    var montecarlo: [Double] {
        if detector.lastBeacons.count < 3 {
            return []
        }
        let scale = 38.537
        var arra = [Double]()
        var arrb = [Double]()
        var arrr = [Double]()
        
        for identifiableBeacon in detector.lastBeacons {
            arra.append(identifiableBeacon.beacon.major.doubleValue / scale)
            arrb.append(identifiableBeacon.beacon.minor.doubleValue / scale)
            arrr.append(Double(identifiableBeacon.beacon.rssi))
        }
        
        let n = 2.0
        let a = 58.0
        let err = 5.0
        let simtimes = 1000
        
        var arrd = [Double]()
        for rssi in arrr {
            arrd.append(pow(10, ((abs(rssi) - a)/(10*n))))
        }
        
        let minx = arra.min()
        let maxx = arra.max()
        let miny = arrb.min()
        let maxy = arrb.max()
        
        let diffx = Double(maxx!) - Double(minx!)
        let diffy = Double(maxy!) - Double(miny!)
        
        var count_x = 0.0
        var count_y = 0.0
        var sumx = 0.0
        var sumy = 0.0
        
        for _ in 0...simtimes-1 {
            let testx = Double.random(in: 0..<1) * diffx + minx!
            let testy = Double.random(in: 0..<1) * diffy + miny!
            
            //test whether this generated value is within the distance to all beacons
            var satisfy = true
            for j in 0...(detector.lastBeacons.count)-1 {
                let d_cal = sqrt(pow(testx - arra[j], 2) + pow(testy - arrb[j], 2))
                if (d_cal - err > arrd[j]) {
                    satisfy = false
                    break
                }
            }
            if (satisfy) {
                count_x += 1
                count_y += 1
                sumx += testx
                sumy += testy
            }
        }
        if (count_x > 0) {
            let x = sumx / count_x
            let y = sumy / count_y
//            print("monte: x = \(round(x * scale)), y = \(round(y * scale))")
            return [x * scale,y * scale]
        }
        return []
    }
    
    var wknn: [Double] {
        if detector.lastBeacons.count < 3 {
            return []
        }
        let scale = 38.537
        var arra = [Double]()
        var arrb = [Double]()
        var arrr = [Double]()
        
        for i in 0...(detector.lastBeacons.count)-1 {
            arra.append(detector.lastBeacons[i].beacon.major.doubleValue/scale)
            arrb.append(detector.lastBeacons[i].beacon.minor.doubleValue/scale)
            arrr.append(Double(detector.lastBeacons[i].beacon.rssi))
        }
        
        let n = 2.0
        let simtimes = 5000
        // k = 3
        var a = [0.0, 0.0, 0.0]
        var b = [0.0, 0.0, 0.0]
        var r = [999.0, 999.0, 999.0]
        
        for i in 0...(detector.lastBeacons.count)-1 {
            for j in 0...r.count-1 {
                if (abs(arrr[i]) < r[j]) {
                    if j < 2 {
                        for k in (j+1...r.count-1).reversed() {
                            
                            r[k] = r[k-1]
                            b[k] = b[k-1]
                            a[k] = a[k-1]
                        }
                    }
                    
                    r[j] = abs(arrr[i])
                    b[j] = arrb[i]
                    a[j] = arra[i]
                    break;
                }
            }
        }
        
        let d01 = pow(10.0, (r[0] - r[1])/n/10)
//        print("d01: \(d01) r: \((r[0] - r[1])/n/10)")
        let d12 = pow(10.0, (r[1] - r[2])/n/10)
        let d02 = pow(10.0, (r[0] - r[2])/n/10)
        
        
//        d01 = round(d01 * 10) //note: convert to integer!
//        d12 = round(d12 * 10) //note: convert to integer!
//        d02 = round(d02 * 10) //note: convert to integer!
        
        let minx = arra.min()
        let maxx = arra.max()
        let miny = arrb.min()
        let maxy = arrb.max()
//        let diffx = (maxx!) - (minx!)
//        let diffy = (maxy!) - (miny!)

        for _ in 0...simtimes-1 {
            let testx = Double.random(in: minx!...maxx!)
            let testy = Double.random(in: miny!...maxy!)
            
            let d0 = sqrt(pow(Double(testx - a[0]), 2) + pow(Double(testy - b[0]), 2));
            let d1 = sqrt(pow(Double(testx - a[1]), 2) + pow(Double(testy - b[1]), 2));
            let d2 = sqrt(pow(Double(testx - a[2]), 2) + pow(Double(testy - b[2]), 2));
            
            let d01_cal = d0/d1; //note: convert to integer!
            let d12_cal = d1/d2; //note: convert to integer!
            let d02_cal = d0/d2; //note: convert to integer!

            if (abs(d01_cal - Double(d01 as NSNumber)) < 0.3 && abs(d12_cal - Double(d12 as NSNumber)) < 0.3 && abs(d02_cal - Double(d02 as NSNumber)) < 0.3){
//                print("wknn: x = \(testx), y = \(testy)")
                return [testx*scale, testy*scale]
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
                            .opacity(0.7)
                        ForEach(self.detector.lastBeacons) { identifiableBeacon in
                            Image("ibeacon").resizable().frame(width: 30, height: 35)
                            .offset(x: CGFloat(truncating: identifiableBeacon.beacon.major)-200, y: CGFloat(truncating: identifiableBeacon.beacon.minor)-311)
                        }
                        // user device position
//                        // three points
//                        if self.threePoint.count == 2 {
//                            Triangle()
//                            .fill(Color.red)
//                            .frame(width: 10, height: 10)
//                                .offset(x: CGFloat(self.threePoint[0] - 200), y: CGFloat(self.threePoint[1] - 311))
//                        }
//                        // montecarlo
//                        if self.montecarlo.count == 2 {
//                            Triangle()
//                            .fill(Color.yellow)
//                            .frame(width: 10, height: 10)
//                                .offset(x: CGFloat(self.montecarlo[0] - 200), y: CGFloat(self.montecarlo[1] - 311))
//                        }
//                        // wknn
//                        if self.wknn.count == 2 {
//                            Triangle()
//                            .fill(Color.blue)
//                            .frame(width: 10, height: 10)
//                                .offset(x: CGFloat(self.wknn[0] - 200), y: CGFloat(self.wknn[1] - 311))
//                        }
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


