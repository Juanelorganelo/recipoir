package io.recipoir.zioapp
package implementation
package postgres

import io.recipoir.quill.CustomQuillNamingStrategy
import io.getquill.PostgresZioJdbcContext

lazy val DbContext = new PostgresZioJdbcContext(CustomQuillNamingStrategy)
