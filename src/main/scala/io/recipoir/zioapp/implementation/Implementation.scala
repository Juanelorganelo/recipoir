package io.recipoir.zioapp
package implementation

import zio.*

import domain.item.ItemRepository
import domain.events.EventPublisher
import implementation.events.NoOpEventPublisher
import implementation.postgres.{ ItemRepositoryImplementation, PostgresDataSource, DbConfig }
import implementation.auth.AuthService

import javax.sql.DataSource

type ImplementationEnv = AuthService & ItemRepository & EventPublisher

val layer: RLayer[DbConfig, ImplementationEnv] =
  PostgresDataSource.layer >>> ItemRepositoryImplementation.layer ++ AuthService.layer ++ NoOpEventPublisher.layer
