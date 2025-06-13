package io.recipoir.zioapp
package implementation
package postgres

import io.getquill.PostgresZioJdbcContext
import io.recipoir.quill.CustomQuillNamingStrategy

lazy val DbContext = new PostgresZioJdbcContext(CustomQuillNamingStrategy)
