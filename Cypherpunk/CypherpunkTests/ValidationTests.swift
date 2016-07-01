//
//  ValidationTests.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/06/29.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import XCTest

class ValidationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testValidEmail() {
        XCTAssertTrue(isValidMailAddress("a@test.com"))
        XCTAssertTrue(isValidMailAddress("a@b.org"))
        XCTAssertTrue(isValidMailAddress("a..c@test.co.jp"))
        XCTAssertTrue(isValidMailAddress("a......c@test.email"))
        XCTAssertTrue(isValidMailAddress("ABC@XYZ.EMAIL"))
        
        XCTAssertTrue(isValidMailAddress("a@ac.jp"))
        XCTAssertTrue(isValidMailAddress("a@ac.com"))
        XCTAssertTrue(isValidMailAddress("a@icloud.com"))
        XCTAssertTrue(isValidMailAddress("a@gmail.com"))
        XCTAssertTrue(isValidMailAddress("a@ne.jp"))
        XCTAssertTrue(isValidMailAddress("a@docomo.jp"))
        XCTAssertTrue(isValidMailAddress("a@docomo.com"))
        XCTAssertTrue(isValidMailAddress("a@kddi.com"))
        XCTAssertTrue(isValidMailAddress("a@kddi.co.jp"))
        XCTAssertTrue(isValidMailAddress("a@softbank.com"))
        XCTAssertTrue(isValidMailAddress("a@softbank.co.jp"))
    }
    
    func testInValidEmail() {
        XCTAssertFalse(isValidMailAddress("abc"))
        XCTAssertFalse(isValidMailAddress("a.b.c"))
        XCTAssertFalse(isValidMailAddress("@icloud.com"))
        XCTAssertFalse(isValidMailAddress("a!@icloud.com"))
        XCTAssertFalse(isValidMailAddress("a.b.c@"))
    }
    
}
