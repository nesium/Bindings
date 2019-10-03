//
//  EqualValidationRule.swift
//  Bindings
//
//  Created by Marc Bauer on 16.06.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift

public struct EqualValidationRule: ValidationRule {
  public init() {}

  public func validate(_ value: (String, String)) -> Observable<ValidationResult> {
    let result: ValidationResult = value.0 == value.1
      ? .valid
      : .invalid(localizedDescription: "Not equal")
    return Observable.of(result)
  }
}
