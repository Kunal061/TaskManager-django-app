from django.core.management.base import BaseCommand
from django.contrib.auth.models import User


class Command(BaseCommand):
    help = 'Create default user "rohilla" with predefined password'

    def handle(self, *args, **options):
        username = 'rohilla'
        password = 'Password001'
        email = 'kunalr.tech@gmail.com'
        
        # Check if user already exists
        if User.objects.filter(username=username).exists():
            user = User.objects.get(username=username)
            # Update password
            user.set_password(password)
            user.save()
            self.stdout.write(
                self.style.WARNING(f'User "{username}" already exists. Password updated.')
            )
        else:
            # Create new user
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password,
                is_staff=True,
                is_superuser=True
            )
            self.stdout.write(
                self.style.SUCCESS(f'✅ Successfully created superuser "{username}"')
            )
        
        # Display user info
        self.stdout.write('\n' + '=' * 60)
        self.stdout.write(self.style.HTTP_INFO('User Details:'))
        self.stdout.write(f'  Username: {user.username}')
        self.stdout.write(f'  Email: {user.email}')
        self.stdout.write(f'  Password: {password}')
        self.stdout.write(f'  Superuser: {"Yes" if user.is_superuser else "No"}')
        self.stdout.write(f'  Staff: {"Yes" if user.is_staff else "No"}')
        self.stdout.write('=' * 60 + '\n')
        
        self.stdout.write(
            self.style.SUCCESS(f'\n🎉 You can now login at http://13.233.122.241:9000/admin')
        )
        self.stdout.write(
            self.style.SUCCESS(f'   Username: {username}')
        )
        self.stdout.write(
            self.style.SUCCESS(f'   Password: {password}\n')
        )
