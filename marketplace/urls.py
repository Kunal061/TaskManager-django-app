from django.urls import path
from . import views

app_name = 'marketplace'

urlpatterns = [
    path('', views.home, name='home'),
    path('products/<int:pk>/', views.product_detail, name='product_detail'),
    path('orders/create/<int:pk>/', views.CreateOrderView.as_view(), name='create_order'),
    path('api/products/', views.ProductListAPI.as_view(), name='api_products'),
    path('api/orders/<int:pk>/', views.OrderDetailAPI.as_view(), name='api_order_detail'),
    path('health/', views.health, name='health'),
    path('ready/', views.ready, name='ready'),
]
