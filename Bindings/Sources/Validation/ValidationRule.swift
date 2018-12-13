//
//  ValidationRule.swift
//  Bindings
//
//  Created by Marc Bauer on 16.06.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift

public protocol ValidationRule {
  associatedtype T

  func validate(_ value: T) -> Observable<ValidationResult>
}
