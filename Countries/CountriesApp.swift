//
//  MacCountries.swift
//  MacCountriesFramework
//
//  Created by Kramer V. Moris on 23/6/17.
//  Copyright © 2017 objc.io. All rights reserved.
//

import VirtualViews

let coutriesAPI = URLRequest(url: URL(string:  "https://restcountries.eu/rest/v2/all?fields=name;alpha3Code;borders")!)

public struct CountriesApp {
	var countries: [CountryModel]
	var selectedCountryIndex: Int?

	public init() {
		countries = []
		selectedCountryIndex = nil
	}
}

extension CountryModel {
	var tableView: TableView<CountriesApp.Message> {
		let cells: [TableViewCell<CountriesApp.Message>] = borders.enumerated().map { el in
			let (_, country) = el
			return TableViewCell<CountriesApp.Message>(text: country, onSelect: nil, accessory: .none, onDelete: nil)
		}
		return TableView<CountriesApp.Message>(items: cells)
	}
}

extension Array where Element == CountryModel {
	var tableViewController: ViewController<CountriesApp.Message> {
		let cells: [TableViewCell<CountriesApp.Message>] = zip(self, self.indices).map { (el) in
			let (item, index) = el
			return TableViewCell(text: item.name, onSelect: .select(listIndex: index), onDelete: nil)
		}
		return ViewController.tableViewController(TableView(items: cells))
	}
}

extension CountriesApp: RootComponent {

	public enum Message {
		case back
		case select(listIndex: Int)
		case reloadCountries
		case createList(Data?)
	}

	var selectedList: CountryModel? {
		get {
			guard let i = selectedCountryIndex else { return nil }
			return countries[i]
		}
		set {
			guard let i = selectedCountryIndex, let value = newValue else { return }
			countries[i] = value
		}
	}

	public var viewController: ViewController<Message> {
		let reloadCountries: BarButtonItem<Message> = BarButtonItem.system(.play, action: .reloadCountries)

		var viewControllers: [NavigationItem<Message>] = [
			NavigationItem(title: "Countries", leftBarButtonItem: nil, rightBarButtonItems: [reloadCountries], viewController: countries.tableViewController)
		]
		if let list = selectedList {
			viewControllers.append(NavigationItem(title: list.name, rightBarButtonItems: [.system(.add, action: .back)], viewController: .tableViewController(list.tableView)))
		}
		return ViewController.navigationController(NavigationController(viewControllers: viewControllers, back: .back))
	}

	mutating public func send(_ msg: Message) -> [Command<Message>] {
		switch msg {
		case .reloadCountries:
			return [
				.request(coutriesAPI) {
					.createList($0)
				}
			]

		case .createList(let data):
			guard let data = data else { return [] } // Pressed cancel
			do {
				countries = try JSONDecoder().decode([CountryModel].self, from: data)
				countries.borderNamingTranslate()
			} catch {
				countries = []
			}
			return []
		case .select(listIndex: let index):
			selectedCountryIndex = index
			return []
		case .back:
			selectedCountryIndex = nil
			return []
		}
	}

	public var subscriptions: [Subscription<Message>] {
		return []
	}
}

extension CountriesApp.Message: Equatable {
	public static func ==(lhs: CountriesApp.Message, rhs: CountriesApp.Message) -> Bool {
		switch (lhs, rhs) {
		case (.back, .back): return true
		case (.select(let l), .select(let r)): return l == r
		default: return false
		}
	}
}

