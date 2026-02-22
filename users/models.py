from django.db import models

class AppUser(models.Model):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.username} <{self.email}>"