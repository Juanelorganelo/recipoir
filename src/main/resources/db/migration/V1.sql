create table if not exists users (
    id serial primary key,
    username varchar(140) not null,
    email varchar(255) not null,
    -- We use bcrypt for hashing
    -- $2$,$2a$,... = 3 bytes, <digit><digit>$ = 3 bytes, 53 <ascii> chars = 53 bytes total of 60
    password binary(60) not null,
    email_verified boolean not null,
);

create table if not exists backup_codes (
    id serial primary key,
    code uuid unique not null,
    user_id integer references users(id),
);
