package io.recipoir.zioapp

import zio.*
import zio.config.ConfigErrorOps
import zio.config.magnolia.deriveConfig
import zio.config.typesafe.TypesafeConfigProvider

import implementation.postgres.DbConfig

type ConfigEnv = DbConfig

final case class AppConfig(db: DbConfig)

object AppConfig:
  val layer: TaskLayer[ConfigEnv] =
    val configLayer = ZLayer(TypesafeConfigProvider.fromResourcePath().kebabCase.load(deriveConfig[AppConfig]))
      .mapError(e => new RuntimeException(e.prettyPrint()))
    configLayer.project(_.db)
