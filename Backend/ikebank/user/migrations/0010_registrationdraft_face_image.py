from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('user', '0009_remove_user_biometric_data_user_face_embedding_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='registrationdraft',
            name='face_image',
            field=models.ImageField(blank=True, null=True, upload_to='face_images/drafts/'),
        ),
    ]
