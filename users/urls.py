from django.urls import path
from .views import users_collection

urlpatterns = [
    path("users", users_collection),  # no trailing slash to match requirement
]