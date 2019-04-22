//
//  Gastro_PlacesTests.swift
//  Gastro PlacesTests
//
//  Created by Michal Martinů on 22/04/2019.
//  Copyright © 2019 Michal Martinů. All rights reserved.
//

import XCTest
import CoreLocation

@testable import Gastro_Places

class InputValuesTest: XCTestCase {

    var location: CLLocation!
    var placeContext: PlaceContext!
    
    override func setUp() {
        location = CLLocation()
    }

    override func tearDown() {
        location = nil
        placeContext = nil
    }

    
    func testNameSucces() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 0, "PlaceContext input – name")
    }
    
    func testNameError() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "", phone: "", email: "", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "PlaceContext")
    }
    
    func testPhoneError1() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "1", email: "", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "PlaceContext input – 1")
    }
    
    func testPhoneError2() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "732234a56a7a", email: "", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "PlaceContext input – 732234567a")
    }
    
    func testPhoneError3() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "ahaahaaha", email: "", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "PlaceContext input – ahaahaaha")
    }
    
    func testPhoneSucces1() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "732123456", email: "", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 0, "PlaceContext input – 732123456")
    }
    
    func testPhoneSucces2() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "+420732123456", email: "", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 0, "PlaceContext input – +420732123456")
    }
    
    func testEmailError1() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "email", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "")
    }
    
    func testEmailError2() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "email@", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "")
    }
    
    func testEmailError3() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "email@.cz", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "")
    }
    
    func testEmailError4() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "email@cz", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "")
    }
    
    func testEmailError5() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "email@email.", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "")
    }
    
    func testEmailError6() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "em%ail@email.", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "")
    }
    
    func testEmailSucces1() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "email@email.cz", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 0, "")
    }
    
    func testEmailSucces2() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "em32@em.com", web: "")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 0, "")
    }
    
    func testWebError1() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "", web: "test")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "")
    }
    
    func testWebError3() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "", web: "test.")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 1, "")
    }
    
    func testWebSuccess() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "", web: "test.cz")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 0, "")
    }
    
    func testWebSuccess2() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "", email: "", web: "test.test.cz")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 0, "")
    }
    
    func testAllError() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "", phone: "w", email: "w", web: "w")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 4, "")
    }
    
    func testAllSuccess() {
        placeContext = PlaceContext(location: location)
        placeContext.changeData(cathegory: "", name: "name", phone: "732456786", email: "web@web.cz", web: "web.cz")
        
        let error = placeContext.checkInput()
        
        XCTAssertEqual(error.count, 0, "")
    }

}
