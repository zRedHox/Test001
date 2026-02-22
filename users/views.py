from django.shortcuts import render

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import AppUser
from .serializers import AppUserSerializer

@api_view(["GET", "POST"])
def users_collection(request):
    if request.method == "GET":
        qs = AppUser.objects.all().order_by("-id")
        data = AppUserSerializer(qs, many=True).data
        return Response(data, status=status.HTTP_200_OK)

    # POST
    serializer = AppUserSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response(AppUserSerializer(user).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
