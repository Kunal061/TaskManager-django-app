from django.test import TestCase
from django.contrib.auth import get_user_model
from ..models import Seller, Product

User = get_user_model()


class SellerProductModelTests(TestCase):
    def setUp(self):
        self.seller_user = User.objects.create_user(username='seller', password='pass')
        self.seller = Seller.objects.create(user=self.seller_user, display_name='Acme')
        self.product = Product.objects.create(seller=self.seller, title='Widget', description='A widget', price='9.99', inventory=5)

    def test_product_str(self):
        self.assertEqual(str(self.product), 'Widget')

    def test_seller_str(self):
        self.assertEqual(str(self.seller), 'Acme')
