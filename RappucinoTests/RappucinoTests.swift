//
//  RappucinoTests.swift
//  RappucinoTests
//
//  Created by Logan Geefs on 2018-05-31.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import XCTest
@testable import Rappucino

class RappucinoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fv = (storyboard.instantiateInitialViewController() as! UITabBarController).viewControllers?.first as! FirstViewController
        let _ = fv.view
        XCTAssertEqual(fv.recordButton.titleLabel?.text, "Button")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
