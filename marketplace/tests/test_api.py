from django.urls import reverse
from django.test import TestCase
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model
from ..models import Seller, Product, Order

User = get_user_model()


class MarketplaceAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.seller_user = User.objects.create_user(username='seller', password='pass')
        self.seller = Seller.objects.create(user=self.seller_user, display_name='Acme')
        self.product = Product.objects.create(seller=self.seller, title='Widget', description='A widget', price='9.99', inventory=5)
        self.user = User.objects.create_user(username='buyer', password='pass')

    def test_product_list_api(self):
        url = reverse('marketplace:api_products')
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertIsInstance(data, list)
        self.assertGreaterEqual(len(data), 1)

    def test_order_create_requires_auth(self):
        # posting to create_order is an HTML endpoint and requires login; API tests simulate login
        self.client.login(username='buyer', password='pass')
        # create order via view: use DRF client to post to HTML endpoint
        url = reverse('marketplace:create_order', args=[self.product.pk])
        resp = self.client.post(url)
        # after posting, should redirect to order detail
        self.assertIn(resp.status_code, (302, 303))
        order = Order.objects.filter(buyer=self.user).first()
        self.assertIsNotNone(order)
