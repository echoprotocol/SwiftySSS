//
//  SwiftySSSTests.swift
//  SwiftySSSTests
//
//  Created by Fedorenko Nikita on 4/16/19.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import SwiftySSS

class ShamirSecretShareTests: XCTestCase {
    
    func testGF256() {
        let tester = { (got:GF256, want:GF256) -> Void in
            XCTAssert(want == got, "expected \(want), but got \(got).")
        }
        
        do {
            try tester(GF256(0xb6) * GF256(0x53), GF256(0x36))
            try tester(GF256(90) * GF256(21), GF256(254))
            try tester(GF256(7) * GF256(11), GF256(49))
            try tester(GF256(90) / GF256(21), GF256(189))
            
            try tester(GF256(90) * GF256(0), GF256(0))
            try tester(GF256(0) * GF256(21), GF256(0))
            try tester(GF256(0) * GF256(0), GF256(0))
            try tester(GF256(0) / GF256(21), GF256(0))
            
            do {
                let _ = try GF256(164) / GF256(0)
                XCTFail("No error on divBy0")
            } catch  {
                XCTAssert(error is GF256.Errors)
            }
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
    
    func testPolyGF256() {
        do {
            let poly = PolyGF256(bytes: [0x04, 0x02, 0xa3])
            let _ = try poly.evaluate(at: GF256(0x04))
            
            let _ = try GF256(0x04) + GF256(0x02)*GF256(0x04) + GF256(0xa3) * GF256(0x04) * GF256(0x04)
            
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
    
    func testSecretShare() {
        let message = Data([UInt8]("Hello World!!!".utf8))
        
        do {
            let secret = try Secret(data: message, threshold: 3, shares: 5)
            let shares = try secret.split()
            let recon  = try Secret.combine(shares: [Secret.Share](shares[1...3]))
            
            XCTAssert(recon == secret.data, "data mismatch")
            
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
    
    func testSplitPerformance() {
        do {
            let data = try Data.random(size: 1000)
            let secret = try Secret(data: data, threshold: 5, shares: 10)
            
            self.measure {
                let _ = try? secret.split()
            }
            
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
    
    func testDefinedShares() {
        let message = Data([UInt8]("Hello World!!!".utf8))
        
        do {
            let secret = try Secret(data: message, threshold: 3, shares: 6)
            let shares = try secret.split()
            let recon  = try Secret.combine(shares: [shares[0], shares[0], shares[1], shares[1], shares[2], shares[2]])
            
            XCTAssert(recon == secret.data, "data mismatch")
            
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
    
    func testDuplicateShares() {
        do {
            let secret = "Hello World!"
            let share1 = Secret.Share(point: 1, bytes: Data(hex: "8d736120eef1ca0b2b58971c")!.bytes)
            let share2 = Secret.Share(point: 2, bytes: Data(hex: "1b46510ea3e09d828f9a217c")!.bytes)
            let share3 = Secret.Share(point: 3, bytes: Data(hex: "de505c42223100e6d6aed241")!.bytes)
            let share4 = Secret.Share(point: 4, bytes: Data(hex: "cb1f8a6d9544593ab4d53807")!.bytes)
            let share5 = Secret.Share(point: 5, bytes: Data(hex: "0e0987211495c45eede1cb3a")!.bytes)
            
            let recon  = try Secret.combine(shares: [share1,share5,share2])
            let decodedSecret = String(data: recon, encoding: .utf8)
            
            XCTAssert(secret == decodedSecret)
            
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
    
    func testCombinePerformance() {
        do {
            let data = try Data.random(size: 1000)
            let secret = try Secret(data: data, threshold: 5, shares: 10)
            let shares = try [Secret.Share](secret.split()[0 ..< 5])
            
            self.measure {
                let _ = try? Secret.combine(shares: shares)
            }
            
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
    
    func testCustomRepresentation() {
        do {
            let data = try Data.random(size: 1000)
            let secret = try Secret(data: data, threshold: 5, shares: 10)
            let shares = try [Secret.Share](secret.split()[0 ..< 5])
            
            let sharesStrings = shares.map {$0.description(closure: { (point, bytes) -> String in
                return "\(point)-\(Data(bytes).hexEncodedString())"
            })}
            
            let restoredShares = try sharesStrings.map { try Secret.Share.init(closure: { (value) -> (point: UInt8, bytes: Data) in
                
                guard let stringValue = value as? String else {
                    throw "Invalid String Representation"
                }
                
                let components = stringValue.components(separatedBy: "-")

                guard let pointComponent = components.first,
                    let point = UInt8(pointComponent)  else {
                    throw "Invalid String Representation"
                }

                guard let bytesComponent = components.last,
                    let bytes = Data(hex: bytesComponent)  else {
                        throw "Invalid String Representation"
                }
                
                return (point, bytes)
                
            }, value: $0) }
            
            let reconData  = try Secret.combine(shares: restoredShares)
            XCTAssertEqual(reconData, data)
            
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
}
