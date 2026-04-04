from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('user', '0015_registrationdraft_face_encoding'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
            PRAGMA foreign_keys=OFF;

            CREATE TABLE IF NOT EXISTS new_django_admin_log (
                id integer NOT NULL PRIMARY KEY AUTOINCREMENT,
                action_time datetime NOT NULL,
                object_id text NULL,
                object_repr varchar(200) NOT NULL,
                action_flag smallint unsigned NOT NULL CHECK (action_flag >= 0),
                change_message text NOT NULL,
                content_type_id integer NULL REFERENCES django_content_type (id) DEFERRABLE INITIALLY DEFERRED,
                user_id bigint NOT NULL REFERENCES user_user (id) DEFERRABLE INITIALLY DEFERRED
            );

            INSERT INTO new_django_admin_log (
                id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id
            )
            SELECT
                id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id
            FROM django_admin_log
            WHERE user_id IN (SELECT id FROM user_user);

            DROP TABLE django_admin_log;
            ALTER TABLE new_django_admin_log RENAME TO django_admin_log;

            CREATE INDEX IF NOT EXISTS django_admin_log_content_type_id_c4bce8eb
                ON django_admin_log (content_type_id);
            CREATE INDEX IF NOT EXISTS django_admin_log_user_id_c564eba6
                ON django_admin_log (user_id);

            PRAGMA foreign_keys=ON;
            """,
            reverse_sql=migrations.RunSQL.noop,
        ),
    ]
