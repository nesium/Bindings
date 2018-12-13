//
//  ValidationResult.swift
//  Bindings
//
//  Created by Marc Bauer on 09.04.17.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation

public enum ValidationResult {
  case valid
  case invalid(localizedDescription: String)
}



extension ValidationResult: Equatable {
  public static func ==(lhs: ValidationResult, rhs: ValidationResult) -> Bool {
    switch (lhs, rhs) {
      case (.valid, .valid):
        return true
      case let (.invalid(lhsMsg), .invalid(rhsMsg)):
        return lhsMsg == rhsMsg
      case (.valid, _), (.invalid, _):
        return false
    }
  }
}
