//
//  MaxLengthValidationRule.swift
//  Bindings
//
//  Created by Marc Bauer on 16.06.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift

public struct MaxLengthValidationRule: ValidationRule {
  public let maxLength: Int

  public init(_ maxLength: Int) {
    self.maxLength = maxLength
  }

  public func validate(_ value: String) -> Observable<ValidationResult> {
    let result: ValidationResult = value.count <= self.maxLength
      ? .valid
      : .invalid(localizedDescription: "Too long")
    return Observable.of(result)
  }
}
