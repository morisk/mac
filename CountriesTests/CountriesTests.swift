//
//  CountriesTests.swift
//  CountriesTests
//
//  Created by Kramer V. Moris on 25/6/17.
//  Copyright © 2017 private. All rights reserved.
//

import XCTest
@testable import Countries

class CountriesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testBorderTranslation() {
		borderTranslation(json: goodJSON)
	}
    
	func borderTranslation(json: String) {
		do {
			var countries = try JSONDecoder().decode([CountryModel].self, from: json.data(using: .utf8)!)
			XCTAssert(countries.count == 3)
			XCTAssert(countries.first!.borders.count == 6)
			XCTAssert(countries.first!.borders.first! == "ISL")
			countries.borderNamingTranslate()
			XCTAssert(countries.first!.borders.first! == "Islands")
		} catch {
			XCTAssert(false) // fail, bad json
		}
    }

	func testAPIService() {
		let url = coutriesAPI.url!
		let expect = expectation(description: "http code: 200")
		let session =  URLSession(configuration: URLSessionConfiguration.default)
		let dataTask = session.dataTask(with: url) { data, response, error in
			if let error = error {
				XCTFail("Error: \(error.localizedDescription)")
				return
			} else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
				if statusCode == 200 {
					expect.fulfill()
				} else {
					XCTFail("http code: \(statusCode)")
				}
			}
		}
		dataTask.resume()
		waitForExpectations(timeout: 5, handler: nil) // real testing is here, testing for speed :)
	}

	let goodJSON = """
				[{
				"name": "Afghanistan",
				"alpha3Code": "AFG",
				"borders": [
				"ISL",
				"PAK",
				"TKM",
				"UZB",
				"TJK",
				"CHN"
				]
				},
				{
				"name": "Islands",
				"alpha3Code": "ISL",
				"borders": []
				},
				{
				"name": "Albania",
				"alpha3Code": "ALB",
				"borders": [
				"MNE",
				"GRC",
				"MKD",
				"KOS"
				]
				}]
			"""
    
}
