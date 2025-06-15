package io.recipoir.zioapp
package implementation
package events

import zio.*

import domain.events.{ EventError, EventPublisher }
import domain.item.Item

final case class NoOpEventPublisher() extends EventPublisher:
  def sendNewItemEvent(item: Item): IO[EventError, Unit] = ZIO.unit

object NoOpEventPublisher:
  val layer: ULayer[EventPublisher] = ZLayer.succeed(NoOpEventPublisher()) 