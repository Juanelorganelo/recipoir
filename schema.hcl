table "users" {
    schema = schema.example

    column "id" {
        null = false
        type = int
    }

    column "email" {
        null = false
        type = varchar(255)
        unique = true
    }

    column "password" {
        null = false
        type = varchar(255)
    }

    column "email_verified" {
        null = false
        type = boolean
    }

    primary_key {
        columns = [column.id]
    }
}

table "backup_codes" {
    
}