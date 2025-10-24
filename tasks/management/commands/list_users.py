from django.core.management.base import BaseCommand
from django.contrib.auth.models import User


class Command(BaseCommand):
    help = 'List all users in the system'

    def add_arguments(self, parser):
        parser.add_argument(
            '--detailed',
            action='store_true',
            help='Show detailed user information',
        )

    def handle(self, *args, **options):
        users = User.objects.all().order_by('username')
        
        if not users:
            self.stdout.write(self.style.WARNING('No users found in the system'))
            return
        
        self.stdout.write(self.style.SUCCESS(f'\nTotal Users: {users.count()}\n'))
        self.stdout.write(self.style.SUCCESS('=' * 80))
        
        if options['detailed']:
            # Detailed view
            for user in users:
                self.stdout.write(f'\n{self.style.HTTP_INFO("Username:")} {user.username}')
                self.stdout.write(f'{self.style.HTTP_INFO("Email:")} {user.email or "Not set"}')
                self.stdout.write(f'{self.style.HTTP_INFO("Full Name:")} {user.get_full_name() or "Not set"}')
                self.stdout.write(f'{self.style.HTTP_INFO("Superuser:")} {"Yes" if user.is_superuser else "No"}')
                self.stdout.write(f'{self.style.HTTP_INFO("Staff:")} {"Yes" if user.is_staff else "No"}')
                self.stdout.write(f'{self.style.HTTP_INFO("Active:")} {"Yes" if user.is_active else "No"}')
                self.stdout.write(f'{self.style.HTTP_INFO("Last Login:")} {user.last_login or "Never"}')
                self.stdout.write(f'{self.style.HTTP_INFO("Date Joined:")} {user.date_joined}')
                self.stdout.write('-' * 80)
        else:
            # Simple view
            self.stdout.write(f'\n{"USERNAME":<20} {"EMAIL":<30} {"SUPERUSER":<12} {"ACTIVE"}')
            self.stdout.write('-' * 80)
            for user in users:
                superuser = '✓ Yes' if user.is_superuser else '✗ No'
                active = '✓ Yes' if user.is_active else '✗ No'
                email = user.email or 'N/A'
                self.stdout.write(f'{user.username:<20} {email:<30} {superuser:<12} {active}')
        
        self.stdout.write(self.style.SUCCESS('\n' + '=' * 80 + '\n'))
