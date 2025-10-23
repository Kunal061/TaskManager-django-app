from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import Seller, Product

User = get_user_model()


class MarketplaceModelsTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username='buyer', password='pass')
        self.seller_user = User.objects.create_user(username='seller', password='pass')
        self.seller = Seller.objects.create(user=self.seller_user, display_name='Acme')
        self.product = Product.objects.create(seller=self.seller, title='Widget', description='A widget', price='9.99', inventory=5)

    def test_product_str(self):
        self.assertEqual(str(self.product), 'Widget')

    def test_home_view(self):
        resp = self.client.get('/')
        self.assertEqual(resp.status_code, 200)
        self.assertContains(resp, 'Marketplace')
