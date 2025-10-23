from django.contrib import admin
from .models import Seller, Product, Order, OrderItem, Review


@admin.register(Seller)
class SellerAdmin(admin.ModelAdmin):
    list_display = ('display_name', 'user')


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('title', 'seller', 'price', 'inventory')
    search_fields = ('title', 'description')


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'buyer', 'created_at', 'paid')
    inlines = [OrderItemInline]


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('product', 'author', 'rating', 'created_at')
