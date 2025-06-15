package io.recipoir.zioapp
package domain

enum ValidationStatus:
  case Validated    extends ValidationStatus
  case NonValidated extends ValidationStatus
