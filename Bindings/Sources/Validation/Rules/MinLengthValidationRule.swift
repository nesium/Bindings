//
//  MinLengthValidationRule.swift
//  Bindings
//
//  Created by Marc Bauer on 16.06.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift

public struct MinLengthValidationRule: ValidationRule {
  public let minLength: Int

  public init(_ minLength: Int) {
    self.minLength = minLength
  }

  public func validate(_ value: String) -> Observable<ValidationResult> {
    let result: ValidationResult = value.count >= self.minLength
      ? .valid
      : .invalid(localizedDescription: "Too short")
    return Observable.of(result)
  }
}
