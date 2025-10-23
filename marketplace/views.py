from django.shortcuts import render, get_object_or_404, redirect
from django.views import View
from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator

from .models import Product, Order, OrderItem, Seller
from .serializers import ProductSerializer, OrderSerializer
from rest_framework import generics


def health(request):
    from django.http import JsonResponse
    return JsonResponse({'status': 'ok'})


def ready(request):
    from django.http import JsonResponse
    # Minimal readiness: DB accessible?
    try:
        from django.db import connections
        connections['default'].cursor()
        return JsonResponse({'ready': True})
    except Exception:
        return JsonResponse({'ready': False}, status=503)


def home(request):
    products = Product.objects.all()[:20]
    return render(request, 'marketplace/home.html', {'products': products})


def product_detail(request, pk):
    product = get_object_or_404(Product, pk=pk)
    return render(request, 'marketplace/product_detail.html', {'product': product})


@method_decorator(login_required, name='dispatch')
class CreateOrderView(View):
    def post(self, request, pk):
        product = get_object_or_404(Product, pk=pk)
        order, created = Order.objects.get_or_create(buyer=request.user, paid=False)
        OrderItem.objects.create(order=order, product=product, quantity=1)
        return redirect('marketplace:order_detail', pk=order.pk)


class ProductListAPI(generics.ListAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer


class OrderDetailAPI(generics.RetrieveAPIView):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer
