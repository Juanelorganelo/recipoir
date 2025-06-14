schema "recipoir" {}

table "users" {
  schema = schema.recipoir

  column "id" {
    null = false
    type = int
  }

  column "email" {
    null = false
    type = varchar(255)
  }

  column "password" {
    null = false
    // We do 60 bytes since that's what bcrypt uses for the hash
    type = varchar(60)
  }

  column "email_verified" {
    null = false
    type = boolean
  }

  primary_key {
    columns = [column.id]
  }

  unique "uniq_email" {
    columns = [column.email]
  }
}

table "backup_codes" {
  schema = schema.recipoir

  column "id" {
    null = false
    type = int
  }

  column "user_id" {
    null = false
    type = int
  }

  column "codes" {
    null = false
    type = json
  }
}