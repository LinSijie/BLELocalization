 //
//  ContentView.swift
//  BeaconScanner
//
//  Created by Xingying Ma on 4/15/20.
//  Copyright © 2020 Xingying Ma. All rights reserved.
//
import Combine
import CoreLocation
import SwiftUI

 struct ContentView: View {
      @State var oneText = ""
      @State var twoText = ""
      @State var threeText = ""
      @State var four = ""
      @State var five = ""
      @State var six = ""
      @State var seven = ""
      @State var eight = ""
      @State var nine = ""
      @State var showanswer = false
     @State var countx = 0.0
     @State var county = 0.0
     var body: some View {
        VStack{
            Group {
            
            VStack{
                Text("K-means Calculation").bold()
                    .foregroundColor(.orange)
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }.frame(height:50)
            .cornerRadius(8)
            .padding(EdgeInsets(top: -200, leading: 0, bottom: 0, trailing: 0))
            
            //first
            VStack{
                TextField("x1", text: $oneText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.keyboardType(.numberPad)
                        .padding()
                     Spacer()
                 }.frame(height:50)
                     //.background(Color.gray)
                     .cornerRadius(8)
                     .padding(EdgeInsets(top: -120, leading: 10, bottom: 0, trailing: 230))
        
            VStack{
                TextField("y1", text: $twoText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    //.keyboardType(.numberPad)
                    .padding()
                Spacer()
            }.frame(height:50)
                //.background(Color.gray)
                .cornerRadius(8)
                .padding(EdgeInsets(top: -120, leading: 120, bottom: 0, trailing: 120))
            
            VStack{
                TextField("RSSI 1", text: $threeText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    //.keyboardType(.numberPad)
                    .padding()
                Spacer()
            }.frame(height:50)
                //.background(Color.gray)
                .cornerRadius(8)
                .padding(EdgeInsets(top: -120, leading: 230, bottom: 0, trailing: 10))
        
                //second
                VStack{
                         TextField("x2 ", text: $four)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            //.keyboardType(.numberPad)
                            .padding()
                         Spacer()
                     }.frame(height:50)
                         //.background(Color.blue)
                         .cornerRadius(8)
                         .padding(EdgeInsets(top: -70, leading: 10, bottom: 0, trailing: 230))
            
                VStack{
                    TextField("y2", text: $five)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.keyboardType(.numberPad)
                        .padding()
                    Spacer()
                }.frame(height:50)
                    //.background(Color.blue)
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: -70, leading: 120, bottom: 0, trailing: 120))
                
                VStack{
                    TextField("RSSI 2", text: $six)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.keyboardType(.numberPad)
                        .padding()
                    Spacer()
                }.frame(height:50)
                    //.background(Color.blue)
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: -70, leading: 230, bottom: 0, trailing: 10))
            
                //third
                VStack{
                         TextField("x3", text: $seven)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            //.keyboardType(.numberPad)
                            .padding()
                         Spacer()
                     }.frame(height:50)
                         //.background(Color.blue)
                         .cornerRadius(8)
                         .padding(EdgeInsets(top: -20, leading: 10, bottom: 0, trailing: 230))
            
                VStack{
                    TextField("y3", text: $eight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.keyboardType(.numberPad)
                        .padding()
                    Spacer()
                }.frame(height:50)
                    //.background(Color.blue)
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: -50, leading: 120, bottom: 0, trailing: 120))
            }
                
                VStack{
                    TextField("RSSI 3", text: $nine)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.keyboardType(.numberPad)
                        .padding()
                    Spacer()
                }.frame(height:50)
                    //.background(Color.blue)
                    .cornerRadius(8)
                    .padding(EdgeInsets(top: -50, leading: 230, bottom: 0, trailing: 10))
                
                
            VStack(spacing:100){
                    Button(action: {
                        self.Kmeans()
                        self.showanswer.toggle()
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.title)
                            Text("Calculate")
                                .fontWeight(.semibold)
                                .font(.title)
                            }.padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(40)
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    }
            
            if showanswer {
                VStack{
                    Text(String(countx))
                        .font(.largeTitle)
                    Text(String(county))
                    .font(.largeTitle)
                }.frame(height:50)
            }
            }
        
     }

 }
    
func Kmeans() {
        
    let a1 = Double(oneText)!
    let b1 = Double(twoText)!
    let a2 = Double(four)!
    let b2 = Double(five)!
    let a3 = Double(seven)!
    let b3 = Double(eight)!
    let r1 = Double(threeText)!
    let r2 = Double(six)!
    let r3 = Double(nine)!
    let n = 3.25
    let a = 45.0
    let d1 = pow(10, ((abs(r1) - a)/(10*n)))
    let d2 = pow(10, ((abs(r2) - a)/(10*n)))
    let d3 = pow(10, ((abs(r3) - a)/(10*n)))

    let zero = pow(a1 - a2, 2) + pow(b1 - b2, 2) - pow(d1 + d2, 2);

    if (abs(zero) < 10) {
        let x = a1 + (a2 - a1) * (d1 / (d1 + d2));
        let y = b1 + (b2 - b1) * (d1 / (r1 + d2));
        let d3_cal = sqrt(pow(x - a3, 2) + pow(y - b3, 2))
    
        if (d3 - d3_cal < 10) {
            countx =  round(x)
            county = round(y)
        }
    
    }
    }
    
 struct NormalTextFieldDemo_Previews: PreviewProvider {
     static var previews: some View {
         ContentView()
     }
 }
 }
