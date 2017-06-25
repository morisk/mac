import Foundation

public struct CountryModel: Decodable {
	public let name : String
	public let alpha3Code : String
	public var borders : Array<String>

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		name = try container.decode(String.self, forKey: .name)
		alpha3Code = try container.decode(String.self, forKey: .alpha3Code)
		borders = try container.decode(Array<String>.self, forKey: .borders)
	}

	public mutating func translate(toBorderNames: Array<String>) {
		borders = toBorderNames
	}

	private enum CodingKeys: String, CodingKey {
		case name, alpha3Code, borders
	}
}

//Helpers
extension Array where Element == CountryModel {
 	public mutating func borderNamingTranslate() {
		let translator = Dictionary(elements: self.map { ($0.alpha3Code, $0.name) } )
		self = self.map { item in
			var item = item
			let names = item.borders.map { translator[$0] ?? "\($0), full name missing"} // when missing 3-Code key, dont translate
			item.translate(toBorderNames: names)
			return item
		}
	}
}


